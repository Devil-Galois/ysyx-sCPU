`timescale 1ns/1ps
module iodev #(
    parameter WIDTH = 8,
    parameter IDX_WIDTH = 3,
    parameter BTN_WIDTH = 5, 
    parameter SEG_WIDTH = 8,
    parameter SW_WIDTH = 8,  
    parameter LED_WIDTH = 16 
) (
    input wire clk,    // clk from sCPU
    input wire rstn,   // system rstn
    // host control interface
    input wire [WIDTH - 1 : 0] host2dev,   // host writes to dev
    // input wire [2 : 0] sel,                // 
    input wire [IDX_WIDTH - 1 : 0] idx,    // dev idx
    input wire io_write,                   // io_write = 1: host2dev io_write = 0: dev2host
    input wire io_valid,
    output reg [WIDTH - 1 : 0] dev2host,   // read from dev

    // dev control interface
    // from dev to host
    input wire [BTN_WIDTH - 1 : 0] dev_btn,     // btn pass the bits to host
    input wire [SW_WIDTH - 1 : 0] dev_sw,       // sw pass the bits to host
    // segs wire
    output wire [SEG_WIDTH - 1 : 0] dev_segs0,  // pass the bits to segs0
    output wire [SEG_WIDTH - 1 : 0] dev_segs1,  // pass the bits to segs1
    output wire [SEG_WIDTH - 1 : 0] dev_segs2,  // pass the bits to segs2
    output wire [SEG_WIDTH - 1 : 0] dev_segs3,  // pass the bits to segs3
    output wire [SEG_WIDTH - 1 : 0] dev_segs4,  // pass the bits to segs4
    output wire [SEG_WIDTH - 1 : 0] dev_segs5,  // pass the bits to segs5
    output wire [SEG_WIDTH - 1 : 0] dev_segs6,  // pass the bits to segs6
    output wire [SEG_WIDTH - 1 : 0] dev_segs7,  // pass the bits to segs7
    // ledr
    output wire [LED_WIDTH - 1 : 0] dev_leds    // pass the bits to dev_led
);
    parameter [IDX_WIDTH :0] DEV_LED_LOW = 4'b1000, DEV_SEG = 4'b1001, DEV_SW = 4'b0000, DEV_BTN = 4'b0001, DEV_LED_HIGH = 4'b1010;
    // reg for segs and leds
    reg [LED_WIDTH - 1 : 0] reg_leds;
    reg [WIDTH - 1 : 0] display_value;
    always @(posedge clk or negedge rstn)begin
        if(!rstn) begin
            reg_leds <= {LED_WIDTH{1'b0}};
            display_value <= {WIDTH{1'b0}};
        end
        else if(io_valid && io_write)begin
            case({io_write,idx})
                DEV_LED_LOW: begin
                    reg_leds[WIDTH - 1 : 0] <= host2dev;
                end
                DEV_SEG: begin
                    display_value <= host2dev;
                end
                DEV_LED_HIGH:begin
                    reg_leds[LED_WIDTH - 1 : LED_WIDTH - WIDTH] <= host2dev;
                end
                default:;
            endcase
        end
    end

    always @(*) begin
        dev2host = {WIDTH{1'b0}};
        if(io_valid && !io_write)begin
            case({io_write, idx})
            DEV_SW: dev2host = dev_sw;
            DEV_BTN: dev2host = {{(WIDTH - BTN_WIDTH){1'b0}}, dev_btn};
            default: dev2host = {WIDTH{1'b0}};
            endcase
        end
    end

    function [SEG_WIDTH - 1 : 0] digit_to_seg;
        input [WIDTH - 1 : 0] digit;
        begin
            case(digit)
                8'd0: digit_to_seg = 8'h03;
                8'd1: digit_to_seg = 8'h9f;
                8'd2: digit_to_seg = 8'h25;
                8'd3: digit_to_seg = 8'h0d;
                8'd4: digit_to_seg = 8'h99;
                8'd5: digit_to_seg = 8'h49;
                8'd6: digit_to_seg = 8'h41;
                8'd7: digit_to_seg = 8'h1f;
                8'd8: digit_to_seg = 8'h01;
                8'd9: digit_to_seg = 8'h09;
                default: digit_to_seg = 8'hff;
            endcase
        end
    endfunction
    
    wire [WIDTH - 1 : 0] ones;
    wire [WIDTH - 1 : 0] tens;

    assign ones = display_value % 8'd10;
    assign tens = display_value / 8'd10;

    assign dev_leds = reg_leds;
    assign dev_segs0 = digit_to_seg(ones);
    assign dev_segs1 = (display_value < 8'd10) ? {WIDTH{1'b1}} : digit_to_seg(tens);
    assign dev_segs2 = {SEG_WIDTH{1'b1}};
    assign dev_segs3 = {SEG_WIDTH{1'b1}};
    assign dev_segs4 = {SEG_WIDTH{1'b1}};
    assign dev_segs5 = {SEG_WIDTH{1'b1}};
    assign dev_segs6 = {SEG_WIDTH{1'b1}};
    assign dev_segs7 = {SEG_WIDTH{1'b1}};
    
endmodule
