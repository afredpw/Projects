`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by: Alfred Woodny Pierre  
// 
// Create Date: 12/17/2024 05:29:08 PM
// Module Name: timer_sim
// Project Name: Personal_project1

//////////////////////////////////////////////////////////////////////////////////


module timer_sim();
    reg clk_in_t;
    reg [15:0] target_t;
    wire [15:0] count_t;
    wire clk_out_t;
    
    timer timerUUT( .clk_in(clk_in_t), .target(target_t),  .clk_out(clk_out_t) );
    
    initial begin
        clk_in_t = 1'b0;
        target_t = 16'd1000;
    
    end
    
    always #5 clk_in_t = ~clk_in_t;
    
    
    
endmodule
