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
    output wire SCL,
    inout wire SDA,
    input wire VS,          //VSYNC
    input wire HS,          //HREF 
    input wire PLK,         //Pixel Clock 
    output wire XLK,        //driving clock (24MHZ) 
    input wire [7:0] D,
    output wire reset_camera,   //active low 
    input wire reset, start_sig, clk
    );
    
    wire clk_VGA, locked;
    
    //I2C Config Module
    sccb sccb(.reset(reset),
    .start_sig(start_sig),
    .clk(clk),
    .SIO_C(SCL),
    .SIO_D(SDA));
    
    //Create 25MHx clock signal for VGA 
    clk_wiz_0 clk_wiz_VGA (
    .clk_in1(clk),
    .clk_out1(clk_VGA),
    .reset(reset),
    .locked(locked)
    ); 
    
    
endmodule
