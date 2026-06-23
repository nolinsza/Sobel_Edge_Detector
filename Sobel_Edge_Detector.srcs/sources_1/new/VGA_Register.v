`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 03:50:06 PM
// Design Name: 
// Module Name: VGA_Register
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


module VGA_Register(
    output reg [2:0] reg_out,
    input wire [2:0] reg_in,
    input wire clk_VGA, reset
    );
    
    always @(posedge clk_VGA) begin
      if (reset) begin 
        reg_out <= 3'b0;
      end  
      else begin 
        reg_out <= reg_in; 
      end
    
    end
     
endmodule
