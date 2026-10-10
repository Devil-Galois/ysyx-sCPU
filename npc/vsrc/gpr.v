`timescale 1ns/1ps
module gpr #(
    parameter WIDTH       = 8,
    parameter ADDR_WIDTH  = 2,
    parameter N           = 4
) (
    input wire clk,
    input wire rstn,

    // read
    input wire [ADDR_WIDTH - 1 : 0] raddr1,
    input wire [ADDR_WIDTH - 1 : 0] raddr2,

    output wire [WIDTH - 1 : 0] rdata1,
    output wire [WIDTH - 1 : 0] rdata2,
    //write
    input wire wen,
    input wire [ADDR_WIDTH - 1 : 0] waddr,
    input wire [WIDTH - 1 : 0]  wdata,

    //monitor
    output  wire [WIDTH - 1 : 0] gpr0,
    output  wire [WIDTH - 1 : 0] gpr1,
    output  wire [WIDTH - 1 : 0] gpr2,
    output  wire [WIDTH - 1 : 0] gpr3
);
    // define the gprs
    reg [WIDTH - 1 : 0] gprs [0 : N - 1];
    integer i;

    // write
    always @(posedge clk or negedge rstn)begin
        if(!rstn) begin
            for (i = 0; i < N; i = i + 1)begin
                gprs[i] <= {WIDTH{1'b0}};
            end
        end
        else if (wen)begin
            gprs[waddr] <= wdata;
        end
    end

    assign rdata1 = gprs[raddr1];
    assign rdata2 = gprs[raddr2];
    
    assign gpr0 = gprs[0];
    assign gpr1 = gprs[1];
    assign gpr2 = gprs[2];
    assign gpr3 = gprs[3];
    
endmodule
