module sccb (
    input wire reset, start_sig, 
    input wire clk,
    output wire SIO_C,
    inout wire SIO_D);

//Define state variables 
localparam idle = 4'b000;
localparam start_state = 4'b001;
localparam dev_state = 4'b010;
localparam addr_state = 4'b011;
localparam data_state = 4'b100;
localparam stop_state = 4'b101;
localparam ack_state = 4'b110;
localparam T_state = 4'b111;
localparam Done = 4'b1000;
localparam start2_state = 4'b1001;
    
//local parameters for generating slower clock
reg [9:0] clk_cnt;
reg SIO_C_en, sio_c;

//Internal register for driving data 
reg SIO_D_Out, SIO_D_Out_Reg;
reg SIO_D_In;

//State varaibles
reg [3:0] current_state, next_state;

//Counter Variables 
reg [2:0] bit_cnt;
reg [1:0] data_cnt;
reg [2:0] message_cnt;

reg bit_inc, message_inc, data_inc; 

//Tri-State Buffer - master drives outside of ack  
//assign SIO_D = (current_state !== ack_state) ? SIO_D_Out_Reg : 1'bz; 
//for simulation 
assign SIO_D = (current_state !== ack_state) ? SIO_D_Out_Reg : 1'b0; 

assign SIO_C = sio_c;

//Define device ID 
localparam device_ID = 8'b00100100; //MSB on the right so MSB is sent first - write slave address 0x42 
//Register addresses 
localparam addr0 = 8'b01001000;    //COM7 0x12
localparam addr1 = 8'b01010001;    //RGB444 0x8C
localparam addr2 = 8'b00000100;    //COM15 0x40
//Message data 
localparam data0 = 8'b00000001;    //reset 0x80
localparam data1 = 8'b00100000;    //select RGB 0x04
localparam data2 = 8'b01000000;    //select RGB444 xR GB 0x02 COM15[4] must be high 
localparam data3 = 8'b00001011;    //Full data length and enable RGB444 0xD0


