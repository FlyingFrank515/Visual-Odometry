`include "DW_sqrt.v"
`include "DW_div.v"

module Orientation_Unit
#(
    parameter WIDTH = 12'd640    
)
(
    input           i_clk,
    input           i_rst_n,
    input [55:0]    i_col0, // up to down

    output [11:0]   o_cos,
    output [11:0]   o_sin
);

// ========== function declaration ==========

// ========== reg/wire declaration ==========
integer i;
reg signed [15:0] sum_x_r [0:6], sum_x_w [0:6]; // used to store the sum in each stage
reg signed [15:0] sum_y_r [0:6], sum_y_w [0:6]; // used to store the sum in each stage
// reg [7:0] pixel [0:6][0:6]; // pixel[0][0] ... pixel[0][6]
//                             // pixel[1][0] ... pixel[1][6]
//                             // ...
//                             // pixel[6][0] ... pixel[6][6]
// reg signed [10:0] pixel_x [0:6][0:6]; // pixels multiplying delta_x 
// reg signed [10:0] pixel_y [0:6][0:6]; // pixels multiplying delta_x 
reg signed [12:0] pixel_3x [0:6];
reg signed [12:0] pixel_2x [0:6];
reg signed [12:0] pixel_1x [0:6];
reg signed [12:0] pixel_m1x [0:6];
reg signed [12:0] pixel_m2x [0:6];
reg signed [12:0] pixel_m3x [0:6];

// for calculating sin and cos value
// cos = mx/sqrt(mx^2+my^2)
// sin = my/sqrt(mx^2+my^2)

// denominator
reg [15:0] mx_abs_w, mx_abs_r;
reg [15:0] my_abs_w, my_abs_r;
reg [31:0] mx_square_w, mx_square_r;
reg [31:0] my_square_w, my_square_r;
reg [32:0] square_sum_w, square_sum_r;
wire [16:0] sqrt_w;
reg [16:0] sqrt_r;

// numerator
reg mx_signed_1_w, mx_signed_1_r;
reg my_signed_1_w, my_signed_1_r;

reg mx_signed_2_w, mx_signed_2_r;
reg my_signed_2_w, my_signed_2_r;
reg [15:0] mx_abs_2_w, mx_abs_2_r;
reg [15:0] my_abs_2_w, my_abs_2_r;

reg mx_signed_3_w, mx_signed_3_r;
reg my_signed_3_w, my_signed_3_r;
reg [15:0] mx_abs_3_w, mx_abs_3_r;
reg [15:0] my_abs_3_w, my_abs_3_r;

reg mx_signed_4_w, mx_signed_4_r;
reg my_signed_4_w, my_signed_4_r;
reg [15:0] mx_abs_4_w, mx_abs_4_r;
reg [15:0] my_abs_4_w, my_abs_4_r;

reg mx_signed_5_w, mx_signed_5_r;
reg my_signed_5_w, my_signed_5_r;

wire [25:0] cos_abs_w;
reg signed [25:0] cos_abs_r; // >>10 and add sign to get the value
wire [25:0] sin_abs_w;
reg signed [25:0] sin_abs_r; // >>10 and add sign to get the value

reg signed [11:0] cos_w, cos_r;
reg signed [11:0] sin_w, sin_r;


always@(*) begin
    // stage1
    mx_abs_w = sum_x_r[6][15] ? -sum_x_r[6] : sum_x_r[6];
    my_abs_w = sum_y_r[6][15] ? -sum_y_r[6] : sum_y_r[6];

    mx_signed_1_w = sum_x_r[6][15];
    my_signed_1_w = sum_y_r[6][15];

    // stage2    
    mx_square_w = mx_abs_r*mx_abs_r;
    my_square_w = my_abs_r*my_abs_r;
    
    mx_signed_2_w = mx_signed_1_r;
    my_signed_2_w = my_signed_1_r;
    mx_abs_2_w = mx_abs_r;
    my_abs_2_w = my_abs_r;

    // stage3
    square_sum_w = mx_square_r + my_square_r;

    mx_signed_3_w = mx_signed_2_r;
    my_signed_3_w = my_signed_2_r;
    mx_abs_3_w = mx_abs_2_r;
    my_abs_3_w = my_abs_2_r;

    // stage4  (DW_sqrt_inst)
    mx_signed_4_w = mx_signed_3_r;
    my_signed_4_w = my_signed_3_r;
    mx_abs_4_w = mx_abs_3_r;
    my_abs_4_w = my_abs_3_r;

    // stage5 (DW_div_inst)
    mx_signed_5_w = mx_signed_4_r;
    my_signed_5_w = my_signed_4_r; 

    // stage6 (bit-choice and sign)
    cos_w = mx_signed_5_r ? -cos_abs_r[10:0] : cos_abs_r[10:0];
    sin_w = my_signed_5_r ? -sin_abs_r[10:0] : sin_abs_r[10:0];


