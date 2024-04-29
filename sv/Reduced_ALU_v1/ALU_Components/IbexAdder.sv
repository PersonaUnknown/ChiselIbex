module IbexAdder(	// <stdin>:3:3
  input  [31:0] io_operand_a_i,	// \\src\\main\\scala\\alu\\ibex_adder.scala:7:16
                io_operand_b_i,	// \\src\\main\\scala\\alu\\ibex_adder.scala:7:16
  output [31:0] io_adder_result,	// \\src\\main\\scala\\alu\\ibex_adder.scala:7:16
                io_adder_result_o,	// \\src\\main\\scala\\alu\\ibex_adder.scala:7:16
  output [33:0] io_adder_result_ext_o	// \\src\\main\\scala\\alu\\ibex_adder.scala:7:16
);

  wire [32:0] _io_adder_result_ext_o_T = {io_operand_a_i, 1'h1} + {io_operand_b_i, 1'h0};	// \\src\\main\\scala\\alu\\ibex_adder.scala:18:25, :19:25, :22:51
  assign io_adder_result = _io_adder_result_ext_o_T[32:1];	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_adder.scala:22:51, :23:51
  assign io_adder_result_o = _io_adder_result_ext_o_T[32:1];	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_adder.scala:22:51, :23:51
  assign io_adder_result_ext_o = {1'h0, _io_adder_result_ext_o_T};	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_adder.scala:19:25, :22:{27,51}
endmodule