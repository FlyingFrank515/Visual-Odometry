`include "BRIEF_Top.v"
`include "FAST.v"
`include "MATCH_Top.v"

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

    output [9:0]    inspect_coordinate_X,
    output [9:0]    inspect_coordinate_Y,
    output [7:0]    inspect_score,
    output          inspect_flag,
    output [255:0]  inspect_descriptor,
    output          inspect_start,
    output          inspect_end,


    output          o_ready,
    output          o_end,
    output          o_valid,
    output [9:0]    o_src_coor_x,
    output [9:0]    o_src_coor_y,
    output [9:0]    o_dst_coor_x,
    output [9:0]    o_dst_coor_y
    
);
    // reg delcaration
    // bus1 (between FAST and BRIEF)
    wire [7:0]   bus1_pixel;
    wire [9:0]   bus1_coor_x, bus1_coor_y;
    wire [11:0]  bus1_sin, bus1_cos;
    wire [7:0]   bus1_score;
    wire         bus1_flag, bus1_start, bus1_end;

    wire [9:0]   bus2_coor_x, bus2_coor_y;
    wire [255:0] bus2_desc;
    wire [7:0] bus2_score;
    wire        bus2_flag, bus2_start, bus2_end;

    assign inspect_coordinate_X = bus2_coor_x;
    assign inspect_coordinate_Y = bus2_coor_y;
    assign inspect_score = bus2_score;
    assign inspect_descriptor = bus2_desc;
    assign inspect_flag = bus2_flag;
    assign inspect_start = bus2_start;
    assign inspect_end = bus2_end;

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
        .o_end(bus1_end),
        .o_ready(o_ready)
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

        .o_coordinate_X(bus2_coor_x),
        .o_coordinate_Y(bus2_coor_y),
        .o_descriptor(bus2_desc),
        .o_score(bus2_score),
        .o_flag(bus2_flag),
        .o_start(bus2_start),
        .o_end(bus2_end)
    );


    MATCH_Top
    #(
        .BUFFER_SIZE(12'd100),
        .KEY_LEN(12'd500)
    )
    MATCH_unit
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_coordinate_X(bus2_coor_x),
        .i_coordinate_Y(bus2_coor_y),
        .i_descriptor(bus2_desc),
        .i_score(bus2_score),
        .i_flag(bus2_flag),
        .i_start(bus2_start),
        .i_end(bus2_end),
        .o_end(o_end),
        .o_valid(o_valid),
        .o_src_coor_x(o_src_coor_x),
        .o_src_coor_y(o_src_coor_y),
        .o_dst_coor_x(o_dst_coor_x),
        .o_dst_coor_y(o_dst_coor_y)
    );

endmodule