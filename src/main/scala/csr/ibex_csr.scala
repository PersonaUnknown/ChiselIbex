package csr
import chisel3._
import chisel3.stage._

class IbexCSR(Width: Int = 32, ShadowCopy: Bool = false.B, ResetValue: UInt = 0.U) extends Module {       
    val io = IO(new Bundle{
        val wr_data_i  = Input(UInt(Width.W))
        val wr_en_i    = Input(Bool())
        val rd_data_o  = Output(UInt(Width.W))
        val rd_error_o = Output(Bool())
    })

    def risingedge(x: Bool) = x && !RegNext(x)
    def fallingedge(x: Bool) = !x && RegNext(x)

    val rdata_q = RegInit(0.U(Width.W))    
    when (risingedge(clock.asBool) || fallingedge(reset.asBool)) {
        when (!reset.asBool) {
            rdata_q := ResetValue
        }.elsewhen(io.wr_en_i) {
            rdata_q := io.wr_data_i
        }.otherwise{
            rdata_q := 0.U
        }
    }.otherwise {
        rdata_q := 0.U
    }

    io.rd_data_o := rdata_q
    
    when (ShadowCopy) {
        // Generate Shadow
        val shadow_q = RegInit(0.U(Width.W))
        when (risingedge(clock.asBool) || fallingedge(reset.asBool)) {
            when (!reset.asBool) {
                shadow_q := ~ResetValue
            }.elsewhen(io.wr_en_i) {
                shadow_q := ~io.wr_data_i
            }
            .otherwise
            {
                shadow_q := 0.U
            }
        }
        .otherwise{
            shadow_q := 0.U
        }
        io.rd_error_o := rdata_q =/= ~shadow_q
    } .otherwise {
        // Generate No Shadow
        io.rd_error_o := 0.B
    }

    // INSERT ASSERTIONS (NOT NECESSARY TO HAVE THE SYSTEM OPERATE)
}

object IbexCSR extends App {
    new circt.stage.ChiselStage().execute(args,Seq(circt.stage.CIRCTTargetAnnotation(circt.stage.CIRCTTarget.SystemVerilog), ChiselGeneratorAnnotation(() => new IbexCSR(ShadowCopy = true.B))))
}