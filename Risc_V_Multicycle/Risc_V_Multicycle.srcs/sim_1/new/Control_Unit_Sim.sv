`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2024 10:47:02
// Design Name: 
// Module Name: Control_Unit_Sim
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


module Control_Unit_Sim();
    logic [31:0] Instr;
    logic [1:0] ALUSrcA, ALUSrcB, ImmSrc, ResultSrc;
    logic [2:0] ALUControl;
    logic CLK, reset, Zero, PCWrite, RegWrite, MemWrite, IRWrite, AdrSrc;
    Control_Unit C_U(.op(Instr[6:0]), .funct3(Instr[14:12]), .funct7_5(Instr[30]), .Zero(Zero), .rst(reset), .clk(CLK), .PCWrite(PCWrite), .RegWrite(RegWrite), .MemWrite(MemWrite), .IRWrite(IRWrite), .AdrSrc(AdrSrc),
             .ResultSrc(ResultSrc), .ALUSrcB(ALUSrcB), .ALUSrcA(ALUSrcA), .ALUControl(ALUControl), .ImmSrc(ImmSrc));
    initial begin
        #5 Instr = 32'b00000000000100000010010100000011;
           Zero = 0;
           CLK = 0;
        forever #10 CLK = ~CLK;
        
        #60 $finish;
        
    end

endmodule
