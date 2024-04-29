package alu
import chisel3._
import chisel3.stage._

class IbexComparator extends Module {       
    val io = IO(new Bundle {
        val operator_i          = Input(alu_op_e())
        val operand_a_i         = Input(UInt(32.W))
        val operand_b_i         = Input(UInt(32.W))
        val adder_result        = Input(UInt(32.W))

        val is_equal            = Output(Bool())
        val is_greater_equal    = Output(Bool())
        val cmp_signed          = Output(Bool())
        val cmp_result          = Output(Bool())
        val comparison_result_o = Output(Bool())
        val is_equal_result_o   = Output(Bool())
        val unused_operand_a_i  = Output(UInt(31.W))
        val unused_operand_b_i  = Output(UInt(31.W))
    })

    // Is Greater Equal
    when (io.operator_i === alu_op_e.ALU_GE || io.operator_i === alu_op_e.ALU_LT || io.operator_i === alu_op_e.ALU_SLT) {
        io.cmp_signed := 1.U (1.W)
    }.otherwise{
        io.cmp_signed := 0.U(1.W)
    }
    io.is_equal := io.adder_result === 0.U(32.W)
    io.is_equal_result_o := io.is_equal
    io.is_greater_equal := Mux((io.operand_a_i(31) ^ io.operand_b_i(31)) === 0.U, io.adder_result(31) === 0.U, io.operand_a_i(31) ^ io.cmp_signed)

    // Generate Comparison Result
    when (io.operator_i === alu_op_e.ALU_EQ) {
        io.cmp_result := io.is_equal
    }.elsewhen(io.operator_i === alu_op_e.ALU_NE) {
        io.cmp_result := ~io.is_equal
    }.elsewhen(io.operator_i === alu_op_e.ALU_GE || io.operator_i === alu_op_e.ALU_GEU) {
        io.cmp_result := io.is_greater_equal
    } .elsewhen(io.operator_i === alu_op_e.ALU_LT || io.operator_i === alu_op_e.ALU_LTU || io.operator_i === alu_op_e.ALU_SLT || io.operator_i === alu_op_e.ALU_SLTU) {
        io.cmp_result := ~io.is_greater_equal
    } .otherwise {
        io.cmp_result := io.is_equal
    }
    io.comparison_result_o := io.cmp_result

    // UNUSED SIGNALS
    io.unused_operand_a_i := io.operand_a_i(30, 0)
    io.unused_operand_b_i := io.operand_b_i(30, 0)
}

object IbexComparator extends App {
    new circt.stage.ChiselStage().execute(args,Seq(circt.stage.CIRCTTargetAnnotation(circt.stage.CIRCTTarget.SystemVerilog), ChiselGeneratorAnnotation(() => new IbexComparator)))   
}

