`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.08.2024 08:59:27
// Design Name: 
// Module Name: RISC_V_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//comments:
//-start with control unit
//-run post synthesis simulation


module RISC_V_top(input logic CLK, reset);
                    
    logic [31:0] PC, Adr,/*ReadData*/ Data, OldPC, Instr, ImmExt;
    logic [31:0] RD1, RD2, WriteData, A, SrcA, SrcB, ALUResult, ALUOut, Result;
    logic Zero, RegWrite, IRWrite, MemWrite, AdrSrc, PCWrite;
    logic [1:0] ResultSrc, ALUSrcA, ALUSrcB, ImmSrc;
    logic [2:0] ALUControl;
    
                        //Result == PCNext
    register PCNext_PC(.D(Result),.Q(PC),.clk(CLK), .rst(reset), .en(PCWrite));                
    
    mux_2 PC_Adr(.A(PC), .B(Result), .SEL(AdrSrc), .Y(Adr));
    
    instr_data_memory i_d_mem(.A(Adr), .WD(WriteData), .clk(CLK), .WE(MemWrite), .IRWrite(IRWrite), .Instr(Instr), .Data(Data));
    
    register PC_OldPC (.D(PC),.Q(OldPC), .clk(CLK), .rst(reset), .en(IRWrite));
    
    Control_Unit C_U(.op(Instr[6:0]), .funct3(Instr[14:12]), .funct7_5(Instr[30]), .Zero(Zero), .rst(reset), .clk(CLK), .PCWrite(PCWrite), .RegWrite(RegWrite), .MemWrite(MemWrite), .IRWrite(IRWrite), .AdrSrc(AdrSrc),
             .ResultSrc(ResultSrc), .ALUSrcB(ALUSrcB), .ALUSrcA(ALUSrcA), .ALUControl(ALUControl), .ImmSrc(ImmSrc));
             
    register_file rf(.A1(Instr[19:15]),.A2(Instr[24:20]),.A3(Instr[11:7]), .WD3(Result), .clk(CLK), .WE3(RegWrite) , .RD1(RD1), .RD2(RD2));
    
    register RD1_A(.D(RD1), .Q(A), .clk(CLK), .rst(reset), .en(1'b1));
    register RD2_WriteData(.D(RD2), .Q(WriteData), .clk(CLK), .rst(reset), .en(1'b1));
    
    extend xtnd(.instr(Instr[31:7]), .ImmSrc(ImmSrc), .ImmExt(ImmExt));
    
    mux_3 A_SrcA(.A(PC), .B(OldPC),.C(A), .SEL(ALUSrcA), .Y(SrcA));
    mux_3 WriteData_SrcB(.A(WriteData), .B(ImmExt),.C(32'd4), .SEL(ALUSrcB), .Y(SrcB)); 
    
    ALU ALU1 (.ALUControl(ALUControl), .SrcA(SrcA), .SrcB(SrcB), .ALUResult(ALUResult), .zero(Zero));               
    
    register ALUResult_ALUOut(.D(ALUResult), .Q(ALUOut), .clk(CLK), .rst(reset), .en(1'b1));
    
    mux_3 ALUOut_Result (.A(ALUOut), .B(Data), .C(ALUResult), .SEL(ResultSrc), .Y(Result));
    
    
                  
                    
endmodule

module register(output logic [31:0] Q, input logic [31:0] D,input logic clk,rst,en);

    always_ff @(posedge clk) begin
        if(rst)
            Q <=32'b0; 
        else if(en)
            Q <= D;
    end 
    
endmodule:register


module register_file(input logic [4:0] A1,A2,A3,input logic [31:0] WD3, input logic clk,WE3, output logic [31:0] RD1,RD2);

    logic [31:0] regs [1:31]; //defines 32 unpack x 32-bit packed registers
   //[1:31] bc i never access the 0,
   //if i do combinational reading im synthetizing LOOT table's 
   //a way to avoid this is to do synchronic reading with the non architectural
   //registers inside the module 
   initial begin
        $readmemb("initial_register_file.mem",regs);
   end 
    
    always_comb
        if (A1 != 5'b00000)
            RD1 = regs[A1];
        else
            RD1 = 32'b0;

    always_comb
        if (A2 != 5'b00000)
            RD2 = regs[A2];
        else
            RD2 = 32'b0;
                
    always_ff @(posedge clk) begin

        if(WE3 && (A3 != 5'b00000))
            regs[A3] <= WD3;
        //else if (rst) //the problem was that i cant just reset an asic chip. but i can reset an fpga 
        //    for (i = 0;i<32;i++) begin
          //      for(j = 0;j<32;j++)begin
            //        regs[i][j] <= 0;
              //  end
            //end
    end
    
endmodule:register_file

module instr_data_memory(input logic [31:0] A, WD, input logic clk, WE, IRWrite,
                         output logic [31:0] Instr, Data);
                         
    logic [12:0] Aint;
 
    logic [31:0] mem [8192];//should I verify A limits?          //PC value goes from 0 to 2^32 - 1 = 4294967295

    initial begin
        $readmemb("initial_data_i_files.mem",mem);
    end 
    
    assign Aint = A[12:0];// to avoid indexing non existing data.
    
    always_ff @(posedge clk) begin //non-architectural registers inside the module
        Data <= mem[Aint];
        if (IRWrite)
            Instr <= mem[Aint];
    end

    always_ff @(posedge clk) begin
        if(WE)
            mem[Aint] <= WD;
        end 

endmodule : instr_data_memory


//module extend_00(input logic [11:0] Imm,output logic ImmExt);
    //assign ImmExt = Imm
//endmodule


module extend(input logic [1:0] ImmSrc, input logic [31:7] instr, output logic [31:0] ImmExt); //may i use the same module for all cases? or i should write 4 separate modules?

    always_comb
        unique case(ImmSrc)//unique case bc there´s only 4 options, with the same priority
            2'b00: ImmExt = {{20{instr[31]}}, instr[31:20]};

            2'b01: ImmExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            2'b10: ImmExt = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

            2'b11: ImmExt = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            
            2'bx:  ImmExt = 32'hx;
        endcase
endmodule 



module ALU(input logic [2:0] ALUControl, input logic [31:0] SrcA, SrcB, 
           output logic [31:0] ALUResult, output logic zero);
           
    logic [31:0] aux;
    assign zero = (ALUResult == 0); //i'd need memory to save the previous vlaue of zero 
                                    //if i only set zero in the case 001    
    
    
    always_comb
        unique case(ALUControl)
            3'b000: ALUResult = SrcA + SrcB;
            3'b001: ALUResult = SrcA - SrcB;
            3'b010: ALUResult = SrcA & SrcB;
            3'b011: ALUResult = SrcA | SrcB;
            3'b101: begin
                    aux = SrcA - SrcB;
                    ALUResult = {31'b0,aux[31]}; //esta no sé como implementarla, hay que revisar el overflow? 
                    end
        endcase
endmodule



//control unit FSM
module instr_decoder(input logic[6:0] op, 
                     output logic [1:0] ImmSrc);
    always_comb 
        unique case(op)
            7'd3: ImmSrc = 2'b00;
            7'd35: ImmSrc = 2'b01;
            7'd51: ImmSrc = 2'bxx;
            7'd99: ImmSrc = 2'b10;
            //insert more instructions
            7'bx:  ImmSrc = 2'bx;
        endcase        
         
endmodule 

module ALU_decoder(input logic [1:0] ALUop, input logic [2:0] funct3,
                   input logic funct7_5, input logic op_5, output logic [2:0] ALUControl);

    always_comb
        unique case(ALUop)
            2'b00: ALUControl = 000;
            2'b01: ALUControl = 001;
            2'b10: begin 
                unique case(funct3)
                    3'b000:
                        if(op_5 & funct7_5)
                            ALUControl = 001;//if op==1 and funct7_5==1
                        else
                            ALUControl = 000;
                    3'b010:
                        ALUControl = 101;
                    3'b110:
                        ALUControl = 011;
                    3'b111:
                        ALUControl = 010;
                    default
                        ALUControl = 000;
                endcase
            end
            default
                ALUControl = 000;//are default cases necessary?
        endcase
endmodule


module main_FSM(input logic [6:0] op, input logic rst, clk,
                output logic Branch, PCUpdate, RegWrite, MemWrite, IRWrite, AdrSrc,
                output logic [1:0] ResultSrc, ALUSrcB, ALUSrcA, ALUOp); 
    enum logic [3:0]{S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10} State, NextState;
    
    
    always_ff @(posedge clk) begin
        if(rst)
            State <= S0;
        else
            State <= NextState; 
    end
                       
    always_comb begin     
        unique case(State)
            S0: begin //FETCH
                    
                    //Write enable signals(default 0)
                    RegWrite = 0;
                    MemWrite = 0;
                    IRWrite = 1;
                    PCUpdate = 1;
                    Branch = 0;
                    
                    //Other signals (default X)
                    
                    AdrSrc = 0;//1 bit
                    
                    ResultSrc = 2'b10; //2 bit
                    ALUSrcA = 2'b00;
                    ALUSrcB = 2'b10;
                    ALUOp = 2'b00;
                    
                   
                    //Next State
                    NextState = S1;
                end
            S1: begin //DECODE
            
                    //Write enable signals(default 0)
                    RegWrite = 0;
                    MemWrite = 0;
                    IRWrite = 0;//it should be 0
                    PCUpdate = 0;
                    Branch = 0;
                    
                    //Other signals (default X)
                    
                    AdrSrc = 1'bx;//1 bit
                    
                    ResultSrc = 2'bxx; //2 bit
                    ALUSrcA = 2'bxx;
                    ALUSrcB = 2'bxx;
                    ALUOp = 2'bxx;
                    
                   
                    //Next State
                    if (op == 7'b0000011 || op == 7'b0100011)
                        NextState = S2;
                end
                
                
            S2: begin //MemAdr
                
                //Write enable signals(default 0)
                    RegWrite = 0;
                    MemWrite = 0;
                    IRWrite = 0;
                    PCUpdate = 0;
                    Branch = 0;
                    
                    //Other signals (default X)
                    
                    AdrSrc = 1'bx;//1 bit
                    
                    ResultSrc = 2'bxx; //2 bit
                    ALUSrcA = 2'b10;
                    ALUSrcB = 2'b01;
                    ALUOp = 2'b00;
                    
                   
                    //Next State
                    if(op == 7'b0000011)
                        NextState = S3;
                    else if(op == 7'b0100011)
                        NextState = S5;
                end

            S3: begin//MemRead
                
                //Write enable signals(default 0)
                    RegWrite = 0;
                    MemWrite = 0;
                    IRWrite = 0;
                    PCUpdate = 0;
                    Branch = 0;
                    
                    //Other signals (default X)
                    
                    AdrSrc = 1'b1;//1 bit
                    
                    ResultSrc = 2'b00; //2 bit
                    ALUSrcA = 2'bxx;
                    ALUSrcB = 2'bxx;
                    ALUOp = 2'bxx;
                    
                   
                    //Next State
                    NextState = S4;
                
                
                end

            S4: begin //MemWB
                
                //Write enable signals(default 0)
                    RegWrite = 1;
                    MemWrite = 0;
                    IRWrite = 0;
                    PCUpdate = 0;
                    Branch = 0;
                    
                    //Other signals (default X)
                    
                    AdrSrc = 1'bx;//1 bit
                    
                    ResultSrc = 2'b01; //2 bit
                    ALUSrcA = 2'bxx;
                    ALUSrcB = 2'bxx;
                    ALUOp = 2'bxx;
                    
                   
                    //Next State
                    NextState = S0;
                
                
                end
                
                
            S5: begin //MemWrite
                
                //Write enable signals(default 0)
                    RegWrite = 0;
                    MemWrite = 1;
                    IRWrite = 0;
                    PCUpdate = 0;
                    Branch = 0;
                    
                    //Other signals (default X)
                    
                    AdrSrc = 1'b1;//1 bit
                    
                    ResultSrc = 2'b00; //2 bit
                    ALUSrcA = 2'bxx;
                    ALUSrcB = 2'bxx;
                    ALUOp = 2'bxx;
                    
                   
                    //Next State
                    NextState = S0;
                
                
                end 
     
            4'bx: begin
                
                //Write enable signals(default 0)
                    RegWrite = 0;
                    MemWrite = 0;
                    IRWrite = 0;
                    PCUpdate = 0;
                    Branch = 0;
                    
                    //Other signals (default X)
                    
                    AdrSrc = 1'bx;//1 bit
                    
                    ResultSrc = 2'bxx; //2 bit
                    ALUSrcA = 2'bxx;
                    ALUSrcB = 2'bxx;
                    ALUOp = 2'bxx;
                    
                   
                    //Next State
                    //NextState = 4'bx;
                
                
                end
                                               
                
                   
                
            
             
        endcase
        
    end


endmodule


module Control_Unit(input logic [6:0]op, input logic [14:12]funct3, input logic funct7_5, Zero, rst, clk,  
                    output logic PCWrite, AdrSrc, MemWrite, IRWrite, RegWrite,
                    output logic [1:0] ResultSrc, ALUSrcA, ALUSrcB, ImmSrc,
                    output logic [2:0] ALUControl);
                    
    logic Branch, PCUpdate, aux1;
    logic [1:0] ALUOp;
    
    main_FSM mfsm(.op(op),.rst(rst), .clk(clk),.Branch(Branch), .PCUpdate(PCUpdate), .RegWrite(RegWrite), .MemWrite(MemWrite), .IRWrite(IRWrite), .AdrSrc(AdrSrc),
             .ResultSrc(ResultSrc), .ALUSrcB(ALUSrcB), .ALUSrcA(ALUSrcA), .ALUOp(ALUOp));
    
    ALU_decoder ALU_dec(.ALUop(ALUOp), .funct3(funct3), .funct7_5(funct7_5), .op_5(op[5]), .ALUControl(ALUControl));
    
    instr_decoder id(.op(op), .ImmSrc(ImmSrc));
    
    and a1(aux1, Zero, Branch);
    or o1 (PCWrite, aux1, PCUpdate);
    
endmodule



module mux_2(input logic [31:0] A, B, input logic SEL, output logic [31:0] Y);
    assign Y = (SEL ? B : A);
endmodule


module mux_3(input logic [31:0] A, B, C, input logic [1:0] SEL, output logic [31:0] Y);
    always_comb begin
        unique case(SEL)
            2'b00:
                Y = A;
            2'b01:
                Y = B;
            2'b10:
                Y = C;
            2'bxx:
                Y = 32'hxxxxxxxx;
        endcase  
    end
endmodule
