`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2026 10:43:32 PM
// Design Name: 
// Module Name: streaming_mod
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


module streaming_mod(
    //Camera Pins
    output wire SCL,
    inout wire SDA,
    input wire VS,          //VSYNC
    input wire HS,          //HREF 
    input wire PLK,         //Pixel Clock 
    output wire XLK,        //driving clock (24MHZ) 
    input wire [7:0] D,
    //output wire reset_camera,   //active low - wired to hot 
    //FPGA Control Pins
    input wire reset, start_sig, clk,
    //VGA Pins
    output wire [3:0] VGA_R, VGA_G, VGA_B,
    output wire VGA_hsync, VGA_vsync
    );
    
    wire camera_write_en;
    wire [9:0] camera_addr_x, camera_addr_y;
    wire [18:0] camera_addr;
    wire[11:0] pixel_in; 

    wire clk_VGA, locked;
    
    //I2C Config Module
    sccb sccb(.reset(reset),
    .start_sig(start_sig),
    .clk(clk),
    .SIO_C(SCL),
    .SIO_D(SDA));

    //Create slower clocks
    clk_wiz_0 clk_wiz_VGA (
    .clk_in1(clk),
    .clk_out1(clk_VGA),
    .clk_out2(XLK),
    .reset(reset),
    .locked(locked)
    ); 
    
    
    
    //Camera Input
    OV7670_Input camera_input(
    //inputs
    .PCLK(PLK),.HREF(HS), .VSYNC(VS), .reset(reset),
    .data(D),
    //outputs
    .x_idx(camera_addr_x), .y_idx(camera_addr_y),
    .R_data(pixel_in[11:8]), .G_data(pixel_in[7:4]), .B_data(pixel_in[3:0]),
    .write_en(camera_write_en)
    );
    
    //compute the address for the frame buffer
    assign camera_addr = (camera_addr_y<<9) + (camera_addr_y<<7) + camera_addr_x; //640*y_addr + x_addr
    
    //----------------------------------------------------VGA_Mod-------------------------------------------------------------
    //VGA_Timing_Mod
    wire [9:0] x_addr, y_addr;
    wire hsync_VGA_Timing, vysnc_VGA_Timing, active_pixel_VGA_Timing; 
    
    //Address lookup for framebuffer 
    wire [18:0] pixel_address;
    wire [11:0] pixel_buffer; 

    wire active_pixel_out;
    
    //Create VGA Timing signals and x,y coordinates 
    VGA_Timing_Mod VGA_Timing(
    //outputs
    .pixel_x(x_addr), .pixel_y(y_addr),   
    .hsync(hsync_VGA_Timing), .vsync(vsync_VGA_Timing), .active_pixel(active_pixel_VGA_Timing), 
    //inputs
    .clk_VGA(clk_VGA), .reset(reset)
    );
    
    //compute the address for the frame buffer
    assign pixel_address = (y_addr<<9) + (y_addr<<7) + x_addr; //640*y_addr + x_addr
    
    //-----------------------------------FRAME BUFFER----------------------------------------------------
    frame_buffer Frame_Buffer(
    //output
    .pixel_vga(pixel_buffer),
    //inputs
    .clk_vga(clk_VGA), .clk_camera(PLK), .camera_write_en(camera_write_en),
    .address_vga(pixel_address), .address_camera(camera_addr), .pixel_camera(pixel_in)
    );
    
    VGA_Register VGA_Reg(
    .reg_out({VGA_hsync, VGA_vsync, active_pixel_out}),
    .reg_in({hsync_VGA_Timing, vsync_VGA_Timing, active_pixel_VGA_Timing}),
    .clk_VGA(clk_VGA), .reset(reset)
    );
    
    assign VGA_R = (active_pixel_out == 1'b1) ? pixel_buffer[11:8] : 4'b0;
    assign VGA_G = (active_pixel_out == 1'b1) ? pixel_buffer[7:4]  : 4'b0;
    assign VGA_B = (active_pixel_out == 1'b1) ? pixel_buffer[3:0]  : 4'b0;
    
    //----------------------------------------------END VGA_Mod------------------------------------------------------------------
    
    
    
    
endmodule
