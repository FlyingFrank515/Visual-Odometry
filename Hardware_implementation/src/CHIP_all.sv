`include "BRIEF_Top.sv"
`include "FAST.sv"
`include "MATCH_Top.sv"

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
    input           i_frame_start, // to frame_start
    input           i_valid,

    // // debug
    // output [9:0]    inspect_coordinate_X,
    // output [9:0]    inspect_coordinate_Y,
    // output [7:0]    inspect_score,
    // output          inspect_flag,
    // output [255:0]  inspect_descriptor,
    // output          inspect_start,
    // output          inspect_end,


    output          o_ready,
    output          o_frame_end,
    output          o_frame_start,
    output          o_valid,
    output [9:0]    o_src_coor_x,
    output [9:0]    o_src_coor_y,
    output [9:0]    o_dst_coor_x,
    output [9:0]    o_dst_coor_y,

    // sram interface -- FAST window
    input [7:0]     FAST_lb_sram_QA [6],
    input [7:0]     FAST_lb_sram_QB [6],
    output          FAST_lb_sram_WENA [6],
    output          FAST_lb_sram_WENB [6],
    output [7:0]    FAST_lb_sram_DA [6],
    output [7:0]    FAST_lb_sram_DB [6],
    output [9:0]    FAST_lb_sram_AA [6],
    output [9:0]    FAST_lb_sram_AB [6],

    // sram interface -- FAST sin, cos delay FIFO
    input [11:0]     FAST_sincos_sram_QA [2],
    input [11:0]     FAST_sincos_sram_QB [2],
    output          FAST_sincos_sram_WENA [2],
    output          FAST_sincos_sram_WENB [2],
    output [11:0]    FAST_sincos_sram_DA [2],
    output [11:0]    FAST_sincos_sram_DB [2],
    output [9:0]    FAST_sincos_sram_AA [2],
    output [9:0]    FAST_sincos_sram_AB [2],

    // sram interface -- FAST NMS FIFO
    input [9:0]     FAST_NMS_sram_QA,
    input [9:0]     FAST_NMS_sram_QB,
    output          FAST_NMS_sram_WENA,
    output          FAST_NMS_sram_WENB,
    output [9:0]    FAST_NMS_sram_DA,
    output [9:0]    FAST_NMS_sram_DB,
    output [9:0]    FAST_NMS_sram_AA,
    output [9:0]    FAST_NMS_sram_AB,

    // sram interface -- BRIEF window
    input [7:0]     BRIEF_lb_sram_QA [30],
    input [7:0]     BRIEF_lb_sram_QB [30],
    output          BRIEF_lb_sram_WENA [30],
    output          BRIEF_lb_sram_WENB [30],
    output [7:0]    BRIEF_lb_sram_DA [30],
    output [7:0]    BRIEF_lb_sram_DB [30],
    output [9:0]    BRIEF_lb_sram_AA [30],
    output [9:0]    BRIEF_lb_sram_AB [30]

    // // sram interface -- BRIEF keypoint buffer
    // input [51:0]     BRIEF_keybuf_sram_QA,
    // input [51:0]     BRIEF_keybuf_sram_QB,
    // output          BRIEF_keybuf_sram_WENA,
    // output          BRIEF_keybuf_sram_WENB,
    // output [51:0]    BRIEF_keybuf_sram_DA,
    // output [51:0]    BRIEF_keybuf_sram_DB,
    // output [6:0]    BRIEF_keybuf_sram_AA,
    // output [6:0]    BRIEF_keybuf_sram_AB
    
);
    // reg delcaration
    // bus1 (between FAST and BRIEF)
    logic [7:0]   bus1_pixel;
    logic [9:0]   bus1_coor_x, bus1_coor_y;
    logic [11:0]  bus1_sin, bus1_cos;
    logic [7:0]   bus1_score;
    logic         bus1_flag, bus1_start, bus1_end;
    logic         bus1_point_valid, bus1_pixel_valid;

    logic [9:0]   bus2_coor_x, bus2_coor_y;
    logic [255:0] bus2_desc;
    logic [7:0] bus2_score;
    logic        bus2_flag, bus2_start, bus2_end;
    logic         bus2_valid;

    // assign inspect_coordinate_X = bus2_coor_x;
    // assign inspect_coordinate_Y = bus2_coor_y;
    // assign inspect_score = bus2_score;
    // assign inspect_descriptor = bus2_desc;
    // assign inspect_flag = bus2_flag;
    // assign inspect_start = bus2_start;
    // assign inspect_end = bus2_end;

    // sram interface
    // logic [7:0]     bus1_sram_QA [0:5];
    // logic [7:0]     bus1_sram_QB [0:5];
    // logic          bus1_sram_WENA [0:5];
    // logic          bus1_sram_WENB [0:5];
    // logic [7:0]    bus1_sram_DA [0:5];
    // logic [7:0]    bus1_sram_DB [0:5];
    // logic [9:0]    bus1_sram_AA [0:5];
    // logic [9:0]    bus1_sram_AB [0:5];

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
        .i_start(i_frame_start),
        .i_valid(i_valid),

        .o_pixel(bus1_pixel),
        .o_pixel_valid(bus1_pixel_valid),
        .o_coordinate_X(bus1_coor_x),
        .o_coordinate_Y(bus1_coor_y),
        .o_cos(bus1_cos),
        .o_sin(bus1_sin),
        .o_score(bus1_score),
        .o_flag(bus1_flag),
        .o_start(bus1_start),
        .o_end(bus1_end),
        .o_point_valid(bus1_point_valid),
        .o_ready(o_ready),

        .FAST_lb_sram_QA(FAST_lb_sram_QA),
        .FAST_lb_sram_QB(FAST_lb_sram_QB),
        .FAST_lb_sram_WENA(FAST_lb_sram_WENA),
        .FAST_lb_sram_WENB(FAST_lb_sram_WENB),
        .FAST_lb_sram_DA(FAST_lb_sram_DA),
        .FAST_lb_sram_DB(FAST_lb_sram_DB),
        .FAST_lb_sram_AA(FAST_lb_sram_AA),
        .FAST_lb_sram_AB(FAST_lb_sram_AB),

        .FAST_sincos_sram_QA(FAST_sincos_sram_QA),
        .FAST_sincos_sram_QB(FAST_sincos_sram_QB),
        .FAST_sincos_sram_WENA(FAST_sincos_sram_WENA),
        .FAST_sincos_sram_WENB(FAST_sincos_sram_WENB),
        .FAST_sincos_sram_DA(FAST_sincos_sram_DA),
        .FAST_sincos_sram_DB(FAST_sincos_sram_DB),
        .FAST_sincos_sram_AA(FAST_sincos_sram_AA),
        .FAST_sincos_sram_AB(FAST_sincos_sram_AB),

        .FAST_NMS_sram_QA(FAST_NMS_sram_QA),
        .FAST_NMS_sram_QB(FAST_NMS_sram_QB),
        .FAST_NMS_sram_WENA(FAST_NMS_sram_WENA),
        .FAST_NMS_sram_WENB(FAST_NMS_sram_WENB),
        .FAST_NMS_sram_DA(FAST_NMS_sram_DA),
        .FAST_NMS_sram_DB(FAST_NMS_sram_DB),
        .FAST_NMS_sram_AA(FAST_NMS_sram_AA),
        .FAST_NMS_sram_AB(FAST_NMS_sram_AB)
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
        .i_point_valid(bus1_point_valid),
        .i_pixel_valid(bus1_pixel_valid),

        .o_coordinate_X(bus2_coor_x),
        .o_coordinate_Y(bus2_coor_y),
        .o_descriptor(bus2_desc),
        .o_score(bus2_score),
        .o_flag(bus2_flag),
        .o_start(bus2_start),
        .o_end(bus2_end),

        .BRIEF_lb_sram_QA(BRIEF_lb_sram_QA),
        .BRIEF_lb_sram_QB(BRIEF_lb_sram_QB),
        .BRIEF_lb_sram_WENA(BRIEF_lb_sram_WENA),
        .BRIEF_lb_sram_WENB(BRIEF_lb_sram_WENB),
        .BRIEF_lb_sram_DA(BRIEF_lb_sram_DA),
        .BRIEF_lb_sram_DB(BRIEF_lb_sram_DB),
        .BRIEF_lb_sram_AA(BRIEF_lb_sram_AA),
        .BRIEF_lb_sram_AB(BRIEF_lb_sram_AB)

        // .BRIEF_keybuf_sram_QA(BRIEF_keybuf_sram_QA),
        // .BRIEF_keybuf_sram_QB(BRIEF_keybuf_sram_QB),
        // .BRIEF_keybuf_sram_WENA(BRIEF_keybuf_sram_WENA),
        // .BRIEF_keybuf_sram_WENB(BRIEF_keybuf_sram_WENB),
        // .BRIEF_keybuf_sram_DA(BRIEF_keybuf_sram_DA),
        // .BRIEF_keybuf_sram_DB(BRIEF_keybuf_sram_DB),
        // .BRIEF_keybuf_sram_AA(BRIEF_keybuf_sram_AA),
        // .BRIEF_keybuf_sram_AB(BRIEF_keybuf_sram_AB)
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
        // .i_valid(bus2_valid),

        .o_frame_end(o_frame_end),
        .o_frame_start(o_frame_start),
        .o_valid(o_valid),
        .o_src_coor_x(o_src_coor_x),
        .o_src_coor_y(o_src_coor_y),
        .o_dst_coor_x(o_dst_coor_x),
        .o_dst_coor_y(o_dst_coor_y)
    );

endmodule