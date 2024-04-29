// A version of the reduced ALU written using Chisel instead (made from converting components into Chisel)
// ALU
module ibex_alu #(
  parameter ibex_pkg::rv32b_e RV32B = ibex_pkg::RV32BNone
) (
  input  ibex_pkg::alu_op_e operator_i,
  input  logic [31:0]       operand_a_i,
  input  logic [31:0]       operand_b_i,
  input  logic              instr_first_cycle_i,
  input  logic [32:0]       multdiv_operand_a_i,
  input  logic [32:0]       multdiv_operand_b_i,
  input  logic              multdiv_sel_i,
  input  logic [31:0]       imd_val_q_i[2], // Intermediate for multicycle ops
  
  output logic [31:0]       imd_val_d_o[2], // Intermediate for multicycle ops
  output logic [1:0]        imd_val_we_o,   // Intermediate for multicycle ops
  output logic [31:0]       adder_result_o,
  output logic [33:0]       adder_result_ext_o,
  output logic [31:0]       result_o,
  output logic              comparison_result_o,
  output logic              is_equal_result_o
);

  import ibex_pkg::*;
  logic [31:0] operand_a_rev;
  // bit reverse operand_a for left shifts
  for (genvar k = 0; k < 32; k++) begin : gen_rev_operand_a
    assign operand_a_rev[k] = operand_a_i[31-k];
  end

  // CUSTOM
  always_comb begin
    if (multdiv_operand_a_i == 33'b0) begin end
    if (multdiv_operand_b_i == 33'b0) begin end
    if (multdiv_sel_i) begin end
    if (imd_val_q_i == 32'b0) begin end
    assign imd_val_d_o = '{default: '0};
    assign imd_val_we_o = '{default: '0};
  end

  ///////////
  // Adder //
  ///////////
  // CHISEL VERSION (NOTE: Needed to add in the logic and reorder the wire after adder_in_a and adder_in_b is assigned, then needed to substitute them to get _io_adder_result_ext_o_T)
  logic [32:0] adder_in_a, adder_in_b;
  logic [31:0] adder_result;
  assign adder_result = _io_adder_result_ext_o_T[32:1];	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_adder.scala:24:55, :25:55
  assign adder_in_a = {operand_a_i, 1'h1};	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_adder.scala:20:29
  assign adder_in_b = {operand_b_i, 1'h0};	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_adder.scala:21:29
  wire [32:0] _io_adder_result_ext_o_T = adder_in_a + adder_in_b;	// \\src\\main\\scala\\alu\\ibex_adder.scala:20:29, :21:29, :24:55
  assign adder_result_o = _io_adder_result_ext_o_T[32:1];	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_adder.scala:24:55, :25:55
  assign adder_result_ext_o = {1'h0, _io_adder_result_ext_o_T};	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_adder.scala:21:29, :24:{31,55}

  
  ////////////////
  // Comparison //
  ////////////////
  // CHISEL VERSION
  wire is_equal = adder_result == 32'h0;	// \\src\\main\\scala\\alu\\ibex_comparator.scala:56:37
  wire cmp_signed = operator_i == 7'h1B;	// \\src\\main\\scala\\alu\\ibex_comparator.scala:60:47
  wire is_greater_equal =
    operand_a_i[31] ^ ~(operand_b_i[31])
      ? ~(adder_result[31])
      : operand_a_i[31] ^ cmp_signed;	// \\src\\main\\scala\\alu\\ibex_comparator.scala:60:47, :61:{32,48,69,75,99,104,132}
  assign comparison_result_o =
    operator_i == 7'h1E
      ? ~is_equal
      : cmp_signed
          ? is_greater_equal
          : operator_i == 7'h19 | operator_i == 7'h1A
              ? ~is_greater_equal
              : is_equal;	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_comparator.scala:56:37, :60:47, :61:32, :65:{29,50}, :66:{24,27}, :67:56, :68:24, :69:{35,55,72,94}, :70:{24,27}, :72:24
  assign is_equal_result_o = is_equal;	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_comparator.scala:56:37

  ///////////
  // Shift //
  ///////////
  // The shifter structure consists of a 33-bit shifter: 32-bit operand + 1 bit extension for
  // arithmetic shifts and one-shift support.
  // Rotations and funnel shifts are implemented as multi-cycle instructions.
  // The shifter is also used for single-bit instructions and bit-field place as detailed below.
  //
  // Standard Shifts
  // ===============
  // For standard shift instructions, the direction of the shift is to the right by default. For
  // left shifts, the signal shift_left signal is set. If so, the operand is initially reversed,
  // shifted to the right by the specified amount and shifted back again. For arithmetic- and
  // one-shifts the 33rd bit of the shifter operand can is set accordingly.
  // CHISEL
  logic [31:0] shift_result;
  wire [5:0]  _io_shift_amt_compl_T_1 = 6'h20 - {1'h0, operand_b_i[4:0]};	// \\src\\main\\scala\\alu\\ibex_shifter.scala:93:{36,52}, :105:43
  wire [4:0]  _io_shift_amt_T_9 =
    instr_first_cycle_i
      ? (operand_b_i[5] ? _io_shift_amt_compl_T_1[4:0] : operand_b_i[4:0])
      : operand_b_i[5] ? operand_b_i[4:0] : _io_shift_amt_compl_T_1[4:0];	// \\src\\main\\scala\\alu\\ibex_shifter.scala:93:{36,52}, :94:{43,51}, :95:{32,70}, :96:32
  wire _io_shift_left_output = operator_i == 7'hA | operator_i == 7'h2F & (|RV32B) & (operand_b_i[5] ^ instr_first_cycle_i);	// \\src\\main\\scala\\alu\\ibex_shifter.scala:94:43, :102:{29,51}, :103:27, :104:{34,56}, :105:{27,33,43}, :106:32, :108:27
  wire [31:0] _io_shift_operand_output = _io_shift_left_output ? operand_a_rev : operand_a_i;	// \\src\\main\\scala\\alu\\ibex_shifter.scala:102:51, :103:27, :104:56, :114:32
  wire [32:0] _io_shift_result_ext_output = $signed($signed({_io_shift_operand_output[31], _io_shift_operand_output}) >>> _io_shift_amt_T_9);	// \\src\\main\\scala\\alu\\ibex_shifter.scala:94:51, :114:32, :115:{42,75,106}
  wire [7:0]  _GEN = {{_io_shift_result_ext_output[11:8], _io_shift_result_ext_output[15:14]} & 6'h33, 2'h0} | {_io_shift_result_ext_output[15:12], _io_shift_result_ext_output[19:16]} & 8'h33;	// \\src\\main\\scala\\alu\\ibex_shifter.scala:93:36, :115:106, :120:{39,59}
  wire [18:0] _GEN_0 =
    {_io_shift_result_ext_output[5:4],
     _io_shift_result_ext_output[7:6],
     _io_shift_result_ext_output[9:8],
     _GEN,
     _io_shift_result_ext_output[19:18],
     _io_shift_result_ext_output[21:20],
     _io_shift_result_ext_output[23]} & 19'h55555;	// \\src\\main\\scala\\alu\\ibex_shifter.scala:115:106, :120:39
  assign shift_result =
    _io_shift_left_output
      ? {_io_shift_result_ext_output[0],
         _io_shift_result_ext_output[1],
         _io_shift_result_ext_output[2],
         _io_shift_result_ext_output[3],
         _io_shift_result_ext_output[4],
         _GEN_0[18:15]
           | {_io_shift_result_ext_output[7:6], _io_shift_result_ext_output[9:8]} & 4'h5,
         _GEN_0[14:7] | _GEN & 8'h55,
         _GEN[1],
         _GEN_0[5] | _io_shift_result_ext_output[18],
         _io_shift_result_ext_output[19],
         _io_shift_result_ext_output[20],
         {_GEN_0[2:0], 1'h0}
           | {_io_shift_result_ext_output[23:22], _io_shift_result_ext_output[25:24]}
           & 4'h5,
         _io_shift_result_ext_output[25],
         _io_shift_result_ext_output[26],
         _io_shift_result_ext_output[27],
         _io_shift_result_ext_output[28],
         _io_shift_result_ext_output[29],
         _io_shift_result_ext_output[30],
         _io_shift_result_ext_output[31]}
      : _io_shift_result_ext_output[31:0];	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_shifter.scala:102:51, :103:27, :104:56, :105:43, :115:106, :119:30, :120:{29,39}, :122:{29,58}
  // Added manually due to 'unused signals' warning preventing simulator building 
  wire _unused_shift_values = &{1'b0,
           // Put list of unused signals here
           _io_shift_result_ext_output[32], _GEN_0[6], _GEN_0[4:3],
           1'b0};
  
  ///////////////////
  // Bitwise Logic //
  ///////////////////
  // CHISEL VERSION
  logic bwlogic_and;               // NOT CHISEL
  logic [31:0] bwlogic_operand_b;  // NOT CHISEL
  logic [31:0] bwlogic_and_result; // NOT CHISEL
  logic [31:0] bwlogic_result;     // NOT CHISEL
  wire        bwlogic_and_output = operator_i == 7'h4;	// \\src\\main\\scala\\alu\\ibex_bitwise.scala:21:41
  assign bwlogic_and = bwlogic_and_output;	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_bitwise.scala:21:41
  assign bwlogic_operand_b = operand_b_i;	// <stdin>:3:3 
  wire [31:0] bwlogic_and_result_output = operand_a_i & bwlogic_operand_b;	// \\src\\main\\scala\\alu\\ibex_bitwise.scala:20:49 ((NOTE: Needed to reorder this line to after assigning bwlogic_operand_b and edit it to use that instead of operand_b_i)
  assign bwlogic_and_result = bwlogic_and_result_output;	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_bitwise.scala:20:49
  assign bwlogic_result =
    bwlogic_and ? bwlogic_and_result : 32'h0;	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_bitwise.scala:20:49, :21:41, :22:33 (NOTE: Needed to remove the '_output' part of bwlogic_and and bwlogic_and_result)
  
  ////////////////
  // Result mux //
  ////////////////
  // CHISEL VERSION
  assign result_o =
    operator_i == 7'h4
      ? bwlogic_result
      : operator_i == 7'h0
          ? adder_result
          : operator_i == 7'hA | operator_i == 7'h9
              ? shift_result
              : operator_i == 7'h1B ? {31'h0, comparison_result_o} : 32'h0;	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_result_mux.scala:23:21, :24:32, :26:29, :29:29, :32:29, :35:29, :38:{29,35} (NOTE: Needed to replace 'cmp_result' with 'comparison_result_o')
  logic unused_shift_amt_compl; // NOT CHISEL
  assign unused_shift_amt_compl = _io_shift_amt_compl_T_1[5];	// <stdin>:3:3, \\src\\main\\scala\\alu\\ibex_result_mux.scala:41:56
endmodule