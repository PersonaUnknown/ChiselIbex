package alu
import chisel3._
import chisel3.stage._
import chisel3.util._

object rv32b_e extends ChiselEnum {
  val RV32BNone       = Value(0.U)
  val RV32Balanced    = Value(1.U)
  val RV32BOTEarlGrey = Value(2.U)
  val RV32BFull       = Value(3.U)
}

object alu_op_e extends ChiselEnum {
    val ALU_ADD, 
        ALU_SUB,
     // Logics
        ALU_XOR,
        ALU_OR,
        ALU_AND,
     // RV32B
        ALU_XNOR,
        ALU_ORN,
        ALU_ANDN,
     // Shifts
        ALU_SRA,
        ALU_SRL,
        ALU_SLL,
     // RV32B
        ALU_SRO,
        ALU_SLO,
        ALU_ROR,
        ALU_ROL,
        ALU_GREV,
        ALU_GORC,
        ALU_SHFL,
        ALU_UNSHFL,
        ALU_XPERM_N,
        ALU_XPERM_B,
        ALU_XPERM_H,
     // Address Calculation (RV32B)
        ALU_SH1ADD,
        ALU_SH2ADD,
        ALU_SH3ADD,
     // Comparisons
        ALU_LT,
        ALU_LTU,
        ALU_GE,
        ALU_GEU,
        ALU_EQ,
        ALU_NE,
     // RV32B
        ALU_MIN,
        ALU_MINU,
        ALU_MAX,
        ALU_MAXU,
     // Pack (RV32B)
        ALU_PACK,
        ALU_PACKU,
        ALU_PACKH,
     // Sign-Extend (RV32B)
        ALU_SEXTB,
        ALU_SEXTH,
     // Bitcounting (RV32B)
        ALU_CLZ,
        ALU_CTZ,
        ALU_CPOP,
     // Set lower than
        ALU_SLT,
        ALU_SLTU,
     // Ternary Bitmanip Operations (RV32B)    
        ALU_CMOV,
        ALU_CMIX,
        ALU_FSL,
        ALU_FSR,
     // Single-Bit Operations (RV32B)
        ALU_BSET,
        ALU_BCLR,
        ALU_BINV,
        ALU_BEXT,
     // Bit Compress / Decompress (RV32B)
        ALU_BCOMPRESS,
        ALU_BDECOMPRESS,
     // Bit Field Place (RV32B)
        ALU_BFP,
     // Carry-less Multiply (RV32B)
        ALU_CLMUL,
        ALU_CLMULR,
        ALU_CLMULH,
     // Cyclic Redundancy Check
        ALU_CRC32_B,
        ALU_CRC32C_B,
        ALU_CRC32_H,
        ALU_CRC32C_H,
        ALU_CRC32_W,
        ALU_CRC32C_W = Value
}