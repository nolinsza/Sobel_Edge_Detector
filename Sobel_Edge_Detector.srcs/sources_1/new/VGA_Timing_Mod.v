`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2026 08:58:50 PM
// Design Name: 
// Module Name: VGA_Timing_Mod
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


module VGA_Timing_Mod(               
        output wire [9:0] pixel_x, pixel_y,         //640x480
        output wire hsync, vsync, pixel_write, 
        input wire clk_VGA, reset
    );
    
 reg [9:0] h_count, v_count;
    
 assign hsync = (h_count > 10'd655 && h_count < 10'd752) ? 1'b0 : 1'b1; 
 assign vsync = (v_count == 10'd490 || v_count == 10'd491) ? 1'b0 : 1'b1; 
 
 assign pixel_x = (h_count >= 10'b0 && h_count <= 10'd639) ? h_count : 10'b0;
 assign pixel_y = (v_count >= 10'b0 && v_count <= 10'd479) ? v_count : 10'b0;
 
 assign pixel_write = ( (h_count >= 10'd0 && h_count <= 10'd639) && (v_count >= 10'd0 && v_count <= 10'd479) ) ? 1'b1 : 1'b0; 
 
 always @(posedge clk_VGA or posedge reset) begin 
    if (reset) begin 
        h_count <= 10'b0;
        v_count <= 10'b0;
    end 
    else begin
        //h_count limit
        if (h_count == 10'd799) begin 
            //first check for vertical increment 
            if (v_count == 10'd524) begin 
                v_count <= 10'b0;
            end
            else begin 
                v_count <= v_count + 1'b1;
            end
            //reset the horizontal increment
            h_count <= 10'b0; 
        end
        
        //incrment h_count
        else begin 
            h_count <= h_count + 1'b1; 
        end
    end
            
  end
            
endmodule
