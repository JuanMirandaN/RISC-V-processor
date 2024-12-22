`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.09.2024 23:07:53
// Design Name: 
// Module Name: RF_sim
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


module RF_sim;
//register_file([4:0] A1,A2,A3,[31:0] WD3, clk,WE3, [31:0] RD1,RD2);
    logic [4:0] A1,A2,A3;
    logic [31:0] WD3,RD1,RD2;
    logic clk,WE3;
    bit error;
    
    register_file rf1 (A1 ,A2, A3, WD3, clk, WE3, RD1, RD2);

    //all initial blocks starts at the same time
    // i can set the clock with a forever statement 
    //
    initial begin
        error = 0;
        WE3 = 0;
        clk = 0;
       forever #5 clk = ~clk;
    end
    
    initial begin 
        WE3 = 1;
        A1 = 2;
        A2 = 3;
   
        A3 = 4;
        WD3 = 32'h0000ffff;
        
        #5 WE3 = 0;
        
        if(RD1 != 'b01101101110111111001001010010101) begin
            $display("Error: A1 = %b\n",RD1);
            error = 1;
        end
        
        if(RD2 != 'b11111111110101011100000011100101) begin
            $display("Error: A2 = %b\n",RD2);
            error = 1;
        end
        
        A2 = 4;
        #2
        if(RD2 != 'b11111111110101011100000011100101) begin
            $display("Error: A2 = %b\n",RD2);
            error = 1;
        end
        
        if(error == 0)
            $display("It's all good man!\n");
        else
            $display("Error encountered :(\n"); 
            
        #5 $finish;
    end
    
endmodule
    
    
    
    
//    initial begin
//        for (int i = 1; i < 32; i++)
//            rf1.regs[i] = i;//change the value of the regs memory INSIDE rf1 instance 
//    end 
    
//    initial begin
//        for (int i = 0; i < 32; i++) begin
//            @(posedge clk);
//            A1 = i;
//            #2;
//            if (RD1 != i)
//                $display ("Error: regs[%d] = %d\n", i, RD1);//verify the writing of each register
//        end
//   end 

//    initial begin
//        A1 = 5'b00000;
//        A2 = 5'b00010;
//        A3 = 5'b00010;
//        WD3 = 32'hff0a;
//        WE3 = 0;
        
        
//        @(posedge clk);// change the values after clk positive edge 
//        A1 = 5'b00000;
//        A2 = 5'b00010;
//        A3 = 5'b00010;
//        WD3 = 32'hff0a;
//        WE3 = 0;
        
        
//        @(posedge clk); #2
//        A1 = 5'b00000;
//        A2 = 5'b00010;
//        A3 = 5'b00010;
//        WD3 = 32'hff0a;
//        WE3 = 1;
        
//        @(posedge clk); #2
//        if (RD2 != 32'hff0a)
//            $display ("error");    



//     #5 A1 = 5'b00000;
//        A2 = 5'b00010;
//        A3 = 5'b00010;
//        WD3 = 32'hff0a;
//        WE3 = 1;
//        clk = 1;
//     #5 A1 = 5'b00000;
//        A2 = 5'b00010;
//        A3 = 5'b00000;
//        WD3 = 32'hff0a;
//        WE3 = 1;
//        clk = 0;
//     #5 A1 = 5'b00000;
//        A2 = 5'b00010;
//        A3 = 5'b00000;
//        WD3 = 32'hff0a;
//        WE3 = 1;
//        clk = 1;
//     #5
        
//        $finish;
//    end  
    
    
    //always begin
      //  #5 assign clk = ~clk;      
    //end
    
//endmodule
