package alu
import chisel3._
import chisel3.stage._
import chisel3.util.Reverse
import chisel3.util.Cat

object IbexALUMain extends App {
    class IbexALU(RV32B: rv32b_e.Type) extends Module {
        val io = IO(new Bundle {
            // Inputs
            val operator_i          = Input(alu_op_e())
            val operand_a_i         = Input(UInt(32.W))
            val operand_b_i         = Input(UInt(32.W))
            val instr_first_cycle_i = Input(Bool())
            val multdiv_operand_a_i = Input(UInt(33.W))
            val multdiv_operand_b_i = Input(UInt(33.W))
            val multdiv_sel_i       = Input(Bool())
            val imd_val_q_i         = Input(Vec(2, UInt(32.W)))
            // Outputs
            val imd_val_d_o         = Output(Vec(2, UInt(32.W)))
            val imd_val_we_o        = Output(UInt(2.W))
            val adder_result_o      = Output(UInt(32.W))
            val adder_result_ext_o  = Output(UInt(34.W))
            val result_o            = Output(UInt(32.W))
            val comparison_result_o = Output(Bool())
            val is_equal_result_o   = Output(Bool())
        })

        // Bit reverse operand_a for left shifts
        val operand_a_rev = Wire(UInt(32.W))
        operand_a_rev := Reverse(io.operand_a_i)
        
        ///////////
        // Adder //
        ///////////
        val alu_adder = Module(new IbexAdder())
        alu_adder.io.operator_i  := io.operator_i
        alu_adder.io.operand_a_i := io.operand_a_i
        alu_adder.io.operand_b_i := io.operand_b_i
        io.adder_result_o     := alu_adder.io.adder_result_o
        io.adder_result_ext_o := alu_adder.io.adder_result_ext_o

        ////////////////
        // Comparison //
        ////////////////
        val alu_comparator = Module(new IbexComparator())
        alu_comparator.io.operator_i   := io.operator_i
        alu_comparator.io.operand_a_i  := io.operand_a_i
        alu_comparator.io.operand_b_i  := io.operand_b_i
        alu_comparator.io.adder_result := alu_adder.io.adder_result
        io.comparison_result_o         := alu_comparator.io.comparison_result_o
        io.is_equal_result_o           := alu_comparator.io.is_equal_result_o

        val is_equal = Wire(Bool())
        val is_greater_equal = Wire(Bool())
        val cmp_sign = Wire(Bool())
        val cmp_result = Wire(Bool())
        val unused_operand_a_i = Wire(UInt(31.W))
        val unused_operand_b_i = Wire(UInt(31.W))
        is_equal := alu_comparator.io.is_equal
        is_greater_equal := alu_comparator.io.is_greater_equal
        cmp_sign := alu_comparator.io.cmp_signed
        cmp_result := alu_comparator.io.cmp_result
        unused_operand_a_i := alu_comparator.io.unused_operand_a_i
        unused_operand_b_i := alu_comparator.io.unused_operand_b_i
        ///////////
        // Shift //
        ///////////
        val alu_shifter = Module(new IbexShifter())
        alu_shifter.io.RV32B               := RV32B
        alu_shifter.io.operator_i          := io.operator_i
        alu_shifter.io.operand_a_i         := io.operand_a_i
        alu_shifter.io.operand_b_i         := io.operand_b_i
        alu_shifter.io.operand_a_rev       := operand_a_rev
        alu_shifter.io.adder_result        := alu_adder.io.adder_result
        alu_shifter.io.instr_first_cycle_i := io.instr_first_cycle_i
        
        /////////////
        // Bitwise //
        /////////////
        val alu_bitwise = Module(new IbexBitwise())
        alu_bitwise.io.operator_i   := io.operator_i
        alu_bitwise.io.operand_a_i  := io.operand_a_i
        alu_bitwise.io.operand_b_i  := io.operand_b_i
        alu_bitwise.io.adder_result := alu_adder.io.adder_result

        ////////////////
        // Result MUX //
        ////////////////
        val alu_result_mux = Module(new IbexResultMux())
        alu_result_mux.io.operator_i      := io.operator_i
        alu_result_mux.io.operand_a_i     := io.operand_a_i
        alu_result_mux.io.operand_b_i     := io.operand_b_i
        alu_result_mux.io.adder_result    := alu_adder.io.adder_result
        alu_result_mux.io.bwlogic_result  := alu_bitwise.io.bwlogic_result
        alu_result_mux.io.shift_amt_compl := alu_shifter.io.shift_amt_compl
        alu_result_mux.io.shift_result    := alu_shifter.io.shift_result
        alu_result_mux.io.cmp_result      := alu_comparator.io.comparison_result_o
        io.result_o                       := alu_result_mux.io.result_o

        // UNUSED SIGNALS (COMPARATOR)
        // val unused_operand_a_i_comp = Wire(UInt(31.W))
        // unused_operand_a_i_comp := alu_comparator.io.unused_operand_a_i
        // dontTouch(unused_operand_a_i_comp)
        // val unused_operand_b_i_comp = Wire(UInt(31.W))
        // unused_operand_b_i_comp := alu_comparator.io.unused_operand_b_i
        // dontTouch(unused_operand_b_i_comp)

        // // UNUSED SIGNALS (SHIFTER)
        // val unused_shift_result_ext = Wire(Bool())
        // unused_shift_result_ext := alu_shifter.io.unused_shift_result_ext
        // dontTouch(unused_shift_result_ext)
        // val unused_operand_b_i_shift = Wire(UInt(27.W))
        // unused_operand_b_i_shift := alu_shifter.io.unused_operand_b_i
        // dontTouch(unused_operand_b_i_shift)

        // // UNUSED SIGNALS (Result MUX)
        // val unused_shift_amt_compl = Wire(Bool())
        // unused_shift_amt_compl := alu_result_mux.io.shift_amt_compl(5)
        // dontTouch(unused_shift_amt_compl)

        // // UNUSED SIGNALS (I/O)
        // val unused_multdiv_operand_a_i = Wire(UInt(33.W))
        // unused_multdiv_operand_a_i := io.multdiv_operand_a_i
        // dontTouch(unused_multdiv_operand_a_i)
        // val unused_multdiv_operand_b_i = Wire(UInt(33.W))
        // unused_multdiv_operand_b_i := io.multdiv_operand_b_i
        // dontTouch(unused_multdiv_operand_b_i)
        // val unused_multdiv_sel_i = Wire(Bool())
        // unused_multdiv_sel_i := io.multdiv_sel_i
        // dontTouch(unused_multdiv_sel_i)
        io.imd_val_d_o := io.imd_val_q_i
        io.imd_val_we_o := 0.U
    }
    new circt.stage.ChiselStage().execute(args,Seq(circt.stage.CIRCTTargetAnnotation(circt.stage.CIRCTTarget.SystemVerilog), ChiselGeneratorAnnotation(() => new IbexALU(rv32b_e.RV32BNone))))   
}