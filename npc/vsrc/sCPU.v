`timescale 1ns/1ps
module sCPU #(
    parameter WIDTH = 8,
    parameter DEPTH = 256,
    parameter N = 4,
    parameter ADDR_WIDTH = 2,
    parameter OP_WIDTH = 2,
    parameter JUMP_WIDTH = 4,
    parameter IDX_WIDTH = 3,
    parameter BTN_WIDTH = 5,
    parameter SEG_WIDTH = 8,
    parameter SW_WIDTH = 8,
    parameter LED_WIDTH = 16
)(
    input wire clk,
    input wire rstn,

    // from dev
    input wire [BTN_WIDTH - 1 : 0] dev_btn,
    input wire [SW_WIDTH - 1 : 0] dev_sw,
    // to dev
    output wire [SEG_WIDTH - 1 : 0] dev_segs0,  // pass the bits to segs0
    output wire [SEG_WIDTH - 1 : 0] dev_segs1,  // pass the bits to segs1
    output wire [SEG_WIDTH - 1 : 0] dev_segs2,  // pass the bits to segs2
    output wire [SEG_WIDTH - 1 : 0] dev_segs3,  // pass the bits to segs3
    output wire [SEG_WIDTH - 1 : 0] dev_segs4,  // pass the bits to segs4
    output wire [SEG_WIDTH - 1 : 0] dev_segs5,  // pass the bits to segs5
    output wire [SEG_WIDTH - 1 : 0] dev_segs6,  // pass the bits to segs6
    output wire [SEG_WIDTH - 1 : 0] dev_segs7,  // pass the bits to segs7
    output wire [LED_WIDTH - 1 : 0] dev_leds,   // pass the bits to dev_led

    // to monitor
    output wire [WIDTH - 1 : 0] pc_monitor,
    output wire [WIDTH - 1 : 0] gpr0_monitor,
    output wire [WIDTH - 1 : 0] gpr1_monitor,
    output wire [WIDTH - 1 : 0] gpr2_monitor,
    output wire [WIDTH - 1 : 0] gpr3_monitor
);
    // define wire
    wire [WIDTH - 1 : 0] pc_top;
    wire [WIDTH - 1 : 0] next_pc_top;
    wire [WIDTH - 1 : 0] instruction;

    wire [WIDTH - 1 : 0] rdata1;
    wire [WIDTH - 1 : 0] rdata2;

    wire [ADDR_WIDTH - 1 : 0] raddr1;
    wire [ADDR_WIDTH - 1 : 0] raddr2;
    wire wen;
    wire [ADDR_WIDTH - 1 : 0] waddr;
    wire [WIDTH - 1 : 0] wdata;

    // wire [2 : 0] io_sel;
    wire [IDX_WIDTH - 1 : 0] io_idx;
    wire io_write;
    wire io_valid;
    wire [WIDTH - 1 : 0] dev2host;

    // set the pc monitor
    assign pc_monitor = pc_top;

    // pc instance
    pc_update #(
        .WIDTH(WIDTH)
    ) u_pc (
        .clk(clk),
        .rstn(rstn),
        .pc(pc_top),
        .next_pc(next_pc_top)
        );

    // rom instance
    rom #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) u_rom(
        .addr(pc_top),
        .inst(instruction)
    );

    // gpr instance
    gpr #(
        .WIDTH(WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .N(N)
    ) u_gpr(
        .clk(clk),
        .rstn(rstn),

        .raddr1(raddr1),
        .raddr2(raddr2),
        .rdata1(rdata1),
        .rdata2(rdata2),

        .wen(wen),
        .waddr(waddr),
        .wdata(wdata),

        .gpr0(gpr0_monitor),
        .gpr1(gpr1_monitor),
        .gpr2(gpr2_monitor),
        .gpr3(gpr3_monitor)
    );

    // exec instance
    exec #(
        .WIDTH(WIDTH),    
        .ADDR_WIDTH(ADDR_WIDTH),
        .OP_WIDTH(OP_WIDTH),
        .JUMP_WIDTH(JUMP_WIDTH),
        .IDX_WIDTH(IDX_WIDTH)
    ) u_exec(
        .inst(instruction),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .curr_pc(pc_top),
        .rs1(raddr1),
        .rs2(raddr2),
        .wdata(wdata),
        .wen(wen),
        .rd(waddr),
        .next_pc(next_pc_top),
        // .io_sel(io_sel),
        .io_idx(io_idx),
        .io_write(io_write),
        .io_valid(io_valid),
        .dev2host(dev2host)
    );

    // iodev instance
    iodev #(
        .WIDTH(WIDTH),
        .IDX_WIDTH(IDX_WIDTH),
        .BTN_WIDTH(BTN_WIDTH),
        .SEG_WIDTH(SEG_WIDTH),
        .SW_WIDTH(SW_WIDTH),
        .LED_WIDTH(LED_WIDTH)
    ) u_iodev (
        .clk(clk),
        .rstn(rstn),
        .host2dev(rdata2),
        // .sel(io_sel),
        .idx(io_idx),
        .io_write(io_write),
        .io_valid(io_valid),
        .dev2host(dev2host),

        .dev_btn(dev_btn),
        .dev_sw(dev_sw),
        .dev_segs0(dev_segs0),
        .dev_segs1(dev_segs1),
        .dev_segs2(dev_segs2),
        .dev_segs3(dev_segs3),
        .dev_segs4(dev_segs4),
        .dev_segs5(dev_segs5),
        .dev_segs6(dev_segs6),
        .dev_segs7(dev_segs7),
        .dev_leds(dev_leds)
    );

endmodule
