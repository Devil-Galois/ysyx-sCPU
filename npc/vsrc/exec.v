`timescale 1ns/1ps
module exec #(
    parameter WIDTH = 8,
    parameter ADDR_WIDTH = 2,
    parameter OP_WIDTH = 2,
    parameter JUMP_WIDTH = 4
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
    output reg [WIDTH - 1 : 0] next_pc
);
    // define instructions
    parameter [OP_WIDTH - 1 : 0] add = 2'b00, li = 2'b10, bner0 = 2'b11;
    // split the inst
    wire [OP_WIDTH - 1 : 0] op_code;
    wire [WIDTH - 1 : 0] imm_data;
    wire [JUMP_WIDTH - 1 : 0] jaddr;
    
    assign op_code = inst[WIDTH - 1 : WIDTH - 2];
    assign imm_data = {{(WIDTH - 2){1'b0}}, inst[WIDTH - 7 : 0]} << {inst[WIDTH - 5 : WIDTH - 6], 1'b0}; // R[rd] = imm << (s<<1)
    assign rs1 = (op_code == bner0) ? 2'b00 : inst[WIDTH - 5 : WIDTH - 6]; // 2'b00 represent gpr0 for bner0
    assign rs2 = inst[WIDTH - 7 : WIDTH - 8];
    assign jaddr = inst[WIDTH - 3 : WIDTH - 6];

    always @(*)begin
        // initialization
        wen = 1'b0;
        wdata = {WIDTH{1'b0}};
        rd = {ADDR_WIDTH{1'b0}};
        next_pc = curr_pc + 1'b1;
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
            default: begin
            end
        endcase
    end

endmodule
