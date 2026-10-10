`timescale 1ns/1ps
module sCPU #(
    parameter WIDTH = 8,
    parameter DEPTH = 256,
    parameter N = 4,
    parameter ADDR_WIDTH = 2,
    parameter OP_WIDTH = 2,
    parameter JUMP_WIDTH = 4
)(
    input wire clk,
    input wire rstn,

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
        .JUMP_WIDTH(JUMP_WIDTH)
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
        .next_pc(next_pc_top)
    );

endmodule
