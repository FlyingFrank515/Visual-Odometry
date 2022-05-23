`include "BRIEF_Top.v"
`include "FAST.v"

module CHIP
#(
    parameter WIDTH = 12'd640,
    parameter HEIGHT = 12'd480,
    parameter EDGE = 12'd31
)
(
    input           i_clk,
    input           i_rst_n,
    input [7:0]     i_pixel,
    input           i_start,

    output [9:0]    o_coordinate_X,
    output [9:0]    o_coordinate_Y,

    output [7:0]    o_score,
    output          o_flag,
    output [255:0]  o_descriptor,
    output          o_start,
    output          o_end

);
    // reg delcaration
    // bus1 (between FAST and BRIEF)
    wire [7:0]   bus1_pixel;
    wire [9:0]   bus1_coor_x, bus1_coor_y;
    wire [11:0]  bus1_sin, bus1_cos;
    wire [7:0]   bus1_score;
    wire         bus1_flag, bus1_start, bus1_end;



    FAST_Detector
    #(
        .WIDTH(12'd640),
        .HEIGHT(12'd480),
        .EDGE(6'd31)
    )
    FAST_unit
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_pixel(i_pixel),
        .i_start(i_start),

        .o_pixel(bus1_pixel),
        .o_coordinate_X(bus1_coor_x),
        .o_coordinate_Y(bus1_coor_y),
        .o_cos(bus1_cos),
        .o_sin(bus1_sin),
        .o_score(bus1_score),
        .o_flag(bus1_flag),
        .o_start(bus1_start),
        .o_end(bus1_end)
    );

    BRIEF_Top
    #(
        .WIDTH(12'd640),
        .HEIGHT(12'd480)
    )
    BRIEF_unit
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),

        .i_pixel(bus1_pixel),
        .i_start(bus1_start),
        .i_end(bus1_end),
        .i_flag(bus1_flag),
        .i_sin(bus1_sin),
        .i_cos(bus1_cos),
        .i_coor_x(bus1_coor_x), 
        .i_coor_y(bus1_coor_y), 
        .i_score(bus1_score),

        .o_coordinate_X(o_coordinate_X),
        .o_coordinate_Y(o_coordinate_Y),
        .o_descriptor(o_descriptor),
        .o_score(o_score),
        .o_flag(o_flag),
        .o_start(o_start),
        .o_end(o_end)
    );

endmodule