always @(posedge clk) begin 

    //Generate a slower clock for SIO_C 
    if (reset) begin
        clk_cnt <= 0;
        sio_c   <= 1'b1;   // idle on reset
        SIO_D_Out_Reg <= 1'b1;
        current_state <= idle; 
        bit_cnt <= 3'b0;
        message_cnt <= 3'b0;
        data_cnt <= 2'b0;
    end 
    //rising edge of the clock 
    else if (clk_cnt == 10'd512) begin
        clk_cnt <= clk_cnt + 1'b1;
        //update state on rising edge 
        current_state <= next_state;
        //sample SDA input on rising edge 
        SIO_D_In <= SIO_D;
        if (SIO_C_en)
            sio_c <=1;
        if (bit_inc)
            bit_cnt <= bit_cnt + 1'b1;
        if (message_inc)
            message_cnt <= message_cnt + 1'b1;
        if (data_inc) 
            data_cnt <= data_cnt + 1'b1; 
    end
    //falling edge of the clock 
    else if (clk_cnt == 10'd0) begin
        clk_cnt <= clk_cnt + 1'b1;
        //Drive SDA output on falling edge of the clock
        SIO_D_Out_Reg <= SIO_D_Out;
        
        if(SIO_C_en)
            sio_c <= 0;
    end
    else begin
        clk_cnt <= clk_cnt + 1'b1;
    end
    
end


 always @(*) begin 
    case (current_state)
        
        idle: begin
            //bus Idle 
            SIO_D_Out = 1'b1;
            SIO_C_en = 1'b1; 
            
            //Counters are reset to 0 upon reset 
            bit_inc = 1'b0;
            message_inc = 1'b0;
            data_inc = 1'b0; 
            
            //Wait for start signal 
            if (start_sig) 
                next_state = start_state; 
            else 
                next_state = idle; 
            end 
            
         start_state: begin
         
            //hold clock through start condition
            SIO_C_en = 1'b0;
         
            //Start Condition - high to low 
            SIO_D_Out = 1'b0;
            
            //Do not increment couners 
            bit_inc = 1'b0;
            message_inc = 1'b0;
            data_inc = 1'b0;
                
            next_state = start2_state;     
            end
            
          start2_state: begin
         
            //release the clock
            SIO_C_en = 1'b1;
         
            //Start Condition - hold low 
            SIO_D_Out = 1'b0;
            
            //Do not increment couners 
            bit_inc = 1'b0;
            message_inc = 1'b0;
            data_inc = 1'b0;
                
            next_state = dev_state;     
            end
        
        //State for Device ID     
        dev_state: begin
        
            //Enable clk 
            SIO_C_en = 1'b1;
        
            //incrmenet bit counter 
            bit_inc = 1'b1;
            //Do not increment 
            message_inc = 1'b0;
            
            
           //Output correct device_ID bit 
           SIO_D_Out = device_ID[bit_cnt]; 
           
           //Move to next state when counter is at 111 on the rising edge 
           if (bit_cnt == 3'b111) begin
                next_state = ack_state; 
                data_inc = 1'b1;
           end
           else begin
                next_state = dev_state; 
                data_inc = 1'b0;
           end

        end
        
        ack_state: begin
        
            //Enable clk 
            SIO_C_en = 1'b1;
        
            //Do not increment couners 
            bit_inc = 1'b0;
            data_inc = 1'b0;
             message_inc = 1'b0;
            
           //keep low until the falling edge of the next state
           SIO_D_Out = 0; 
           
           //Wait for ACK 
           if (!SIO_D_In) begin

           
                if (data_cnt == 2'b00)
                    next_state = addr_state; 
                else if (data_cnt == 2'b01)
                    next_state = data_state;
                else
                    next_state = stop_state;
           end
           else begin
                next_state = ack_state; 
           end
                  
        end
        
         addr_state: begin
         
            //Enable clk 
            SIO_C_en = 1'b1;
        
            //incrmenet bit counter 
            bit_inc = 1'b1;
            //Do not increment 
            message_inc = 1'b0;
            
           //Output correct address register bit 
           if (message_cnt == 3'd0 || message_cnt == 3'd1)
                SIO_D_Out = addr0[bit_cnt]; 
           else if (message_cnt == 3'd2)
                SIO_D_Out = addr1[bit_cnt];
           else
                SIO_D_Out = addr2[bit_cnt];     
           
           //Move to next state when counter is at 111 on the rising edge 
           if (bit_cnt == 3'b111) begin
                next_state = ack_state; 
                data_inc = 1'b1;
           end
           else begin 
                next_state = addr_state; 
                data_inc = 1'b0;
           end

        end
        
        
        data_state: begin
         
            //Enable clk 
            SIO_C_en = 1'b1;
        
            //incrmenet bit counter 
            bit_inc = 1'b1;
            //Do not increment 
            message_inc = 1'b0;
            data_inc = 1'b0;
            
           //Output correct address register bit 
           if (message_cnt == 3'b0)
                SIO_D_Out = data0[bit_cnt]; 
           else if (message_cnt == 3'b01)
                SIO_D_Out = data1[bit_cnt];
           else if (message_cnt == 3'b10)
                SIO_D_Out = data2[bit_cnt];
           else 
                SIO_D_Out = data3[bit_cnt];
           
           //Move to next state when counter is at 111 on the rising edge 
           if (bit_cnt == 3'b111) begin
                next_state = ack_state; 
                data_inc = 1'b1;
           end
           else begin 
                next_state = data_state; 
                data_inc = 1'b0;
           end

        end
        
        stop_state: begin
         
            //hold clock high through the stop condition 
            SIO_C_en = 1'b0;
            
            //Stop condition - low to high 
            SIO_D_Out = 1'b1;
            
            //Do not increment couners 
            bit_inc = 1'b0;
            data_inc = 1'b0;
            //Incrment message 
            message_inc = 1'b1;
                
            next_state = T_state;     
         end
            
         T_state: begin
            
            //bus Idle 
            SIO_D_Out = 1'b1;
            //Clk enabled 
            SIO_C_en = 1'b1; 
            
            //Do not incrmenet ocunter  
            bit_inc = 1'b0;
            message_inc = 1'b0;
            //Reset data_inc with overflow 
            data_inc = 1'b1; 
             
            if (message_cnt == 3'b11) 
                next_state = Done; 
            else 
                next_state = start_state; 
         end 
            
            
        Done: begin
            
            //bus Idle 
            SIO_D_Out = 1'b1;
            //Clk disabled
            SIO_C_en = 1'b0; 
            
            bit_inc = 1'b0;
            message_inc = 1'b0; 
            data_inc = 1'b0; 

            next_state = Done; 
            
        end 
           
            
     endcase
    
    end 
    
endmodule 




module sccb_tb(); 
    reg reset, start_sig;
    reg clk;
    wire SIO_C;
    wire SIO_D;
    
    sccb SUT(.reset(reset), .start_sig(start_sig), .clk(clk),
    .SIO_C(SIO_C), .SIO_D(SIO_D));
    
    parameter PERIOD = 10; 
    initial clk = 1'b0;
    always #(PERIOD/2) clk = ~clk;

        initial begin 
        reset = 1'b1; start_sig = 1'b0; #PERIOD; 
        reset = 1'b0; start_sig = 1'b1; #10240;
        reset = 1'b0; start_sig = 1'b0; #PERIOD;
                      #5_000_000;
                      
    end 
        
endmodule
