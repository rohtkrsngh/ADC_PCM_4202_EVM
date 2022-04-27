`timescale 1ns / 1ps


module adc_slave_controller(i_serial_data,i_bck,i_lrck,o_left_sample,o_right_sample,index

,o_scaled_left,o_scaled_right

    );

    //input signals to the adc
    input i_serial_data,i_bck,i_lrck;
    output reg [23:0]o_left_sample,o_right_sample;
    

    //state machine parameters
    reg [1:0]sm_main;
    parameter s_left_temp = 2'b00;      //initial invalid state of the receiver
    parameter s_left_valid = 2'b01;     //valid left state
    parameter s_right_temp = 2'b10;     //initial invalid state of the receiver
    parameter s_right_valid = 2'b11;    //valid right state

    //output registers to hold the scaled outputs
    output reg [31:0]o_scaled_left = 0;
    output reg [31:0]o_scaled_right = 0;

    //register to hold the index of the serial data
    output reg [4:0] index=0;
    
    //temporary registers to hold the serial data
    reg [24:0]temp_data_left=0;
    reg [24:0]temp_data_right=0;

    always@(negedge i_bck)
     begin
         case(sm_main)
            s_left_temp : begin //check if the channel line is low
                if(i_lrck == 1'b0)  begin
                    sm_main <= s_left_temp;
                    
                end

                else begin //channel line goes high for the first time
                    sm_main <= s_right_valid;
                    
                    index <= 24;
                end

            end //end of state s_left_temp

            s_right_temp : begin //check if the channel line is high
                if(i_lrck == 1'b1)  begin
                    sm_main <= s_right_temp;
                    
                end

                else begin //channel line goes low for the first time
                    sm_main <= s_left_valid;
                    
                    index <= 24;
                end

            end //end of state s_right_temp

            s_left_valid : begin
                if(i_lrck == 1'b0) begin//continously check if the channel line is low
                    if((index<25)&&(index>=0)) begin //check if index is proper
                        temp_data_left[index] <= i_serial_data;
                        index <= index - 1;
                        sm_main <= s_left_valid;
                    end

                    else begin  //if index goes out of the range
                        //index <= index;
                        sm_main <= s_left_valid;
                        o_left_sample <= temp_data_left[23:0];
                        o_scaled_left <= ((temp_data_left[23:0] + 2136)/830026);
                    end 

                end

                else begin  // if channel line goes high, change state to s_right_valid
                    index <= 24;
                    sm_main <= s_right_valid;
                end

            end // end of state s_left_valid

             s_right_valid : begin
                if(i_lrck == 1'b1) begin//continously check if the channel line is high
                    if((index<25)&&(index>=0)) begin //check if index is proper
                        temp_data_right[index] <= i_serial_data;
                        index <= index - 1;
                        sm_main <= s_right_valid;
                    end

                    else begin  //if index goes out of the range
                        //index <= index;
                        sm_main <= s_right_valid;
                        o_right_sample <= temp_data_right[23:0];
                        o_scaled_right <= ((temp_data_right[23:0] + 2136)/830026);
                    end 

                end

                else begin  // if channel line goes high, change state to s_right_valid
                    index <= 24;
                    sm_main <= s_left_valid;
                end

            end // end of state s_right_valid

            default : begin
                if(i_lrck == 1'b0) begin
                    sm_main <= s_left_temp;
                    
                end
                else begin
                    sm_main <= s_right_temp;
                    
                end
            end // end of default case

         endcase

     end

    
    
endmodule
