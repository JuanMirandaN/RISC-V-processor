`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2024 11:01:15
// Design Name: 
// Module Name: main_fsm_sim
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


module main_fsm_sim();
    
    logic [31:0] Instr;
    logic [1:0] ALUSrcA, ALUSrcB, ResultSrc;
    logic [1:0] ALUOp;
    logic CLK, reset, RegWrite, MemWrite, IRWrite, AdrSrc, Branch, PCUpdate;
    
    main_FSM mfsm(.op(Instr[6:0]),.rst(reset), .clk(CLK),.Branch(Branch), .PCUpdate(PCUpdate), .RegWrite(RegWrite), .MemWrite(MemWrite), .IRWrite(IRWrite), .AdrSrc(AdrSrc),
             .ResultSrc(ResultSrc), .ALUSrcB(ALUSrcB), .ALUSrcA(ALUSrcA), .ALUOp(ALUOp));
    
    initial begin
           reset = 0;
        #5 reset = 1;
        #5 reset = 0;
        
        #5 Instr = 32'b00000000000100000010010100000011;
        #5 CLK = 1;
        
        
        #5 forever #10 CLK = ~CLK;
        
        #60 $finish;
        
    end




endmodule
