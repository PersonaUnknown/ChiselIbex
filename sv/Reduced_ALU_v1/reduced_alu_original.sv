// Reducing the SystemVerilog of the Ibex ALU to an initially more manageable state
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

  // ORIGINAL
  logic [32:0] adder_in_a, adder_in_b;
  logic [31:0] adder_result;
  // prepare operands a and b
  always_comb begin
    adder_in_a = {operand_a_i,1'b1};
    adder_in_b = {operand_b_i, 1'b0};
  end
  // actual adder
  assign adder_result_ext_o = $unsigned(adder_in_a) + $unsigned(adder_in_b);
  assign adder_result       = adder_result_ext_o[32:1];
  assign adder_result_o     = adder_result;
  
  ////////////////
  // Comparison //
  ////////////////

  // ORIGINAL VERSION
  logic is_equal;
  logic is_greater_equal;  // handles both signed and unsigned forms
  logic cmp_signed;
  assign is_equal = adder_result == 32'b0;
  assign is_equal_result_o = is_equal;
  // Is greater equal
  always_comb begin
    cmp_signed = operator_i == ALU_GE ? 1'b1 : 1'b0;
    is_greater_equal = (operand_a_i[31] ^ operand_b_i[31]) == 1'b0 ? adder_result[31] == 1'b0 : operand_a_i[31] ^ cmp_signed;
  end
  // generate comparison result
  logic cmp_result;
  always_comb begin
    unique case (operator_i)
      ALU_NE: cmp_result = ~is_equal;
      ALU_GE: cmp_result = is_greater_equal;
      ALU_LT, ALU_LTU: cmp_result = ~is_greater_equal;
      default: cmp_result = is_equal;
    endcase
  end
  assign comparison_result_o = cmp_result;

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
  
  // ORIGINAL VERSION
  logic       shift_left;
  logic       shift_ones;
  logic [5:0] shift_amt;
  logic [5:0] shift_amt_compl; // complementary shift amount (32 - shift_amt)
  logic        [31:0] shift_operand;
  logic signed [32:0] shift_result_ext_signed;
  logic        [32:0] shift_result_ext;
  logic               unused_shift_result_ext;
  logic        [31:0] shift_result;
  logic        [31:0] shift_result_rev;
  // bit shift_amt[5]: word swap bit: only considered for FSL/FSR.
  // if set, reverse operations in first and second cycle.
  assign shift_amt[5] = operand_b_i[5];
  assign shift_amt_compl = 32 - operand_b_i[4:0];
  always_comb begin
    shift_amt[4:0] = instr_first_cycle_i ?
          (operand_b_i[5] ? shift_amt_compl[4:0] : operand_b_i[4:0]) :
          (operand_b_i[5] ? operand_b_i[4:0] : shift_amt_compl[4:0]);
  end
  // left shift if this is:
  // * a standard left shift (slo, sll)
  // * fsl: without word-swap bit: first cycle, else: second cycle
  // * a single-bit instruction: bclr, bset, binv (excluding bext)
  always_comb begin
    unique case (operator_i)
      ALU_SLL: shift_left = 1'b1;
      ALU_FSL: shift_left = (RV32B != RV32BNone) ?
        (shift_amt[5] ? ~instr_first_cycle_i : instr_first_cycle_i) : 1'b0;
      default: shift_left = 1'b0;
    endcase
  end
  assign shift_ones = 1'b0;
  // shifter structure.
  always_comb begin
    // select shifter input
    // for bfp, sbmode and shift_left the corresponding bit-reversed input is chosen.
    shift_operand = shift_left ? operand_a_rev : operand_a_i;
    shift_result_ext_signed = $signed({shift_ones | shift_operand[31], shift_operand}) >>> shift_amt[4:0];
    shift_result_ext = $unsigned(shift_result_ext_signed);
    shift_result            = shift_result_ext[31:0];
    unused_shift_result_ext = shift_result_ext[32];
    for (int unsigned i = 0; i < 32; i++) begin
      shift_result_rev[i] = shift_result[31-i];
    end
    shift_result = shift_left ? shift_result_rev : shift_result;
  end
  
  ///////////////////
  // Bitwise Logic //
  ///////////////////
  // ORIGINAL
  logic bwlogic_and;
  logic [31:0] bwlogic_operand_b;
  logic [31:0] bwlogic_and_result;
  logic [31:0] bwlogic_result;
  assign bwlogic_operand_b = operand_b_i;
  assign bwlogic_and_result = operand_a_i & bwlogic_operand_b;
  assign bwlogic_and = operator_i == ALU_AND;
  always_comb begin
    bwlogic_result = bwlogic_and ? bwlogic_and_result : 32'0;
  end
  
  ////////////////
  // Result mux //
  ////////////////
  // ORIGINAL
  always_comb begin
    result_o   = '0;
    unique case (operator_i)
      // Bitwise Logic Operations
      ALU_AND: result_o = bwlogic_result;
      // Adder Operations
      ALU_ADD:result_o = adder_result;
      // Shift Operations
      ALU_SLL,  ALU_SRL: result_o = shift_result;
      // Comparison Operations
      //ALU_GE: result_o = {31'h0, cmp_result};        // ORIGINAL
      ALU_GE: result_o = {31'h0, comparison_result_o}; // CHISEL VERSION 
      default: ;
    endcase
  end
  logic unused_shift_amt_compl;
  assign unused_shift_amt_compl = shift_amt_compl[5];
endmodule