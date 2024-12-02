`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.08.2024 08:39:07
// Design Name: 
// Module Name: Register_sim
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

module Register_sim();
    logic [31:0] Q,D;
    logic clk,rst,en;
    
    register reg1(Q,D,clk,rst,en);
    
    initial begin
    
        #5 Q = 'hffa4; //if i dont specify the size is 32 bits default 
           D = 'h00ff;
           clk = 0;
           rst = 0;
           en=1;
           
           #5 rst = 1;
           #1 rst = 0;
           #5 clk = 1;
           #5 clk = 0;D='h0fff;
           #5 clk = 1;
           #5 clk = 0;D='h0fff;
           #5 clk = 1;
           #5 rst = 1;
           #1 rst = 0;
    
    end
    
endmodule


