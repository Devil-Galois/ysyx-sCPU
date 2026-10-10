#include <verilated.h>
#include <nvboard.h>
#include "VsCPU.h"

void nvboard_bind_all_pins(VsCPU* top);
constexpr vluint64_t HALF_PERIOD = 5000; // 5000 ps = 5ns

static void clock_cycle(VerilatedContext& context, VsCPU& dut){
    dut.clk = 0;
    dut.eval();
    context.timeInc(HALF_PERIOD);

    dut.clk = 1;
    dut.eval();
    context.timeInc(HALF_PERIOD);
}

int main(int argc, char** argv) {
    VerilatedContext context;
    context.commandArgs(argc, argv);
    VsCPU dut{&context};

    dut.clk = 0;
    dut.rstn = 0;
    dut.dev_btn = 0;
    dut.dev_sw = 0;
    dut.eval();

    nvboard_bind_all_pins(&dut);
    nvboard_init();

    clock_cycle(context, dut);
    clock_cycle(context, dut);
    dut.rstn = 1;

    while(!context.gotFinish()){
        nvboard_update();
        clock_cycle(context, dut);
    }
    dut.final();
    nvboard_quit();
    return 0;
}
