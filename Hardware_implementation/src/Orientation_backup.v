module Orientation_Unit
#(
    parameter WIDTH = 12'd640;    
)
(
    input           i_clk,
    input           i_rst_n,
    input [55:0]    i_col0, // down to up
    input [55:0]    i_col1,
    input [55:0]    i_col2,
    input [55:0]    i_col3,
    input [55:0]    i_col4,
    input [55:0]    i_col5,
    input [55:0]    i_col6,

    output [12:0]   o_mx,
    output [12:0]   o_my,
);

// ========== function declaration ==========

// ========== reg/wire declaration ==========
integer i;
reg signed [12:0] sum_x_r [0:5], sum_x_w [0:5]; // used to store the sum in each stage
reg signed [12:0] sum_y_r [0:5], sum_y_w [0:5]; // used to store the sum in each stage
reg [7:0] pixel [0:6][0:6]; // pixel[0][0] ... pixel[0][6]
                            // pixel[1][0] ... pixel[1][6]
                            // ...
                            // pixel[6][0] ... pixel[6][6]
reg signed [10:0] pixel_x [0:6][0:6]; // pixels multiplying delta_x 
reg signed [10:0] pixel_y [0:6][0:6]; // pixels multiplying delta_x 


// ========== Connection ==========
always@(*) begin
    // connect input to pixel table
    for(i = 0; i < 7; i = i+1) begin
        pixel[i][0] = i_col0[i*8:i*8+7];
        pixel[i][1] = i_col1[i*8:i*8+7];
        pixel[i][2] = i_col2[i*8:i*8+7];
        pixel[i][3] = i_col3[i*8:i*8+7];
        pixel[i][4] = i_col4[i*8:i*8+7];
        pixel[i][5] = i_col5[i*8:i*8+7];
        pixel[i][6] = i_col6[i*8:i*8+7];
    end
    // pixels multiplying delta_x 
    for(i = 0; i < 7; i = i+1) begin
        pixel_x[i][0] = -(pixel[i][0] << 1 + pixel[i][0]); // *-3
        pixel_x[i][1] = -(pixel[i][1] << 1); // *-2
        pixel_x[i][2] = -pixel[i][2];
        pixel_x[i][3] = 0;
        pixel_x[i][4] = pixel[i][4];
        pixel_x[i][5] = pixel[i][5] << 1;
        pixel_x[i][6] = pixel[i][6] << 1 + pixel[i][6];
    end
    // pixels multiplying delta_y
    for(i = 0; i < 7; i = i+1) begin
        pixel_y[0][i] = -(pixel[0][i] << 1 + pixel[0][i]); // *-3
        pixel_y[1][i] = -(pixel[1][i] << 1); // *-2
        pixel_y[2][i] = -pixel[2][i];
        pixel_y[3][i] = 0;
        pixel_y[4][i] = pixel[4][i];
        pixel_y[5][i] = pixel[5][i] << 1;
        pixel_y[6][i] = pixel[6][i] << 1 + pixel[6][i];
    end
end

// ========== Combinational Block ==========
always@(*) begin
    sum_x_w[0] = ((pixel_x[0][0] + pixel_x[1][0]) + (pixel_x[2][0] + pixel_x[3][0])) + ((pixel_x[4][0] + pixel_x[5][0]) + pixel_x[6][0]);
    sum_y_w[0] = ((pixel_y[0][0] + pixel_y[1][0]) + (pixel_y[2][0] + pixel_y[3][0])) + ((pixel_y[4][0] + pixel_y[5][0]) + pixel_y[6][0]);
    for(i = 1; i < 7; i = i+1) begin
        sum_x_w[i] = ((pixel_x[0][i] + pixel_x[1][i]) + (pixel_x[2][i] + pixel_x[3][i])) + ((pixel_x[4][i] + pixel_x[5][i]) + (pixel_x[6][i] + sum_x_r[i-1]));
        sum_y_w[i] = ((pixel_y[0][i] + pixel_y[1][i]) + (pixel_y[2][i] + pixel_y[3][i])) + ((pixel_y[4][i] + pixel_y[5][i]) + (pixel_y[6][i] + sum_y_r[i-1]));
    end
    
end
// ========== Sequential Block ==========
always@(posedge i_clk) begin
    if(!i_rst_n) begin

    end
    else begin
    end
end
endmodule