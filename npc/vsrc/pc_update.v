`timescale 1ns/1ps
module pc_update #(
    parameter WIDTH = 8
) (
    input wire clk,
    input wire rstn,

    output reg [WIDTH - 1 : 0] pc,
    input wire [WIDTH - 1 : 0] next_pc
);
    // refresh pc
    always @(posedge clk or negedge rstn)begin
        if(!rstn)
            pc <= {WIDTH{1'b0}};
        else pc <= next_pc;
    end
    
endmodule
