module IbexResultMux(	// <stdin>:182:3
  input  [6:0]  io_operator_i,	// \\src\\main\\scala\\alu\\ibex_result_mux.scala:9:20
  input  [31:0] io_adder_result,	// \\src\\main\\scala\\alu\\ibex_result_mux.scala:9:20
                io_bwlogic_result,	// \\src\\main\\scala\\alu\\ibex_result_mux.scala:9:20
                io_shift_result,	// \\src\\main\\scala\\alu\\ibex_result_mux.scala:9:20
  input         io_cmp_result,	// \\src\\main\\scala\\alu\\ibex_result_mux.scala:9:20
  output [31:0] io_result_o	// \\src\\main\\scala\\alu\\ibex_result_mux.scala:9:20
);

  assign io_result_o =
    io_operator_i == 7'h4
      ? io_bwlogic_result
      : io_operator_i == 7'h0
          ? io_adder_result
          : io_operator_i == 7'hA | io_operator_i == 7'h9
              ? io_shift_result
              : io_operator_i == 7'h1B ? {31'h0, io_cmp_result} : 32'h0;	// <stdin>:182:3, \\src\\main\\scala\\alu\\ibex_result_mux.scala:22:21, :23:32, :25:29, :28:29, :31:29, :34:29, :37:{29,35}
endmodule