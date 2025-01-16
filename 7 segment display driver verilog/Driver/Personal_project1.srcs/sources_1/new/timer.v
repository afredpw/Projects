`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by: Alfred Woodny Pierre
// 
// Create Date: 12/17/2024 05:03:42 PM 
// Module Name: timer
// Project Name: Personal_project1
// Target Devices: Basys3 Artix 7
// Description: 21-bit timer module to provide timing control for driver
// 
// Dependencies: none
// 
// Revision: none
// Revision 0.01 - File Created
// Additional Comments: none
// 
//////////////////////////////////////////////////////////////////////////////////


module timer(input clk_in, input [20:0] target, output reg clk_out = 1'b0);
    reg [20:0] count = 21'b0;
    always @(posedge clk_in) begin
        count = count + 1;
        if(count == target)
            clk_out <= 1'b1;
        else if(count > target)begin
            count <= 21'b0;
            clk_out <= 1'b0;
        end    
        else
            clk_out <= 1'b0;                            
    end
    
endmodule
