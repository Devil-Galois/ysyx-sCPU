// memory to store the program
`timescale 1ns/1ps
module rom #(
    WIDTH = 8,
    DEPTH = 256
) (
    input   wire [WIDTH - 1 : 0] addr,
    output  wire [WIDTH - 1 : 0] inst
);

    reg [WIDTH - 1 : 0] mem [0 : DEPTH - 1];

    initial begin
        $readmemh("program.hex", mem);
    end

    assign inst = mem[addr];
    
endmodule
