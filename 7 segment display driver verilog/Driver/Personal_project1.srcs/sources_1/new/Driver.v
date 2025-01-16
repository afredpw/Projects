`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Create Date: 12/19/2024 06:18:37 PM
// Module Name: Driver
// Project Name: Personal project 1 
// Target Devices: Basys 3 Artix FPGA board 
// Tool Versions: 
// Description: 
// 
// Dependencies: timer.v
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module Driver(input [15:0] in, input clk, output reg [3:0] d_anode, output reg [6:0] d_cathode);
    wire refresh_clk;   //wire to instantiate timer output clock signal
    wire switch_clk;
    //specific of vivado and amd fpga families no explicit reset meachanism is required to initialize register values contrary to verilog standard
    reg [20:0] target_1 = 21'd400003;
    reg [20:0] target_2 = 21'd400000;   //250Hz
    
    //wires for each digit.
    wire [3:0] digit_1 = in[3:0];
    wire [3:0] digit_2 = in[7:4];
    wire [3:0] digit_3 = in[11:8];
    wire [3:0] digit_4 = in[15:12];
    
    //state and select reg to individually target each four digits.
    reg [1:0] state = 2'b00;    
    reg [3:0] select;
    
    // instantiation of timer module.
    timer timer_ref(.clk_in(clk), .target(target_1), .clk_out(refresh_clk) );
    timer timer_swt(.clk_in(clk), .target(target_2), .clk_out(switch_clk) );
    
    always @(posedge switch_clk) begin
        state = state + 1;  //switch states
    end
    
    
    
    
    always @(posedge switch_clk) begin
        //go to the next digit on each rising edge of the clock
        case(state)
            2'b00: begin
                d_anode = 4'b0111;
                select = digit_3;                 
            end
            2'b01: begin
                d_anode = 4'b1011;
                select = digit_2; 
            end
            2'b10: begin
                d_anode = 4'b1101;
                select = digit_1; 
            end
            2'b11: begin
                d_anode = 4'b1110;
                select = digit_4; 
            end                
        endcase
    end
    
    always @(posedge switch_clk) begin
        //encode 4bit digit value to the conresponding 7bit seven segment pattern with dont care after 9
        case(select)
            4'b0000: d_cathode = 7'b0000001;
            4'b0001: d_cathode = 7'b1001111;
            4'b0010: d_cathode = 7'b0010010;
            4'b0011: d_cathode = 7'b0000110;
            4'b0100: d_cathode = 7'b1001100;
            4'b0101: d_cathode = 7'b0100100;
            4'b0110: d_cathode = 7'b0100000;
            4'b0111: d_cathode = 7'b0001111;
            4'b1000: d_cathode = 7'b0000000;
            4'b1001: d_cathode = 7'b0000100;
            4'b1010: d_cathode = 7'bx;
            4'b1011: d_cathode = 7'bx;
            4'b1100: d_cathode = 7'bx;
            4'b1101: d_cathode = 7'bx;
            4'b1110: d_cathode = 7'bx;
            4'b1111: d_cathode = 7'bx;
            
        endcase
    end
endmodule
