package csr
import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class EdgeDetectorTest extends AnyFlatSpec with ChiselScalatestTester {
  "EdgeDetector test" should "pass" in {
    test(new EdgeDetector).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
      var flip = true
      dut.io.signal.poke((false))
      for (i <- 0 until 500) {
        
        dut.clock.step(1)
        if (i % 10 == 0) {
            dut.io.signal.poke(flip)
            flip = !flip
        }
      }
      
    }
  }
}