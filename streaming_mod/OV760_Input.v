`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2026 11:27:20 AM
// Design Name: 
// Module Name: OV7670_Input
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


module OV7670_Input(
    input wire PCLK,HREF, VSYNC, reset,
    input wire [7:0] data,
    output reg [9:0] x_idx, y_idx,
    output reg [3:0] R_data, G_data, B_data,
    output reg write_en
    );
    
    wire HREF_falling;
    reg byte_cnt, last_HREF;
    reg [9:0] next_x_idx;
    
    assign HREF_falling = ((last_HREF == 1'b1) && (HREF == 1'b0));
    
    always @(posedge PCLK) begin
    
        last_HREF <= HREF;
        
        if (reset == 1'b1) begin 
            x_idx <= 10'b0;
            y_idx <= 10'b0; 
            byte_cnt <= 1'b0;
            write_en <= 1'b0;
            R_data <= 4'b0;
            G_data <= 4'b0;
            B_data <= 4'b0;
            
        end 
        else if (VSYNC == 1'b1) begin 
            x_idx <= 10'b0;
            next_x_idx <= 10'b0;
            y_idx <= 10'b0; 
            byte_cnt <= 1'b0;
            write_en <= 1'b0;
            R_data <= 4'b0;
            G_data <= 4'b0;
            B_data <= 4'b0;
        end    
        //start of new row 
        else if (HREF_falling == 1'b1) begin 
            x_idx <= 10'b0;
            next_x_idx <= 10'b0;
            y_idx <= y_idx + 1'b1; 
            byte_cnt = 1'b0;
            write_en <= 1'b0;
        end
        //active pixels
        else if (HREF == 1'b1) begin 
            //byte 1 
            if (byte_cnt == 1'b0) begin 
                R_data <= data[3:0];
                write_en <= 1'b0;
                x_idx <= next_x_idx; 
            end
            //byte 2 
            else begin
                G_data <= data[7:4];
                B_data <= data[3:0];
                write_en <= 1'b1;
                next_x_idx <= next_x_idx +1'b1;
            end
            byte_cnt <= byte_cnt + 1'b1;
        end
        
    end 
    
endmodule

module OV7670Input_tb ();
    reg PCLK,HREF, VSYNC, reset;
    reg [7:0] data;
    wire [9:0] x_idx, y_idx;
    wire [3:0] R_data, G_data, B_data;
    wire write_en;
    
    OV7670_Input SUT(.PCLK(PCLK), .HREF(HREF), .VSYNC(VSYNC), .reset(reset),
    .data(data), .x_idx(x_idx), .y_idx(y_idx), .R_data(R_data),
    .G_data(G_data), .B_data(B_data), .write_en(write_en));
    
    parameter PERIOD = 10; 
    initial PCLK = 1'b0;
    always #(PERIOD/2) PCLK = ~PCLK;

        initial begin 
        reset = 1'b0; VSYNC = 1'b1; HREF = 1'b1; data = 8'b0; #PERIOD; 
        reset = 1'b0; VSYNC = 1'b0; HREF = 1'b1; data = 8'b10001111; #PERIOD; 
        reset = 1'b0; VSYNC = 1'b0; HREF = 1'b1; data = 8'b00110101; #PERIOD; 
                                                                     #12790;
        reset = 1'b0; VSYNC = 1'b0; HREF = 1'b0; data = 8'b11111111; #PERIOD;
        reset = 1'b0; VSYNC = 1'b0; HREF = 1'b0; data = 8'b10101010; #PERIOD;       
                      
    end 
    
endmodule
