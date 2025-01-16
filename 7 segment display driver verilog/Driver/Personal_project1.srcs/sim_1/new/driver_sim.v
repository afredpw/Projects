`timescale 1ns / 1ps
//module Driver(input [15:0] in, input clk, output reg [3:0] d_anode, output reg [6:0] d_cathode );
//    wire refresh_clk;
//    wire switch_clk;


module driver_sim();
    reg [15:0] in_t;
    reg clk_t;
    wire [3:0] d_anode_t;
    wire [6:0] d_cathode_t;
    wire refresh_t, switch_t;
    
    Driver driver_UUT(.in(in_t), .clk(clk_t), .d_anode(d_anode_t), .d_cathode(d_cathode_t));
    
    initial begin 
        in_t = 16'b1001000101001000; //9148
        clk_t = 1'b0;
    end
    
    always #5 clk_t = ~clk_t;    

endmodule
