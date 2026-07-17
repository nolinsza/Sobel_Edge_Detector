`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2026 10:07:53 PM
// Design Name: 
// Module Name: frame_buffer
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


module frame_buffer(
    output reg [11:0] pixel_vga,
    input wire clk_vga, clk_camera, camera_write_en,
    input wire [18:0] address_vga, address_camera,
    input wire [11:0] pixel_camera
    );
    
    //640*480 (307200) memory locationg for 444 RGB (12 bits) 
    reg [11:0] framebuffer [0: 307199];
    
    //intiialize the BRAM with test image 
    
    always @(posedge clk_vga) 
    begin 
        pixel_vga <= framebuffer[address_vga];
    end 
    
    always @(posedge clk_camera)
    begin
        if (camera_write_en == 1'b1)
            framebuffer[address_camera] <= pixel_camera;
    end
    
endmodule
