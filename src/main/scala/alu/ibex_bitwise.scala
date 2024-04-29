package alu
import chisel3._
import chisel3.stage._

class IbexBitwise extends Module {       
        val io = IO(new Bundle {
            val operator_i          = Input(alu_op_e())
            val operand_a_i         = Input(UInt(32.W))
            val operand_b_i         = Input(UInt(32.W))
            val adder_result        = Input(UInt(32.W))
            
            val bwlogic_or          = Output(Bool())
            val bwlogic_and         = Output(Bool())
            val bwlogic_operand_b   = Output(UInt(32.W))
            val bwlogic_or_result   = Output(UInt(32.W))
            val bwlogic_and_result  = Output(UInt(32.W))
            val bwlogic_xor_result  = Output(UInt(32.W))
            val bwlogic_result      = Output(UInt(32.W))
        })

        io.bwlogic_operand_b  := io.operand_b_i
        io.bwlogic_or_result  := io.operand_a_i | io.bwlogic_operand_b
        io.bwlogic_and_result := io.operand_a_i & io.bwlogic_operand_b
        io.bwlogic_xor_result := io.operand_a_i ^ io.bwlogic_operand_b
        io.bwlogic_or  := (io.operator_i === alu_op_e.ALU_OR)  | (io.operator_i === alu_op_e.ALU_ORN)
        io.bwlogic_and := (io.operator_i === alu_op_e.ALU_AND) | (io.operator_i === alu_op_e.ALU_ANDN)
        when (io.bwlogic_or) {
            io.bwlogic_result := io.bwlogic_or_result
        }.elsewhen(io.bwlogic_and) {
            io.bwlogic_result := io.bwlogic_and_result
        }.otherwise {
            io.bwlogic_result := io.bwlogic_xor_result
        }
    }

object IbexBitwise extends App {
    new circt.stage.ChiselStage().execute(args,Seq(circt.stage.CIRCTTargetAnnotation(circt.stage.CIRCTTarget.SystemVerilog), ChiselGeneratorAnnotation(() => new IbexBitwise)))   
}

