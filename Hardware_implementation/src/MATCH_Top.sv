`include "MATCH.sv"
`include "Key_Buffer2.sv"

module MATCH_Top
#(
    parameter BUFFER_SIZE = 12'd100,
    parameter KEY_LEN = 12'd500
)
(
    input           i_clk,
    input           i_rst_n,

    input [9:0]     i_coordinate_X,
    input [9:0]     i_coordinate_Y,
    input [255:0]   i_descriptor,
    input [7:0]     i_score,
    input [9:0]     i_depth,
    input           i_flag,
    input           i_start,
    input           i_end,

    output          o_frame_end,
    output          o_frame_start,
    output          o_valid,
    output [9:0]    o_src_coor_x,
    output [9:0]    o_src_coor_y,
    output [9:0]    o_src_depth,
    output [9:0]    o_dst_coor_x,
    output [9:0]    o_dst_coor_y,
    output [9:0]    o_dst_depth
);

    logic  [9:0]     BUFFER_coor_x; 
    logic  [9:0]     BUFFER_coor_y;
    logic  [9:0]     BUFFER_depth;
    logic  [7:0]     BUFFER_score;
    logic  [255:0]   BUFFER_descriptor;
    logic            BUFFER_flag;

    logic            MATCH_next;

    Key_Buffer2
    #(
        .SIZE(BUFFER_SIZE)
    )
    buffer
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_next(MATCH_next),
        .i_valid(i_flag),
    
        .i_coor_x(i_coordinate_X), 
        .i_coor_y(i_coordinate_Y), 
        .i_score(i_score),
        .i_descriptor(i_descriptor),
        .i_depth(i_depth),

        .o_coor_x(BUFFER_coor_x), 
        .o_coor_y(BUFFER_coor_y),
        .o_score(BUFFER_score),
        .o_descriptor(BUFFER_descriptor),
        .o_flag(BUFFER_flag),
        .o_depth(BUFFER_depth)
    );

    MATCH
    #(
        .SIZE(KEY_LEN)
    )
    MATCH_unit
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_flag(BUFFER_flag),
        .i_end(i_end),
        .i_coor_x(BUFFER_coor_x), 
        .i_coor_y(BUFFER_coor_y),
        .i_score(BUFFER_score),
        .i_descriptor(BUFFER_descriptor),
        .i_depth(BUFFER_depth),

        .o_next(MATCH_next),
        .o_frame_end(o_frame_end),
        .o_frame_start(o_frame_start),
        .o_valid(o_valid),
        .o_src_coor_x(o_src_coor_x),
        .o_src_coor_y(o_src_coor_y),
        .o_src_depth(o_src_depth),
        .o_dst_coor_x(o_dst_coor_x),
        .o_dst_coor_y(o_dst_coor_y),
        .o_dst_depth(o_dst_depth)
    );

endmodule
