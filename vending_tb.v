`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2020 17:33:01
// Design Name: 
// Module Name: vending_tb
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


module vending_tb();

//clock and reser
reg clk, rst;

//signals to fsm
reg insert_bill, purchase, cancel;

//signals from fsm
wire error, checking, idle, dispense, refund;


vending_machine dut (
    .clk(clk), 
    .rst(rst),

    .insert_bill(insert_bill), 
    .purchase(purchase),
    .cancel(cancel),

    .error(error),
    .checking(checking),
    .idle(idle),
    .dispense(dispense),
    .refund(refund)
);


always
	#5 clk = ~clk;

initial
begin
    clk = 1'b0;
    rst = 1'b0;
    insert_bill = 1'b0;
    purchase = 1'b0;
    cancel = 1'b0;
    #5 rst = 1'b1;
    #10 rst = 1'b0;
    
    //insert 1 bil
    #20 insert_bill = 1'b1;
    #10 insert_bill = 1'b0;

    //press purchase, FSM should transit to STATE_CHECKING
        purchase = 1'b1;
    //now FSM should be in STATE_CHECKING
    #10 purchase = 1'b0;
    //now FSM transits to STATE_ERROR, and error signal should be asserted
    #10 ;
    //insert three bills
    #10 insert_bill = 1'b1;
    //Now, four bills have been inserted, we can purchase
    #30 insert_bill = 1'b0;
        purchase = 1'b1;
    //FSM goes into STATE_CHECK, checking signal should be asserted
    #10 purchase = 1'b0;
    //FSM goes into STATE_DISPENSE, signal dispense should be asserted
    #10 ;
    //FSM goes into STATE_DONE, counter is cleared
    #10 ;
    //FSM goes into STATE_IDLE, idle signal should be asserted
    #10 ;
    //insert 5 bills
    #10 insert_bill = 1'b1;
    #50 insert_bill = 1'b0;
    //purchase
    #10 purchase = 1'b1;
    //FSM goes to STATE_CHECKING, checking signal should be asserted
    #10 purchase = 1'b0;
    //FSM goes to STATE_DISPENSE, signal dispense should be asserted
    #10 ;
    //FSM goes to STATE_REFUND, signal refund should be asserted
    #10 ;
    //FSM goes to STATE_DONE, counter is cleared
    #10 ;
    //FSM goes to STATE_IDLE, idle signal should be asserted
    #10 $display("simulation finished: %d",dataOut);

end



wire[11:0] dataIn;
reg[11:0] dataOut;
reg[11:0] misr_temp;

assign dataIn = dut.current_state ^ dut.next_state ^ {error, checking, idle, dispense};

always@(posedge clk or posedge rst)
begin
	if(rst==1)
	begin
		dataOut <= 12'd0;
		misr_temp <= 12'd0;
	end
	else 
	begin 
		misr_temp<=dataOut;
        dataOut[0]<=misr_temp[3]^dataIn[0];
        dataOut[1]<=misr_temp[3]^dataIn[1];
        dataOut[2]<=misr_temp[1]^dataIn[2];
        dataOut[3]<=misr_temp[2]^dataIn[3];
        dataOut[4]<=misr_temp[3]^dataIn[4]^misr_temp[0];
        dataOut[5]<=misr_temp[4]^dataIn[5];
        dataOut[6]<=misr_temp[5]^dataIn[6];
        dataOut[7]<=misr_temp[6]^dataIn[7];
        dataOut[8]<=misr_temp[7]^dataIn[8];
        dataOut[9]<=misr_temp[8]^dataIn[9]^misr_temp[0];
        dataOut[10]<=misr_temp[9]^dataIn[10]^misr_temp[0];
        dataOut[11]<=misr_temp[10]^dataIn[11]^misr_temp[0];
	end
end


endmodule
