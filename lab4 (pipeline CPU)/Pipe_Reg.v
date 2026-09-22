module Pipe_Reg (
  clk_i,
  rst_n,
  data_i,
  data_o
);

  parameter integer size = 64;

  //I/O ports
  input clk_i;
  input rst_n;
  input [size-1:0] data_i;

  output [size-1:0] data_o;

  //Internal Signals
  reg [size-1:0] data_o;

  //Main function
  always @(posedge clk_i or negedge rst_n) begin
    if (~rst_n)
      data_o <= 0;  // Reset the output data to 0 when reset is active
    else
      data_o <= data_i;  // Transfer the input data to the output on the rising edge of the clock
  end

endmodule
