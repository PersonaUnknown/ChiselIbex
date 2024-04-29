module IbexComparator(	// <stdin>:19:3
  input  [6:0]  io_operator_i,	// \\src\\main\\scala\\alu\\ibex_comparator.scala:6:16
  input  [31:0] io_operand_a_i,	// \\src\\main\\scala\\alu\\ibex_comparator.scala:6:16
                io_operand_b_i,	// \\src\\main\\scala\\alu\\ibex_comparator.scala:6:16
                io_adder_result,	// \\src\\main\\scala\\alu\\ibex_comparator.scala:6:16
  output        io_comparison_result_o,	// \\src\\main\\scala\\alu\\ibex_comparator.scala:6:16
                io_is_equal_result_o	// \\src\\main\\scala\\alu\\ibex_comparator.scala:6:16
);

  wire is_equal = io_adder_result == 32'h0;	// \\src\\main\\scala\\alu\\ibex_comparator.scala:19:33
  wire cmp_signed = io_operator_i == 7'h1B;	// \\src\\main\\scala\\alu\\ibex_comparator.scala:23:43
  wire is_greater_equal =
    io_operand_a_i[31] ^ ~(io_operand_b_i[31])
      ? ~(io_adder_result[31])
      : io_operand_a_i[31] ^ cmp_signed;	// \\src\\main\\scala\\alu\\ibex_comparator.scala:23:43, :24:{28,44,65,71,95,100,128}
  assign io_comparison_result_o =
    io_operator_i == 7'h1E
      ? ~is_equal
      : cmp_signed
          ? is_greater_equal
          : io_operator_i == 7'h19 | io_operator_i == 7'h1A
              ? ~is_greater_equal
              : is_equal;	// <stdin>:19:3, \\src\\main\\scala\\alu\\ibex_comparator.scala:19:33, :23:43, :24:28, :28:{25,46}, :29:{20,23}, :30:52, :31:20, :32:{31,51,68,90}, :33:{20,23}, :35:20
  assign io_is_equal_result_o = is_equal;	// <stdin>:19:3, \\src\\main\\scala\\alu\\ibex_comparator.scala:19:33
  
  ////////////////////
  // ADDED MANUALLY //
  // TO REMOVE ALL  //
  // UNUSED SIGNALS //
  always_comb begin
    if (io_operand_a_i[30:0] == 31'b0) begin end
    if (io_operand_b_i[30:0] == 31'b0) begin end
  end
  ////////////////////
endmodule