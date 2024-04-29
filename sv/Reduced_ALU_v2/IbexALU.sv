// Generated by CIRCT firtool-1.56.1
module IbexShifter(	// <stdin>:85:3
  input  [6:0]  operator_i,	// \\src\\main\\scala\\alu\\ibex_shifter.scala:8:16
  input  [31:0] operand_a_i,	// \\src\\main\\scala\\alu\\ibex_shifter.scala:8:16
                operand_b_i,	// \\src\\main\\scala\\alu\\ibex_shifter.scala:8:16
                operand_a_rev,	// \\src\\main\\scala\\alu\\ibex_shifter.scala:8:16
  input         instr_first_cycle_i,	// \\src\\main\\scala\\alu\\ibex_shifter.scala:8:16
  output [31:0] shift_result	// \\src\\main\\scala\\alu\\ibex_shifter.scala:8:16
);

  wire        _GEN = operator_i == 7'hA;	// \\src\\main\\scala\\alu\\ibex_shifter.scala:41:25
  wire [31:0] _shift_operand_T = _GEN ? operand_a_rev : operand_a_i;	// \\src\\main\\scala\\alu\\ibex_shifter.scala:41:25, :58:28
  wire [32:0] _shift_result_ext_signed_T_6 =
    $signed($signed({operator_i == 7'h8 & _shift_operand_T[31],
                     _shift_operand_T})
            >>> (instr_first_cycle_i
                   ? operand_b_i[4:0]
                   : 5'h0 - operand_b_i[4:0]));	// \\src\\main\\scala\\alu\\ibex_shifter.scala:34:{32,48}, :35:65, :48:37, :58:28, :59:{38,71,89,121}
  wire [7:0]  _GEN_0 =
    {{_shift_result_ext_signed_T_6[11:8], _shift_result_ext_signed_T_6[15:14]}
       & 6'h33,
     2'h0}
    | {_shift_result_ext_signed_T_6[15:12], _shift_result_ext_signed_T_6[19:16]}
    & 8'h33;	// \\src\\main\\scala\\alu\\ibex_shifter.scala:59:121, :61:43, :65:35
  wire [18:0] _GEN_1 =
    {_shift_result_ext_signed_T_6[5:4],
     _shift_result_ext_signed_T_6[7:6],
     _shift_result_ext_signed_T_6[9:8],
     _GEN_0,
     _shift_result_ext_signed_T_6[19:18],
     _shift_result_ext_signed_T_6[21:20],
     _shift_result_ext_signed_T_6[23]} & 19'h55555;	// \\src\\main\\scala\\alu\\ibex_shifter.scala:59:121, :65:35
  assign shift_result =
    _GEN
      ? {_shift_result_ext_signed_T_6[0],
         _shift_result_ext_signed_T_6[1],
         _shift_result_ext_signed_T_6[2],
         _shift_result_ext_signed_T_6[3],
         _shift_result_ext_signed_T_6[4],
         _GEN_1[18:15]
           | {_shift_result_ext_signed_T_6[7:6], _shift_result_ext_signed_T_6[9:8]}
           & 4'h5,
         _GEN_1[14:7] | _GEN_0 & 8'h55,
         _GEN_0[1],
         _GEN_1[5] | _shift_result_ext_signed_T_6[18],
         _shift_result_ext_signed_T_6[19],
         _shift_result_ext_signed_T_6[20],
         {_GEN_1[2:0], 1'h0}
           | {_shift_result_ext_signed_T_6[23:22],
              _shift_result_ext_signed_T_6[25:24]} & 4'h5,
         _shift_result_ext_signed_T_6[25],
         _shift_result_ext_signed_T_6[26],
         _shift_result_ext_signed_T_6[27],
         _shift_result_ext_signed_T_6[28],
         _shift_result_ext_signed_T_6[29],
         _shift_result_ext_signed_T_6[30],
         _shift_result_ext_signed_T_6[31]}
      : _shift_result_ext_signed_T_6[31:0];	// <stdin>:85:3, \\src\\main\\scala\\alu\\ibex_shifter.scala:41:25, :59:121, :64:26, :65:{25,35}, :67:{25,54}
endmodule

module IbexBitwise(	// <stdin>:211:3
  input  [6:0]  operator_i,	// \\src\\main\\scala\\alu\\ibex_bitwise.scala:6:20
  input  [31:0] operand_a_i,	// \\src\\main\\scala\\alu\\ibex_bitwise.scala:6:20
                operand_b_i,	// \\src\\main\\scala\\alu\\ibex_bitwise.scala:6:20
  output [31:0] bwlogic_result	// \\src\\main\\scala\\alu\\ibex_bitwise.scala:6:20
);

  assign bwlogic_result =
    operator_i == 7'h3 | operator_i == 7'h6
      ? operand_a_i | operand_b_i
      : operator_i == 7'h4 | operator_i == 7'h7
          ? operand_a_i & operand_b_i
          : operand_a_i ^ operand_b_i;	// <stdin>:211:3, \\src\\main\\scala\\alu\\ibex_bitwise.scala:22:49, :23:49, :24:49, :25:{41,62,78}, :26:{41,62,78}, :27:30, :28:31, :29:36, :30:31, :32:31
endmodule

module IbexResultMux(	// <stdin>:240:3
  input  [6:0]  operator_i,	// \\src\\main\\scala\\alu\\ibex_result_mux.scala:9:20
  input  [31:0] adder_result,	// \\src\\main\\scala\\alu\\ibex_result_mux.scala:9:20
                bwlogic_result,	// \\src\\main\\scala\\alu\\ibex_result_mux.scala:9:20
                shift_result,	// \\src\\main\\scala\\alu\\ibex_result_mux.scala:9:20
  input         cmp_result,	// \\src\\main\\scala\\alu\\ibex_result_mux.scala:9:20
  output [31:0] result_o	// \\src\\main\\scala\\alu\\ibex_result_mux.scala:9:20
);

  assign result_o =
    operator_i == 7'h4 | operator_i == 7'h2 | operator_i == 7'h3
      ? bwlogic_result
      : operator_i == 7'h0 | operator_i == 7'h1
          ? adder_result
          : operator_i == 7'hA | operator_i == 7'h9 | operator_i == 7'h8
              ? shift_result
              : operator_i == 7'h1D | operator_i == 7'h1E | operator_i == 7'h1B
                | operator_i == 7'h1C | operator_i == 7'h19 | operator_i == 7'h1A
                | operator_i == 7'h2B | operator_i == 7'h2C
                  ? {31'h0, cmp_result}
                  : 32'h0;	// <stdin>:240:3, \\src\\main\\scala\\alu\\ibex_result_mux.scala:22:21, :23:{29,67,88,105,126}, :24:29, :25:{35,56,73,95}, :26:25, :27:{34,72,93,110,132}, :28:25, :29:{34,71}, :30:{34,71}, :31:{34,71}, :32:{34,55,72}, :33:9, :34:{25,31}
endmodule

module IbexALU(	// <stdin>:289:3
  input         clock,	// <stdin>:290:11
                reset,	// <stdin>:291:11
  input  [6:0]  operator_i,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  input  [31:0] operand_a_i,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
                operand_b_i,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  input         instr_first_cycle_i,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  input  [32:0] multdiv_operand_a_i,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
                multdiv_operand_b_i,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  input         multdiv_sel_i,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  input  [31:0] imd_val_q_i_0,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
                imd_val_q_i_1,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  output [31:0] imd_val_d_o_0,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
                imd_val_d_o_1,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  output [1:0]  imd_val_we_o,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  output [31:0] adder_result_o,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  output [33:0] adder_result_ext_o,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  output [31:0] result_o,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
  output        comparison_result_o,	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
                is_equal_result_o	// \\src\\main\\scala\\alu\\ibex_alu.scala:9:20
);

  wire [31:0] _alu_bitwise_bwlogic_result;	// \\src\\main\\scala\\alu\\ibex_alu.scala:79:33
  wire [31:0] _alu_shifter_shift_result;	// \\src\\main\\scala\\alu\\ibex_alu.scala:67:33
  wire        _alu_comparator_comparison_result_o;	// \\src\\main\\scala\\alu\\ibex_alu.scala:55:36
  wire [31:0] _alu_adder_adder_result;	// \\src\\main\\scala\\alu\\ibex_alu.scala:44:31
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
    .operator_i         (operator_i),
    .operand_a_i        (operand_a_i),
    .operand_b_i        (operand_b_i),
    .adder_result       (_alu_adder_adder_result),
    .adder_result_o     (adder_result_o),
    .adder_result_ext_o (adder_result_ext_o)
  );
  IbexComparator alu_comparator (	// \\src\\main\\scala\\alu\\ibex_alu.scala:55:36
    .operator_i          (operator_i),
    .operand_a_i         (operand_a_i),
    .operand_b_i         (operand_b_i),
    .adder_result        (_alu_adder_adder_result),	// \\src\\main\\scala\\alu\\ibex_alu.scala:44:31
    .comparison_result_o (_alu_comparator_comparison_result_o),
    .is_equal_result_o   (is_equal_result_o)
  );
  IbexShifter alu_shifter (	// \\src\\main\\scala\\alu\\ibex_alu.scala:67:33
    .operator_i          (operator_i),
    .operand_a_i         (operand_a_i),
    .operand_b_i         (operand_b_i),
    .operand_a_rev
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
    .instr_first_cycle_i (instr_first_cycle_i),
    .shift_result        (_alu_shifter_shift_result)
  );
  IbexBitwise alu_bitwise (	// \\src\\main\\scala\\alu\\ibex_alu.scala:79:33
    .operator_i     (operator_i),
    .operand_a_i    (operand_a_i),
    .operand_b_i    (operand_b_i),
    .bwlogic_result (_alu_bitwise_bwlogic_result)
  );
  IbexResultMux alu_result_mux (	// \\src\\main\\scala\\alu\\ibex_alu.scala:88:36
    .operator_i     (operator_i),
    .adder_result   (_alu_adder_adder_result),	// \\src\\main\\scala\\alu\\ibex_alu.scala:44:31
    .bwlogic_result (_alu_bitwise_bwlogic_result),	// \\src\\main\\scala\\alu\\ibex_alu.scala:79:33
    .shift_result   (_alu_shifter_shift_result),	// \\src\\main\\scala\\alu\\ibex_alu.scala:67:33
    .cmp_result     (_alu_comparator_comparison_result_o),	// \\src\\main\\scala\\alu\\ibex_alu.scala:55:36
    .result_o       (result_o)
  );
  assign imd_val_d_o_0 = 32'h0;	// <stdin>:289:3, \\src\\main\\scala\\alu\\ibex_alu.scala:38:34
  assign imd_val_d_o_1 = 32'h0;	// <stdin>:289:3, \\src\\main\\scala\\alu\\ibex_alu.scala:38:34
  assign imd_val_we_o = 2'h0;	// <stdin>:289:3, \\src\\main\\scala\\alu\\ibex_alu.scala:39:25
  assign comparison_result_o = _alu_comparator_comparison_result_o;	// <stdin>:289:3, \\src\\main\\scala\\alu\\ibex_alu.scala:55:36
endmodule