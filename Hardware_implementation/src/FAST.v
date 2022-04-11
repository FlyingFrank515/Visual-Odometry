module FAST_Detector
#(
    parameter WIDTH = 12'd640;
    parameter HEIGHT = 12'd480;
)
(
    input           i_clk,
    input           i_rst_n,
    input [7:0]     i_pixel,

    output [7:0]    o_pixel,
    output [9:0]    o_coordinate_X,
    output [9:0]    o_coordinate_Y,

    output [9:0]    o_orientation,
    output [7:0]    o_score,
    output          o_valid,

);
endmodule