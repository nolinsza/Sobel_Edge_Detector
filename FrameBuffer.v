`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 01:48:24 PM
// Design Name: 
// Module Name: FrameBuffer
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


module FrameBuffer(
    output reg [11:0] pixel,
    input wire clk_VGA, 
    input wire [18:0] address
    );
    
    //640*480 (307200) memory locationg for 444 RGB (12 bits) 
    reg [11:0] framebuffer [0: 307199];
    
    //intiialize the BRAM with test image 
    integer x, y, addr; 
    initial begin 
        for (y = 0; y < 480; y = y + 1) begin 
        
            for (x = 0; x < 640; x = x + 1) begin 
            
                addr = y*640 + x; 
                
                 if(x < 80)
                    framebuffer[addr] = 12'hF00; // red
    
                else if(x < 160)
                    framebuffer[addr] = 12'h0F0; // green
    
                else if(x < 240)
                    framebuffer[addr] = 12'h00F; // blue
    
                else if(x < 320)
                    framebuffer[addr] = 12'hFF0; // yellow
    
                else if(x < 400)
                    framebuffer[addr] = 12'h0FF; // cyan
    
                else if(x < 480)
                    framebuffer[addr] = 12'hF0F; // magenta
    
                else if(x < 560)
                    framebuffer[addr] = 12'hFFF; // white
    
                else
                    framebuffer[addr] = 12'hFFF; // black
                end
            end
        end
    
    always @(posedge clk_VGA) 
    begin 
        pixel <= framebuffer[address];
    end 
    
endmodule
