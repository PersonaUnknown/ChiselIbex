package alu
import chisel3._
import chisel3.stage._
import chisel3.util.Cat
import chisel3.util.switch
import chisel3.util.is

class IbexResultMux extends Module {       
        val io = IO(new Bundle {
            val operator_i          = Input(alu_op_e())
            val operand_a_i         = Input(UInt(32.W))
            val operand_b_i         = Input(UInt(32.W))
            val adder_result        = Input(UInt(32.W))
            val bwlogic_result      = Input(UInt(32.W))
            val shift_amt_compl     = Input(UInt(6.W))
            val shift_result        = Input(UInt(32.W))
            val cmp_result          = Input(Bool())
            val result_o            = Output(UInt(32.W))
            val unused_shift_amt_compl = Output(Bool())
        })

        io.result_o := 0.U
        when (io.operator_i === alu_op_e.ALU_AND || io.operator_i === alu_op_e.ALU_XOR || io.operator_i === alu_op_e.ALU_OR) {
                io.result_o := io.bwlogic_result
        }.elsewhen (io.operator_i === alu_op_e.ALU_ADD || io.operator_i === alu_op_e.ALU_SUB) {
            io.result_o := io.adder_result
        }.elsewhen(io.operator_i === alu_op_e.ALU_SLL || io.operator_i === alu_op_e.ALU_SRL || io.operator_i === alu_op_e.ALU_SRA) {
            io.result_o := io.shift_result
        }.elsewhen(io.operator_i === alu_op_e.ALU_EQ || io.operator_i === alu_op_e.ALU_NE ||
                   io.operator_i === alu_op_e.ALU_GE || io.operator_i === alu_op_e.ALU_GEU ||
                   io.operator_i === alu_op_e.ALU_LT || io.operator_i === alu_op_e.ALU_LTU ||
                   io.operator_i === alu_op_e.ALU_SLT || io.operator_i === alu_op_e.ALU_SLTU) 
        {
            io.result_o := Cat(0.U(31.W), io.cmp_result)
        }

        io.unused_shift_amt_compl := io.shift_amt_compl(5)
    }

object IbexResultMux extends App {
    new circt.stage.ChiselStage().execute(args,Seq(circt.stage.CIRCTTargetAnnotation(circt.stage.CIRCTTarget.SystemVerilog), ChiselGeneratorAnnotation(() => new IbexResultMux)))   
}

