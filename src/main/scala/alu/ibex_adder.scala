package alu
import chisel3._
import chisel3.stage._
import chisel3.util.Cat
import chisel3.util.switch
import chisel3.util.is
import chisel3.util.Fill

class IbexAdder extends Module {       
    val io = IO(new Bundle {
        val operator_i          = Input(alu_op_e())
        val operand_a_i         = Input(UInt(32.W))
        val operand_b_i         = Input(UInt(32.W))

        val adder_op_b_negate   = Output(Bool())
        val operand_b_neg       = Output(UInt(33.W))
        val adder_result        = Output(UInt(32.W))
        val adder_in_a          = Output(UInt(33.W))
        val adder_in_b          = Output(UInt(33.W))        
        val adder_result_o      = Output(UInt(32.W))
        val adder_result_ext_o  = Output(UInt(34.W))
    })

    io.adder_op_b_negate := 0.U
    when (io.operator_i === alu_op_e.ALU_SUB || io.operator_i === alu_op_e.ALU_EQ 
       || io.operator_i === alu_op_e.ALU_NE  || io.operator_i === alu_op_e.ALU_GE 
       || io.operator_i === alu_op_e.ALU_GEU || io.operator_i === alu_op_e.ALU_LT 
       || io.operator_i === alu_op_e.ALU_LTU || io.operator_i === alu_op_e.ALU_SLT 
       || io.operator_i === alu_op_e.ALU_SLTU) 
    {
        io.adder_op_b_negate := 1.U(1.W)
    }

    // Prepare Operands
    io.adder_in_a := Cat(io.operand_a_i, 1.U(1.W))
    val ones = Fill(33, 1.U(1.W))
    io.operand_b_neg := Cat(io.operand_b_i, 0.U(1.W)) ^ ones
    when (io.adder_op_b_negate) {
        io.adder_in_b := io.operand_b_neg
    } .otherwise {
        io.adder_in_b := Cat(io.operand_b_i, 0.U(1.W))
    }
    
    // Actual adder
    io.adder_result_ext_o := io.adder_in_a.asUInt + io.adder_in_b.asUInt
    io.adder_result       := io.adder_result_ext_o(32, 1)
    io.adder_result_o     := io.adder_result
}

object IbexAdder extends App {
    new circt.stage.ChiselStage().execute(args,Seq(circt.stage.CIRCTTargetAnnotation(circt.stage.CIRCTTarget.SystemVerilog), ChiselGeneratorAnnotation(() => new IbexAdder)))   
}
