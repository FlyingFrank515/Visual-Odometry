`include "MATCH.sv"
`include "Key_Buffer2.sv"
`include "MATCH_mem.sv"

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
    input [15:0]     i_depth,
    input           i_flag,
    input           i_start,
    input           i_end,

    output          o_frame_end,
    output          o_frame_start,
    output          o_valid,
    output [9:0]    o_src_coor_x,
    output [9:0]    o_src_coor_y,
    output [15:0]    o_src_depth,
    output [9:0]    o_dst_coor_x,
    output [9:0]    o_dst_coor_y,
    output [15:0]    o_dst_depth,

    input [19:0]    MATCH_mem1_point_QA,
    output          MATCH_mem1_point_WENA,
    output [19:0]   MATCH_mem1_point_DA,
    output [8:0]    MATCH_mem1_point_AA,

    input [19:0]    MATCH_mem2_point_QA,
    output          MATCH_mem2_point_WENA,
    output [19:0]   MATCH_mem2_point_DA,
    output [8:0]    MATCH_mem2_point_AA,

    input [15:0]    MATCH_mem1_depth_QA,
    output          MATCH_mem1_depth_WENA,
    output [15:0]   MATCH_mem1_depth_DA,
    output [8:0]    MATCH_mem1_depth_AA,

    input [15:0]    MATCH_mem2_depth_QA,
    output          MATCH_mem2_depth_WENA,
    output [15:0]   MATCH_mem2_depth_DA,
    output [8:0]    MATCH_mem2_depth_AA,

    input [31:0]    MATCH_mem1_desc_QA [8],
    output          MATCH_mem1_desc_WENA [8],
    output [31:0]   MATCH_mem1_desc_DA [8],
    output [8:0]    MATCH_mem1_desc_AA [8],

    input [31:0]    MATCH_mem2_desc_QA [8],
    output          MATCH_mem2_desc_WENA [8],
    output [31:0]   MATCH_mem2_desc_DA [8],
    output [8:0]    MATCH_mem2_desc_AA [8]
);

    logic  [9:0]     BUFFER_coor_x; 
    logic  [9:0]     BUFFER_coor_y;
    logic  [15:0]     BUFFER_depth;
    logic  [7:0]     BUFFER_score;
    logic  [255:0]   BUFFER_descriptor;
    logic            BUFFER_flag;

    logic            MATCH_next;

    // to memory controller
    logic [10:0]   mem_bus1_addr;
    logic [291:0]  mem_bus1_wdata;
    logic          mem_bus1_wen;
    logic [291:0]   mem_bus1_rdata;

    logic [10:0]   mem_bus2_addr;
    logic [291:0]  mem_bus2_wdata;
    logic          mem_bus2_wen;
    logic [291:0]   mem_bus2_rdata;

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
        .o_dst_depth(o_dst_depth),

        // to memory controller
        .mem1_addr(mem_bus1_addr),
        .mem1_wdata(mem_bus1_wdata),
        .mem1_wen(mem_bus1_wen),
        .mem1_rdata(mem_bus1_rdata),
        .mem2_addr(mem_bus2_addr),
        .mem2_wdata(mem_bus2_wdata),
        .mem2_wen(mem_bus2_wen),
        .mem2_rdata(mem_bus2_rdata)
    );

    MATCH_mem u_match_mem_controller
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),

        // to memory controller
        .mem1_addr(mem_bus1_addr),
        .mem1_wdata(mem_bus1_wdata),
        .mem1_wen(mem_bus1_wen),
        .mem1_rdata(mem_bus1_rdata),
        .mem2_addr(mem_bus2_addr),
        .mem2_wdata(mem_bus2_wdata),
        .mem2_wen(mem_bus2_wen),
        .mem2_rdata(mem_bus2_rdata),

        // sram interface
        .MATCH_mem1_point_QA(MATCH_mem1_point_QA),
        .MATCH_mem1_point_WENA(MATCH_mem1_point_WENA),
        .MATCH_mem1_point_DA(MATCH_mem1_point_DA),
        .MATCH_mem1_point_AA(MATCH_mem1_point_AA),

        .MATCH_mem2_point_QA(MATCH_mem2_point_QA),
        .MATCH_mem2_point_WENA(MATCH_mem2_point_WENA),
        .MATCH_mem2_point_DA(MATCH_mem2_point_DA),
        .MATCH_mem2_point_AA(MATCH_mem2_point_AA),

        .MATCH_mem1_depth_QA(MATCH_mem1_depth_QA),
        .MATCH_mem1_depth_WENA(MATCH_mem1_depth_WENA),
        .MATCH_mem1_depth_DA(MATCH_mem1_depth_DA),
        .MATCH_mem1_depth_AA(MATCH_mem1_depth_AA),

        .MATCH_mem2_depth_QA(MATCH_mem2_depth_QA),
        .MATCH_mem2_depth_WENA(MATCH_mem2_depth_WENA),
        .MATCH_mem2_depth_DA(MATCH_mem2_depth_DA),
        .MATCH_mem2_depth_AA(MATCH_mem2_depth_AA),

        .MATCH_mem1_desc_QA(MATCH_mem1_desc_QA),
        .MATCH_mem1_desc_WENA(MATCH_mem1_desc_WENA),
        .MATCH_mem1_desc_DA(MATCH_mem1_desc_DA),
        .MATCH_mem1_desc_AA(MATCH_mem1_desc_AA),

        .MATCH_mem2_desc_QA(MATCH_mem2_desc_QA),
        .MATCH_mem2_desc_WENA(MATCH_mem2_desc_WENA),
        .MATCH_mem2_desc_DA(MATCH_mem2_desc_DA),
        .MATCH_mem2_desc_AA(MATCH_mem2_desc_AA)
    ); 

endmodule
