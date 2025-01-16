`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2025 08:49:36 PM
// Design Name: 
// Module Name: Horloge
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


module Horloge(
    input start_stop,
    input reset,
    input set_time,
    input set_alarm,
    input m_clk,
    input [13:0] input_time,
    output alarm,
    input ff,
    input rr,
    input enable,
    output seconds,
    output [3:0] x_anode,
    output [6:0] x_cathode
    );
    reg [13:0] current_time;
    reg [13:0] current_alarm;
    reg [3:0] digit1;
    reg [3:0] digit2;
    reg [3:0] digit3;
    reg [1:0] digit4;
    reg [5:0] counter;
    
    wire z_anode;
    wire b_clk, a_clk, t_clk, d_clk;
    
    assign x_anode = z_anode & (~enable);
    assign b_clk = ( (t_clk & ~ff & ~rr) | (ff & a_clk & ~rr) | (~ff & a_clk & rr) ) & enable;
    assign d_clk = enable & m_clk;
    
    always @(posedge b_clk) begin
        if(reset) 
            counter <= 6'b0;
        else if(counter == 6'd60)
            counter <= 6'b0;
        else if(start_stop)
            counter <= counter + 1;
    end
    
    always @(posedge d_clk) begin
        if(reset) begin
            digit1 <= 4'b0;
            digit2 <= 4'b0;
            digit3 <= 4'b0;
            digit4 <= 2'b0;   
        end else if(set_time) begin
            digit1 <= input_time[3:0];
            digit2 <= input_time[7:4];
            digit3 <= input_time[11:8];
            digit4 <= input_time[13:12];
        end else if(set_alarm) begin
            current_alarm <= input_time;
        end else if(start_stop) begin
            if(digit4 == 2'd2 && digit3 == 4'd4) begin
                digit1 <= 4'b0;
                digit2 <= 4'b0;
                digit3 <= 4'b0;
                digit4 <= 2'b0;
            end else begin
                if(counter == 6'd60) begin
                    digit1 <= digit1 + 1;
                end        
                if(digit1 == 4'd10) begin
                    digit2 <= digit2 + 1;
                    digit1 <= 4'b0;
                end
                if(digit2 == 4'd6) begin
                    digit3 <= digit3 + 1;
                    digit2 <= 4'b0;
                end
                if(digit3 == 4'd10) begin
                    digit4 <= digit4 + 1;
                    digit3 <= 4'b0;
                end
            end   
        end

    end    
   
    always @(posedge d_clk) begin
        current_time[3:0] <= digit1;
        current_time[7:4] <= digit2;
        current_time[11:8] <= digit3;
        current_time[13:12] <= digit4;
    end    
    
endmodule
