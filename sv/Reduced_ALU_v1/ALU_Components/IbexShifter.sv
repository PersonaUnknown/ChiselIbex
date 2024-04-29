module IbexShifter(	// <stdin>:63:3
  input  [6:0]  io_operator_i,	// \\src\\main\\scala\\alu\\ibex_shifter.scala:8:16
  input  [31:0] io_operand_a_i,	// \\src\\main\\scala\\alu\\ibex_shifter.scala:8:16
                io_operand_b_i,	// \\src\\main\\scala\\alu\\ibex_shifter.scala:8:16
                io_operand_a_rev,	// \\src\\main\\scala\\alu\\ibex_shifter.scala:8:16
  input         io_instr_first_cycle_i,	// \\src\\main\\scala\\alu\\ibex_shifter.scala:8:16
  output [31:0] io_shift_result	// \\src\\main\\scala\\alu\\ibex_shifter.scala:8:16
);

  wire [4:0]  _io_shift_amt_compl_T_1 = 5'h0 - io_operand_b_i[4:0];	// \\src\\main\\scala\\alu\\ibex_shifter.scala:33:{32,48}
  wire        _GEN = io_operator_i == 7'hA;	// \\src\\main\\scala\\alu\\ibex_shifter.scala:42:25
  wire [31:0] _io_shift_operand_T = _GEN ? io_operand_a_rev : io_operand_a_i;	// \\src\\main\\scala\\alu\\ibex_shifter.scala:42:25, :54:28
  wire [32:0] _io_shift_result_ext_signed_T_5 =
    $signed($signed({_io_shift_operand_T[31], _io_shift_operand_T})
            >>> (io_instr_first_cycle_i
                   ? (io_operand_b_i[5] ? _io_shift_amt_compl_T_1 : io_operand_b_i[4:0])
                   : io_operand_b_i[5] ? io_operand_b_i[4:0] : _io_shift_amt_compl_T_1));	// \\src\\main\\scala\\alu\\ibex_shifter.scala:33:{32,48}, :34:{39,47}, :35:28, :36:28, :54:28, :55:{38,71,102}
  wire [7:0]  _GEN_0 =
    {{_io_shift_result_ext_signed_T_5[11:8], _io_shift_result_ext_signed_T_5[15:14]}
       & 6'h33,
     2'h0}
    | {_io_shift_result_ext_signed_T_5[15:12], _io_shift_result_ext_signed_T_5[19:16]}
    & 8'h33;	// \\src\\main\\scala\\alu\\ibex_shifter.scala:55:102, :60:{35,55}
  wire [18:0] _GEN_1 =
    {_io_shift_result_ext_signed_T_5[5:4],
     _io_shift_result_ext_signed_T_5[7:6],
     _io_shift_result_ext_signed_T_5[9:8],
     _GEN_0,
     _io_shift_result_ext_signed_T_5[19:18],
     _io_shift_result_ext_signed_T_5[21:20],
     _io_shift_result_ext_signed_T_5[23]} & 19'h55555;	// \\src\\main\\scala\\alu\\ibex_shifter.scala:55:102, :60:35
  assign io_shift_result =
    _GEN
      ? {_io_shift_result_ext_signed_T_5[0],
         _io_shift_result_ext_signed_T_5[1],
         _io_shift_result_ext_signed_T_5[2],
         _io_shift_result_ext_signed_T_5[3],
         _io_shift_result_ext_signed_T_5[4],
         _GEN_1[18:15]
           | {_io_shift_result_ext_signed_T_5[7:6], _io_shift_result_ext_signed_T_5[9:8]}
           & 4'h5,
         _GEN_1[14:7] | _GEN_0 & 8'h55,
         _GEN_0[1],
         _GEN_1[5] | _io_shift_result_ext_signed_T_5[18],
         _io_shift_result_ext_signed_T_5[19],
         _io_shift_result_ext_signed_T_5[20],
         {_GEN_1[2:0], 1'h0}
           | {_io_shift_result_ext_signed_T_5[23:22],
              _io_shift_result_ext_signed_T_5[25:24]} & 4'h5,
         _io_shift_result_ext_signed_T_5[25],
         _io_shift_result_ext_signed_T_5[26],
         _io_shift_result_ext_signed_T_5[27],
         _io_shift_result_ext_signed_T_5[28],
         _io_shift_result_ext_signed_T_5[29],
         _io_shift_result_ext_signed_T_5[30],
         _io_shift_result_ext_signed_T_5[31]}
      : _io_shift_result_ext_signed_T_5[31:0];	// <stdin>:63:3, \\src\\main\\scala\\alu\\ibex_shifter.scala:42:25, :55:102, :59:26, :60:{25,35}, :62:{25,54}
      
  ////////////////////
  // ADDED MANUALLY //
  // TO REMOVE ALL  //
  // UNUSED SIGNALS //
  always_comb begin
    if (io_operand_b_i[31:6] == 26'b0) begin end
    if (_io_shift_result_ext_signed_T_5[32]) begin end
    if ({_GEN_1[6], _GEN_1[4:3]} == 3'b0) begin end
  end
  ////////////////////
endmodule