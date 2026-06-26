`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 04:07:37 PM
// Design Name: 
// Module Name: VGA_Mod
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


module VGA_Mod(
    output wire [3:0] VGA_R, VGA_G, VGA_B,
    output wire VGA_hsync, VGA_vsync,
    input wire reset, clk
    );
    
    wire clk_VGA, locked, system_reset;
    
    //VGA_Timing_Mod
    wire [9:0] x_addr, y_addr;
    wire hsync_VGA_Timing, vysnc_VGA_Timing, active_pixel_VGA_Timing; 
    
    //Address lookup for framebuffer 
    wire [18:0] pixel_address;
    wire [11:0] pixel_buffer; 
    
    //VGA_register 
    wire active_pixel_out;
    
    //Create 25MHx clock signal for VGA 
    clk_wiz_0 clk_wiz_VGA (
    .clk_in1(clk),
    .clk_out1(clk_VGA),
    .reset(reset),
    .locked(locked)
    ); 
    
    assign system_reset = reset | ~locked; 
    
    /*
    //for simulation 
    assign clk_VGA = clk;
    assign system_reset = reset; 
    */
    
    //Create VGA Timing signals and x,y coordinates 
    VGA_Timing_Mod VGA_Timing(
    //outputs
    .pixel_x(x_addr), .pixel_y(y_addr),   
    .hsync(hsync_VGA_Timing), .vsync(vsync_VGA_Timing), .active_pixel(active_pixel_VGA_Timing), 
    //inputs
    .clk_VGA(clk_VGA), .reset(system_reset)
    );
    
    //compute the address for the frame buffer
    assign pixel_address = (y_addr<<9) + (y_addr<<7) + x_addr; //640*y_addr + x_addr
    
    FrameBuffer Frame_Buffer(
    //output
    .pixel(pixel_buffer),
    //inputs
    .clk_VGA(clk_VGA), 
    .address(pixel_address)
    );
    
    VGA_Register VGA_Reg(
    .reg_out({VGA_hsync, VGA_vsync, active_pixel_out}),
    .reg_in({hsync_VGA_Timing, vsync_VGA_Timing, active_pixel_VGA_Timing}),
    .clk_VGA(clk_VGA), .reset(system_reset)
    );
    
    assign VGA_R = (active_pixel_out == 1'b1) ? pixel_buffer[11:8] : 4'b0;
    assign VGA_G = (active_pixel_out == 1'b1) ? pixel_buffer[7:4]  : 4'b0;
    assign VGA_B = (active_pixel_out == 1'b1) ? pixel_buffer[3:0]  : 4'b0;

    
endmodule


module VGA_tb (); 
    wire [3:0] VGA_R, VGA_G, VGA_B;
    wire VGA_hsync, VGA_vsync;
    reg reset, clk;
    
    VGA_Mod SUT(.VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
    .VGA_hsync(VGA_hsync), .VGA_vsync(VGA_vsync), 
    .reset(reset), .clk(clk));
    
    parameter PERIOD = 10; 
    initial clk = 1'b0;
    always #(PERIOD/2) clk = ~clk;
    
    initial begin 
        reset = 1'b1; #PERIOD; 
        reset = 1'b0; #PERIOD;
                      #5_000_000;
                      
    end 
    
endmodule 

