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


module RISC_V_top(

    );
endmodule

module register(output logic [31:0] Q, input logic [31:0] D,input logic clk,rst,en);

    always_ff @(posedge clk or posedge rst) begin
        if(rst)
            Q <=32'b0; 
        else if(en)
            Q <= D;
    end 
    
endmodule:register


module register_file(input logic [4:0] A1,A2,A3,input logic [31:0] WD3, input logic clk,WE3, output logic [31:0] RD1,RD2);

    logic [31:0] regs [31:0]; //defines 32 x 32-bit registers

    assign regs[5'h00] = 32'h0000; //x0 register hardwired to 0
    assign RD1 = regs[A1];
    assign RD2 = regs[A2];

    always_ff @(posedge clk) begin

        if(WE3)
            regs[A3] <= WD3;
    end
    
endmodule:register_file





