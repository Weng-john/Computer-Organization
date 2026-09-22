`include "ALU_1bit.v"
module ALU (
	aluSrc1,
	aluSrc2,
	invertA,
	invertB,
	operation,
	result,
	zero,
	overflow
);

	//I/O ports
	input [32-1:0] aluSrc1;
	input [32-1:0] aluSrc2;
	input invertA;
	input invertB;
	input [2-1:0] operation;

	output [32-1:0] result;
	output zero;
	output overflow;

	//Internal Signals
	wire [32-1:0] result;
	wire zero;
	wire overflow;

	wire [31:0] carry;
	wire set_less;
	wire carryOut;
	wire [31:0] sum;

	// connect each ALU bit
	wire [31:0] a_final, b_final;

	//Main function
	genvar i;
	generate
		for(i=0;i<32;i=i+1) begin: ALU_BITS
			if(i==0) begin
				ALU_1bit alu(
					.a(aluSrc1[i]),
					.b(aluSrc2[i]),
					.invertA(invertA),
					.invertB(invertB),
					.operation(operation),
					.carryIn(invertB),  // For subtraction, initial carry in is 1 (invertB)
					.less(set_less),
					.result(result[i]),
					.carryOut(carry[i]),
					.sum(sum[i])
				);
			end
			else if (i==31) begin
				ALU_1bit alu(
					.a(aluSrc1[i]),
					.b(aluSrc2[i]),
					.invertA(invertA),
					.invertB(invertB),
					.operation(operation),
					.carryIn(carry[i-1]),
					.less(1'b0),
					.result(result[i]),
					.carryOut(carryOut),
					.sum(set_less)
				);
			end
			else begin
				ALU_1bit alu(
					.a(aluSrc1[i]),
					.b(aluSrc2[i]),
					.invertA(invertA),
					.invertB(invertB),
					.operation(operation),
					.carryIn(carry[i-1]),
					.less(1'b0),
					.result(result[i]),
					.carryOut(carry[i]),
					.sum(sum[i])
				);
			end
		end
	endgenerate

	// detect overflow
	assign overflow = (operation == 2'b11) && (
	(invertB == 1'b0 && aluSrc1[31] == aluSrc2[31] && aluSrc1[31] != result[31]) || // Addition
	(invertB == 1'b1 && aluSrc1[31] != aluSrc2[31] && aluSrc1[31] != result[31])   // Subtraction
	);

	// zero flag
	assign zero= (result == 32'b0);

endmodule