end

DW_div_inst #(26, 0, 0) UX (.a({mx_abs_4_r, 10'd0}), .b({9'd0, sqrt_r}), .quotient(cos_abs_w), .remainder(), .divide_by_0());
DW_div_inst #(26, 0, 0) UY (.a({my_abs_4_r, 10'd0}), .b({9'd0, sqrt_r}), .quotient(sin_abs_w), .remainder(), .divide_by_0());
DW_sqrt_inst #(33, 0) U1 (.radicand(square_sum_r), .square_root(sqrt_w));

// ========== Connection ==========
assign o_cos = cos_r;
assign o_sin = sin_r;

always@(*) begin
    for(i = 0; i < 7; i = i+1) begin
        pixel_1x[i] = $signed({1'b0, i_col0[i*8 +: 8]});
        pixel_2x[i] = pixel_1x[i] << 1;
        pixel_3x[i] = (pixel_1x[i] << 1) + pixel_1x[i];
        pixel_m1x[i] = -pixel_1x[i];
        pixel_m2x[i] = -pixel_2x[i];
        pixel_m3x[i] = -pixel_3x[i];
    end
end

// ========== Combinational Block ==========
always@(*) begin
    sum_x_w[0] = ((pixel_m3x[0] + pixel_m3x[1]) + (pixel_m3x[2] + pixel_m3x[3])) + ((pixel_m3x[4] + pixel_m3x[5]) + pixel_m3x[6]);
    sum_y_w[0] = ((pixel_m3x[0] + pixel_m2x[1]) + (pixel_m1x[2] + 0)) + ((pixel_1x[4] + pixel_2x[5]) + pixel_3x[6]);

    sum_x_w[1] = ((pixel_m2x[0] + pixel_m2x[1]) + (pixel_m2x[2] + pixel_m2x[3])) + ((pixel_m2x[4] + pixel_m2x[5]) + (pixel_m2x[6] + sum_x_r[0]));
    sum_y_w[1] = ((pixel_m3x[0] + pixel_m2x[1]) + (pixel_m1x[2] + 0)) + ((pixel_1x[4] + pixel_2x[5]) + (pixel_3x[6] + sum_y_r[0]));

    sum_x_w[2] = ((pixel_m1x[0] + pixel_m1x[1]) + (pixel_m1x[2] + pixel_m1x[3])) + ((pixel_m1x[4] + pixel_m1x[5]) + (pixel_m1x[6] + sum_x_r[1]));
    sum_y_w[2] = ((pixel_m3x[0] + pixel_m2x[1]) + (pixel_m1x[2] + 0)) + ((pixel_1x[4] + pixel_2x[5]) + (pixel_3x[6] + sum_y_r[1]));    

    sum_x_w[3] = sum_x_r[2];
    sum_y_w[3] = ((pixel_m3x[0] + pixel_m2x[1]) + (pixel_m1x[2] + 0)) + ((pixel_1x[4] + pixel_2x[5]) + (pixel_3x[6] + sum_y_r[2]));   

    sum_x_w[4] = ((pixel_1x[0] + pixel_1x[1]) + (pixel_1x[2] + pixel_1x[3])) + ((pixel_1x[4] + pixel_1x[5]) + (pixel_1x[6] + sum_x_r[3]));
    sum_y_w[4] = ((pixel_m3x[0] + pixel_m2x[1]) + (pixel_m1x[2] + 0)) + ((pixel_1x[4] + pixel_2x[5]) + (pixel_3x[6] + sum_y_r[3]));    

    sum_x_w[5] = ((pixel_2x[0] + pixel_2x[1]) + (pixel_2x[2] + pixel_2x[3])) + ((pixel_2x[4] + pixel_2x[5]) + (pixel_2x[6] + sum_x_r[4]));
    sum_y_w[5] = ((pixel_m3x[0] + pixel_m2x[1]) + (pixel_m1x[2] + 0)) + ((pixel_1x[4] + pixel_2x[5]) + (pixel_3x[6] + sum_y_r[4]));  

    sum_x_w[6] = ((pixel_3x[0] + pixel_3x[1]) + (pixel_3x[2] + pixel_3x[3])) + ((pixel_3x[4] + pixel_3x[5]) + (pixel_3x[6] + sum_x_r[5]));
    sum_y_w[6] = ((pixel_m3x[0] + pixel_m2x[1]) + (pixel_m1x[2] + 0)) + ((pixel_1x[4] + pixel_2x[5]) + (pixel_3x[6] + sum_y_r[5]));  

end
// ========== Sequential Block ==========
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        mx_abs_r <= 0;
        my_abs_r <= 0;

        mx_signed_1_r <= 0;
        my_signed_1_r <= 0;

        // stage2    
        mx_square_r <= 0;
        my_square_r <= 0; 
        mx_signed_2_r <= 0;
        my_signed_2_r <= 0;
        mx_abs_2_r <= 0;
        my_abs_2_r <= 0;

        // stage3
        square_sum_r <= 0;
        mx_signed_3_r <= 0;
        my_signed_3_r <= 0;
        mx_abs_3_r <= 0;
        my_abs_3_r <= 0;

        // stage4  (Dr_sqrt_inst)
        mx_signed_4_r <= 0;
        my_signed_4_r <= 0;
        mx_abs_4_r <= 0;
        my_abs_4_r <= 0;
        sqrt_r <= 0;

        // stage5 (Dr_div_inst)
        mx_signed_5_r <= 0;
        my_signed_5_r <= 0; 
        cos_abs_r <= 0;
        sin_abs_r <= 0;

        // stage6
        cos_r <= 0;
        sin_r <= 0;

        for(i = 0; i < 7; i = i+1) begin
            sum_x_r[i] <= 0;
            sum_y_r[i] <= 0;
        end
    end
    else begin
        mx_abs_r <= mx_abs_w;
        my_abs_r <= my_abs_w;

        mx_signed_1_r <= mx_signed_1_w;
        my_signed_1_r <= my_signed_1_w;

        // stage2    
        mx_square_r <= mx_square_w;
        my_square_r <= my_square_w; 
        mx_signed_2_r <= mx_signed_2_w;
        my_signed_2_r <= my_signed_2_w;
        mx_abs_2_r <= mx_abs_2_w;
        my_abs_2_r <= my_abs_2_w;

        // stage3
        square_sum_r <= square_sum_w;
        mx_signed_3_r <= mx_signed_3_w;
        my_signed_3_r <= my_signed_3_w;
        mx_abs_3_r <= mx_abs_3_w;
        my_abs_3_r <= my_abs_3_w;

        // stage4  (Dr_sqrt_inst)
        mx_signed_4_r <= mx_signed_4_w;
        my_signed_4_r <= my_signed_4_w;
        mx_abs_4_r <= mx_abs_4_w;
        my_abs_4_r <= my_abs_4_w;
        sqrt_r <= sqrt_w;

        // stage5 (Dr_div_inst)
        mx_signed_5_r <= mx_signed_5_w;
        my_signed_5_r <= my_signed_5_w; 
        cos_abs_r <= cos_abs_w;
        sin_abs_r <= sin_abs_w;

        // stage6
        cos_r <= cos_w;
        sin_r <= sin_w;

        for(i = 0; i < 7; i = i+1) begin
            sum_x_r[i] <= sum_x_w[i];
            sum_y_r[i] <= sum_y_w[i];
        end
    end
end
endmodule