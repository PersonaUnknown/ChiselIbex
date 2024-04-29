module IbexBitwise(	// <stdin>:169:3
  input  [6:0]  io_operator_i,	// \\src\\main\\scala\\alu\\ibex_bitwise.scala:6:20
  input  [31:0] io_operand_a_i,	// \\src\\main\\scala\\alu\\ibex_bitwise.scala:6:20
                io_operand_b_i,	// \\src\\main\\scala\\alu\\ibex_bitwise.scala:6:20
  output [31:0] io_bwlogic_result	// \\src\\main\\scala\\alu\\ibex_bitwise.scala:6:20
);

  assign io_bwlogic_result =
    io_operator_i == 7'h4 ? io_operand_a_i & io_operand_b_i : 32'h0;	// <stdin>:169:3, \\src\\main\\scala\\alu\\ibex_bitwise.scala:19:49, :20:41, :21:33
endmodule