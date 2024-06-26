module ibex_alu #(
  parameter ibex_pkg::rv32b_e RV32B = ibex_pkg::RV32BNone
) (
  input  [6:0]  operator_i,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  input  [31:0] operand_a_i,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
                operand_b_i,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  input         instr_first_cycle_i,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  input  [32:0] multdiv_operand_a_i,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
                multdiv_operand_b_i,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  input         multdiv_sel_i,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  input  logic [31:0] imd_val_q_i[2],	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  output logic [31:0] imd_val_d_o[2],	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  output [1:0]  imd_val_we_o,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  output [31:0] adder_result_o,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  output [33:0] adder_result_ext_o,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  output [31:0] result_o,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  output        comparison_result_o,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
                is_equal_result_o	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
);

  wire [31:0] _alu_bitwise_io_bwlogic_result;	// \\src\\main\\scala\\alu\\ibex_alu.scala:78:33
  wire [31:0] _alu_shifter_io_shift_result;	// \\src\\main\\scala\\alu\\ibex_alu.scala:66:33
  wire        _alu_comparator_io_comparison_result_o;	// \\src\\main\\scala\\alu\\ibex_alu.scala:54:36
  wire [31:0] _alu_adder_io_adder_result;	// \\src\\main\\scala\\alu\\ibex_alu.scala:44:31
  wire [7:0]  _GEN =
    {{operand_a_i[11:8], operand_a_i[15:14]} & 6'h33, 2'h0}
    | {operand_a_i[15:12], operand_a_i[19:16]} & 8'h33;	// \\src\\main\\scala\\alu\\ibex_alu.scala:32:33, :39:25
  wire [18:0] _GEN_0 =
    {operand_a_i[5:4],
     operand_a_i[7:6],
     operand_a_i[9:8],
     _GEN,
     operand_a_i[19:18],
     operand_a_i[21:20],
     operand_a_i[23]} & 19'h55555;	// \\src\\main\\scala\\alu\\ibex_alu.scala:32:33
  IbexAdder alu_adder (	// \\src\\main\\scala\\alu\\ibex_alu.scala:44:31
    .io_operand_a_i        (operand_a_i),
    .io_operand_b_i        (operand_b_i),
    .io_adder_result       (_alu_adder_io_adder_result),
    .io_adder_result_o     (adder_result_o),
    .io_adder_result_ext_o (adder_result_ext_o)
  );
  IbexComparator alu_comparator (	// \\src\\main\\scala\\alu\\ibex_alu.scala:54:36
    .io_operator_i          (operator_i),
    .io_operand_a_i         (operand_a_i),
    .io_operand_b_i         (operand_b_i),
    .io_adder_result        (_alu_adder_io_adder_result),	// \\src\\main\\scala\\alu\\ibex_alu.scala:44:31
    .io_comparison_result_o (_alu_comparator_io_comparison_result_o),
    .io_is_equal_result_o   (is_equal_result_o)
  );
  IbexShifter alu_shifter (	// \\src\\main\\scala\\alu\\ibex_alu.scala:66:33
    .io_operator_i          (operator_i),
    .io_operand_a_i         (operand_a_i),
    .io_operand_b_i         (operand_b_i),
    .io_operand_a_rev
      ({operand_a_i[0],
        operand_a_i[1],
        operand_a_i[2],
        operand_a_i[3],
        operand_a_i[4],
        _GEN_0[18:15] | {operand_a_i[7:6], operand_a_i[9:8]} & 4'h5,
        _GEN_0[14:7] | _GEN & 8'h55,
        _GEN[1],
        _GEN_0[5] | operand_a_i[18],
        operand_a_i[19],
        operand_a_i[20],
        {_GEN_0[2:0], 1'h0} | {operand_a_i[23:22], operand_a_i[25:24]} & 4'h5,
        operand_a_i[25],
        operand_a_i[26],
        operand_a_i[27],
        operand_a_i[28],
        operand_a_i[29],
        operand_a_i[30],
        operand_a_i[31]}),	// \\src\\main\\scala\\alu\\ibex_alu.scala:32:33
    .io_instr_first_cycle_i (instr_first_cycle_i),
    .io_shift_result        (_alu_shifter_io_shift_result)
  );
  IbexBitwise alu_bitwise (	// \\src\\main\\scala\\alu\\ibex_alu.scala:78:33
    .io_operator_i     (operator_i),
    .io_operand_a_i    (operand_a_i),
    .io_operand_b_i    (operand_b_i),
    .io_bwlogic_result (_alu_bitwise_io_bwlogic_result)
  );
  IbexResultMux alu_result_mux (	// \\src\\main\\scala\\alu\\ibex_alu.scala:87:36
    .io_operator_i     (operator_i),
    .io_adder_result   (_alu_adder_io_adder_result),	// \\src\\main\\scala\\alu\\ibex_alu.scala:44:31
    .io_bwlogic_result (_alu_bitwise_io_bwlogic_result),	// \\src\\main\\scala\\alu\\ibex_alu.scala:78:33
    .io_shift_result   (_alu_shifter_io_shift_result),	// \\src\\main\\scala\\alu\\ibex_alu.scala:66:33
    .io_cmp_result     (_alu_comparator_io_comparison_result_o),	// \\src\\main\\scala\\alu\\ibex_alu.scala:54:36
    .io_result_o       (result_o)
  );
  
  always_comb begin
    // The commented out parts were generated by Chisel but create an error
    //assign imd_val_d_o = 32'h0;	// <stdin>:221:3, \\src\\main\\scala\\alu\\ibex_alu.scala:38:25
    //assign imd_val_we_o = 2'h0;	// <stdin>:221:3, \\src\\main\\scala\\alu\\ibex_alu.scala:39:25
    assign imd_val_d_o = '{default: '0};
    assign imd_val_we_o = '{default: '0};
  end
  assign comparison_result_o = _alu_comparator_io_comparison_result_o;	// <stdin>:221:3, \\src\\main\\scala\\alu\\ibex_alu.scala:54:36
  
  ////////////////////
  // ADDED MANUALLY //
  // TO REMOVE ALL  //
  // UNUSED SIGNALS //
  import ibex_pkg::*;
  always_comb begin
    if (multdiv_operand_a_i == 33'b0) begin end
    if (multdiv_operand_b_i == 33'b0) begin end
    if (multdiv_sel_i) begin end
    if (imd_val_q_i == 32'b0) begin end
    if (RV32B == RV32BNone) begin end
    if ({_GEN_0[6], _GEN_0[4:3]} == 3'b0) begin end
  end
  ////////////////////
endmodule

