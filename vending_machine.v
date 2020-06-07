`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2020 15:47:57
// Design Name: 
// Module Name: vending_machine
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


module vending_machine(
    //clock and reset
    input clk, rst,

    //input signals to fsm
    input insert_bill, purchase,
    input cancel,

    //fsm output signals
    output reg error,
    output reg checking,
    output reg idle,
    output reg dispense,
    output reg refund
);

parameter STATE_IDLE = 4'd0;
parameter STATE_COUNT = 4'd1;
parameter STATE_CHECK = 4'd2;
parameter STATE_ERROR = 4'd3;
parameter STATE_DISPENSE = 4'd4;
parameter STATE_REFUND = 4'd5;
parameter STATE_DONE = 4'd6;

parameter PRICE = 8'd4;

//FSM states
reg [3:0] current_state;
reg [3:0] next_state;

//counter and its control signals
reg [7:0] counter;
reg inc_counter, clear;

//counter's control logic
always @(posedge clk or posedge rst)
begin
    if (rst == 1'b1)
        counter <= 0;
    else if (inc_counter == 1'b1)
        counter <= counter + 1;
    else if (clear == 1'b1)
        counter <= 0;
    else
        counter <= counter;
end

//Synchronous state transition
always @(posedge clk or posedge rst)
begin
    if (rst == 1'b1)
    begin
        current_state = STATE_IDLE;
    end
    else
        current_state <= next_state;
end

//state transition conditions
always @(*)
begin
    next_state = STATE_IDLE;
    case (current_state)
        STATE_IDLE:
        begin
            if (insert_bill == 1'b1)
                next_state = STATE_COUNT;
            else
                next_state = STATE_IDLE;
        end

		STATE_COUNT:
        begin
          if (insert_bill == 1'b1)
          		next_state = STATE_CHECK;
          else if (cancel == 1'b1)
            	next_state = STATE_REFUND;
          else if (purchase == 1'b1)
           		next_state = STATE_DISPENSE;
          else
            	next_state = STATE_IDLE;
        end
      	
      	STATE_CHECK:
        begin
          if (counter < PRICE)
            	next_state = STATE_ERROR;
      	  else 
            	next_state = STATE_DISPENSE;
        end
      
      	STATE_ERROR:
        begin
          next_state = STATE_IDLE;
        end
      	
      	STATE_DISPENSE:
        begin
          if (counter > PRICE)
            	next_state = STATE_REFUND;
          else
            	next_state = STATE_DONE;
        end
      	
      	STATE_REFUND:
        begin
          next_state = STATE_DONE;
        end

        STATE_DONE:
        begin
            next_state = STATE_IDLE;
        end
        default:
        next_state = STATE_IDLE;
    endcase
end

//control signals
always @(*)
begin
    inc_counter = 1'b0;
    clear = 1'b0;
    error = 1'b0;
    dispense = 1'b0;
    refund = 1'b0;
    idle = 1'b0;
    checking = 1'b0;

    case (current_state)
        STATE_IDLE:
        begin
            if (insert_bill == 1'b1)
                inc_counter = 1'b1;
            idle = 1'b1;
        end
        
		STATE_COUNT:
        begin
          if (insert_bill == 1'b1)
            	checking = 1'b1;
          else if (cancel == 1'b1)
            	refund = 1'b1;
          else if (purchase == 1'b1)
            	dispense = 1'b1;
          idle = 1'b1;
        end
      	
      	STATE_CHECK:
        begin
          if (counter < PRICE)
            	error = 1'b1;
          dispense = 1'b1;
        end
      
      	STATE_ERROR:
        begin
          error = 1'b1;
          idle = 1'b1;
        end
      
      	STATE_DISPENSE:
        begin
          if (counter > PRICE)
            	refund = 1'b1;
          dispense = 1'b1;
        end
      
      	STATE_REFUND:
        begin
          refund = 1'b1;
          idle = 1'b1;
        end
      	
        STATE_DONE:
        begin
            clear = 1'b1;
        end
      	
      	default:
      	begin
          inc_counter = 1'b0;
    	  clear = 1'b0;
    	  error = 1'b0;
    	  dispense = 1'b0;
    	  refund = 1'b0;
    	  idle = 1'b0;
    	  checking = 1'b0;
    	end
    endcase
end

endmodule
