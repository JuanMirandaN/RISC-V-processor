`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.09.2024 22:24:50
// Design Name: 
// Module Name: Alu_sim
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


module Alu_sim;

//module ALU([2:0] ALUControl, [31:0] SrcA,SrcB,[31:0] ALUResult, zero);
    logic [31:0] A,B,Result;
    logic [2:0]ctrl;
    logic zero;
    
    ALU alu1(ctrl,A,B,Result,zero);
    
    initial begin
    
           A= 32'd10; 
           B = 32'd5;
           ctrl = 000;
           
        #5 A= 32'd10; 
           B = 32'd10;
           ctrl = 001;
        #5 A= 32'd5; 
           B = 32'd50;
           ctrl = 001;
        #5 A= 32'hffff; 
           B = 32'h000A;
           ctrl = 010;
        #5 A= 32'hffff; 
           B = 32'h000A;
           ctrl = 011;
        #5 A= 32'd30; 
           B = 32'd100;
           ctrl = 101;
        #5 A= 32'd100; 
           B = 32'd30;
           ctrl = 101;
       $finish;
    end
endmodule
