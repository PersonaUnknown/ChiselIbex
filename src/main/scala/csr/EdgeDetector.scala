package csr
import chisel3._
import chisel3.stage._

class EdgeDetector() extends Module {       
   val io = IO(new Bundle {
    val signal = Input(Bool())
    val risingEdge = Output(Bool())
    val fallingEdge = Output(Bool())
   })

   val prevSignal = RegNext(io.signal)
   io.risingEdge := io.signal && !prevSignal
   io.fallingEdge := !io.signal && prevSignal
}

object EdgeDetector extends App {
    new circt.stage.ChiselStage().execute(args,Seq(circt.stage.CIRCTTargetAnnotation(circt.stage.CIRCTTarget.SystemVerilog), ChiselGeneratorAnnotation(() => new EdgeDetector())))   
}

