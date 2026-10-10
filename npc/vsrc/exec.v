`timescale 1ns/1ps
module exec #(
    parameter WIDTH = 8,
    parameter ADDR_WIDTH = 2,
    parameter OP_WIDTH = 2,
    parameter JUMP_WIDTH = 4,
    parameter IDX_WIDTH = 3
) (
    input wire [WIDTH - 1 : 0] inst,
    input wire [WIDTH - 1 : 0] rdata1,
    input wire [WIDTH - 1 : 0] rdata2,
    input wire [WIDTH - 1 : 0] curr_pc,

    output wire [ADDR_WIDTH - 1 : 0] rs1,
    output wire [ADDR_WIDTH - 1 : 0] rs2,

    output reg [WIDTH - 1 : 0] wdata,
    output reg wen,

    output reg [ADDR_WIDTH - 1 : 0] rd,
    output reg [WIDTH - 1 : 0] next_pc,
    
    // io interface
    // output reg [2 : 0] io_sel,
    output reg [IDX_WIDTH - 1 : 0] io_idx,
    output reg io_write,
    output reg io_valid,
    input wire [WIDTH - 1 : 0] dev2host
);
    // define instructions
    parameter [OP_WIDTH - 1 : 0] add = 2'b00, li = 2'b10, bner0 = 2'b11, io = 2'b01;
    // split the inst
    wire [OP_WIDTH - 1 : 0] op_code;
    wire [WIDTH - 1 : 0] imm_data;
    wire [JUMP_WIDTH - 1 : 0] jaddr;
    wire [IDX_WIDTH - 1 : 0] idx;
    wire io_bit;
    
    assign op_code = inst[WIDTH - 1 : WIDTH - 2];
    assign imm_data = {{(WIDTH - 2){1'b0}}, inst[WIDTH - 7 : 0]} << {inst[WIDTH - 5 : WIDTH - 6], 1'b0}; // R[rd] = imm << (s<<1)
    assign rs1 = (op_code == bner0) ? 2'b00 : inst[WIDTH - 5 : WIDTH - 6]; // 2'b00 represent gpr0 for bner0
    assign rs2 = (op_code == io) ? inst[WIDTH - 3 : WIDTH - 4] : inst[WIDTH - 7 : WIDTH - 8];
    assign jaddr = inst[WIDTH - 3 : WIDTH - 6];
    assign idx = inst[WIDTH - 6 : WIDTH - 8];
    assign io_bit = inst[WIDTH - 5];

    always @(*)begin
        // initialization
        wen = 1'b0;
        wdata = {WIDTH{1'b0}};
        rd = {ADDR_WIDTH{1'b0}};
        next_pc = curr_pc + 1'b1;
        // io_sel = 3'd0;
        io_idx = {IDX_WIDTH{1'b0}};
        io_write = 1'b0;
        io_valid = 1'b0;
        case(op_code)
            add: begin
                wdata = rdata1 + rdata2;
                wen = 1;
                rd = inst[WIDTH - 3 : WIDTH - 4];
            end
            li : begin
                wdata = imm_data;
                wen = 1;
                rd = inst[WIDTH - 3 : WIDTH - 4];
            end
            bner0: begin
                if(rdata2 != rdata1) // rdata1 from gpr0
                    next_pc = curr_pc + {{(WIDTH - JUMP_WIDTH){jaddr[JUMP_WIDTH - 1]}}, jaddr};
            end
            io:begin
                io_idx = idx;
                io_write = io_bit;
                io_valid = 1'b1;
                if(!io_bit)begin
                    rd = inst[WIDTH - 3 : WIDTH - 4];
                    wdata = dev2host;
                    wen = 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

endmodule
