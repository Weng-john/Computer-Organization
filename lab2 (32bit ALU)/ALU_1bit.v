`include "Full_adder.v"
module ALU_1bit (
	a,
	b,
	invertA,
	invertB,
	operation,
	carryIn,
	less,
	result,
	carryOut,
	sum
);

	//I/O ports
	input a;
	input b;
	input invertA;
	input invertB;
	input [2-1:0] operation;
	input carryIn;
	input less;

	output reg result;
	output wire carryOut;
	output wire sum;

	//Internal Signals
	wire a_final, b_final;
	wire sum_internal, and_result, or_result;

	//Main function
	// process input signal
	assign a_final= invertA ? ~a:a;
	assign b_final= invertB ? ~b:b;

	// Full_adder
	Full_adder FA(
		.carryIn(carryIn),
		.input1(a_final),
		.input2(b_final),
		.sum(sum_internal),
		.carryOut(carryOut)
	);

	// logical operation
	assign and_result= a_final & b_final;
	assign or_result= a_final | b_final;
	
	assign sum= sum_internal;
	
	// base on operated code select result
	always @(*) begin
		case (operation)
			2'b00: result= and_result;	// AND
			2'b10: result= or_result;	// OR
			2'b11: result= sum;		// sub and add
			2'b01: result= less;		// slt
			default: result= 0;
		endcase
	end
endmodule
