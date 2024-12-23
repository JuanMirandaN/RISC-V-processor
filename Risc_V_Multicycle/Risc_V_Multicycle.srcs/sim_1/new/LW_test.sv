`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2024 10:26:38
// Design Name: 
// Module Name: LW_test
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


module LW_test();
    logic clk;
    logic reset;
    //integer N_Instructions = ;
    
    RISC_V_top RV(.CLK(clk), .reset(reset));
    
    initial begin
        clk = 0;
        reset = 1;
        forever #10 clk = ~clk;

    end
    
    initial begin 
        #12 reset = 0;
        
        #540
        $finish;
    end
    


    
    
endmodule
