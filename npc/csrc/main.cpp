#include <cstdio>
#include <cassert>
#include <verilated.h>
#include "VsCPU.h"

constexpr vluint64_t HALF_PERIOD = 5000;  // cycle = 10 ns
// single step
static void clock_cycle(VerilatedContext& context, VsCPU& dut){
  dut.clk = 0;
  dut.eval();
  context.timeInc(HALF_PERIOD);

  dut.clk = 1;
  dut.eval();
  context.timeInc(HALF_PERIOD);
}

static void print_state(unsigned cycle, const VsCPU& dut){
  std::printf(
    "cycle = %2u  pc = %u r0 = %u r1 = %u r2 = %u r3 = %u\n",
    cycle,
    static_cast<unsigned>(dut.pc_monitor),
    static_cast<unsigned>(dut.gpr0_monitor),
    static_cast<unsigned>(dut.gpr1_monitor),
    static_cast<unsigned>(dut.gpr2_monitor),
    static_cast<unsigned>(dut.gpr3_monitor)
  );
}

int main(int argc, char** argv) {
  VerilatedContext context;
  context.commandArgs(argc, argv);

  VsCPU dut{&context};

  // initial
  dut.clk = 0;
  dut.rstn = 0;
  dut.eval();

  // keep resetting
  clock_cycle(context, dut);
  clock_cycle(context, dut);

  // releasing
  dut.rstn = 1;

  constexpr unsigned MAX_CYCLES = 64;
  bool reached_halt = false;

  for (unsigned cycle = 1; cycle <= MAX_CYCLES; ++cycle) {
    clock_cycle(context, dut);
    print_state(cycle, dut);

    if (dut.pc_monitor == 8) {
      reached_halt = true;
      break;
    }
  }
    
  if (!reached_halt) {
    std::fprintf(stderr, "FAIL: timeout before reaching PC = 5\n");
    dut.final();
    return 1;
  }

  if (dut.gpr0_monitor != 10 ||
      dut.gpr1_monitor != 10  ||
      dut.gpr2_monitor != 55 ||
      dut.gpr3_monitor != 1) {
    std::fprintf(stderr, "FAIL: incorrect register state\n"
        "r0 = %u  r1 = %u r2 = %u r3 = %u\n",
        static_cast<unsigned>(dut.gpr0_monitor),
        static_cast<unsigned>(dut.gpr1_monitor),
        static_cast<unsigned>(dut.gpr2_monitor),
        static_cast<unsigned>(dut.gpr3_monitor));
    dut.final();
    return 1;
  }
  clock_cycle(context, dut);
  if(dut.pc_monitor != 8) {
    std::fprintf(
      stderr, "FAIL: halt instruction did not keep pc at 5\n"
    );
    dut.final();
    return 1;
  }
  
  std::printf("PASS: PC = 8, R0 = 10, R1 = 10, R2 = 55, R3 = 1\n");
  dut.final();
  return 0;
}
