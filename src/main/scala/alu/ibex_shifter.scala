package alu
import chisel3._
import chisel3.stage._
import chisel3.util.Reverse
import chisel3.util.Cat

class IbexShifter extends Module {       
    val io = IO(new Bundle {
        // Values From ALU
        val RV32B               = Input(rv32b_e())
        val operator_i          = Input(alu_op_e())
        val operand_a_i         = Input(UInt(32.W))
        val operand_b_i         = Input(UInt(32.W))
        val operand_a_rev       = Input(UInt(32.W))
        val adder_result        = Input(UInt(32.W))
        val instr_first_cycle_i = Input(Bool())
    
        // Shift-Specific
        val shift_left              = Output(Bool())
        val shift_ones              = Output(Bool())
        val shift_arith             = Output(Bool())
        val shift_funnel            = Output(Bool())
        val shift_amt               = Output(UInt(6.W))
        val shift_amt_compl         = Output(UInt(6.W))
        val shift_operand           = Output(UInt(32.W))
        val shift_result_ext_signed = Output(SInt(33.W))
        val shift_result_ext        = Output(UInt(33.W))
        val shift_result            = Output(UInt(32.W))

        // UNUSED SIGNALS
        val unused_shift_result_ext = Output(Bool())
        val unused_operand_b_i      = Output(UInt(27.W))
    })

    // Bit shift_amt(5): word swap bit: only considered for FSL/FSR
    // If set, reverse operations in first and second cycle
    io.shift_amt_compl := 32.U - io.operand_b_i(4, 0)
    io.shift_amt := Cat(io.operand_b_i(5) & io.shift_funnel, Mux(io.instr_first_cycle_i, 
                          Mux(io.operand_b_i(5) && io.shift_funnel, io.shift_amt_compl(4, 0), io.operand_b_i(4,0)), 
                          Mux(io.operand_b_i(5) && io.shift_funnel, io.operand_b_i(4,0), io.shift_amt_compl(4, 0))
                          ))
    // Left shift if this is:
    // * a standard left shift (slo, sll)
    when (io.operator_i === alu_op_e.ALU_SLL) {
        io.shift_left := 1.U(1.W)
    }.elsewhen(io.operator_i === alu_op_e.ALU_SLO) {
        io.shift_left := Mux(io.RV32B === rv32b_e.RV32BOTEarlGrey || io.RV32B === rv32b_e.RV32BFull, 1.U(1.W), 0.U(1.W))
    }.otherwise{
        io.shift_left := 0.U
    }
    io.shift_arith := io.operator_i === alu_op_e.ALU_SRA
    io.shift_ones := Mux((io.RV32B === rv32b_e.RV32BOTEarlGrey) || (io.RV32B === rv32b_e.RV32BFull), 
                       (io.operator_i === alu_op_e.ALU_SLO) | (io.operator_i === alu_op_e.ALU_SRO), 0.U(1.W)
                     )
    io.shift_funnel := Mux(io.RV32B =/= rv32b_e.RV32BNone, 
                        (io.operator_i === alu_op_e.ALU_FSL) | (io.operator_i === alu_op_e.ALU_FSR), 0.U(1.W)
                       )

    // Shifter Structure
    // Select shifter input: For bfp, sbmode and shift_left the corresponding bit_reversed input is chosen
    io.shift_operand := Mux(io.shift_left, io.operand_a_rev, io.operand_a_i)
    io.shift_result_ext_signed := Cat(io.shift_ones | (io.shift_arith & io.shift_operand(31)), io.shift_operand).asSInt >> io.shift_amt(4, 0)
    io.shift_result_ext := io.shift_result_ext_signed.asUInt
    io.shift_result := io.shift_result_ext(31, 0)
    when (io.shift_left) {
        io.shift_result := Reverse(io.shift_result_ext(31, 0))
    }.otherwise{
        io.shift_result := io.shift_result_ext(31, 0)
    }

    // UNUSED SIGNALS
    io.unused_operand_b_i := io.operand_b_i(31, 5)
    io.unused_shift_result_ext := io.shift_result_ext(32)
}

object IbexShifter extends App {
    new circt.stage.ChiselStage().execute(args,Seq(circt.stage.CIRCTTargetAnnotation(circt.stage.CIRCTTarget.SystemVerilog), ChiselGeneratorAnnotation(() => new IbexShifter)))   
}

