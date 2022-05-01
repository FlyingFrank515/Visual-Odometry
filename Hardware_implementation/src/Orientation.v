module Orientation_Unit
#(
    parameter WIDTH = 12'd640    
)
(
    input           i_clk,
    input           i_rst_n,
    input [55:0]    i_col0, // up to down

    output [15:0]   o_mx,
    output [15:0]   o_my
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



// ========== Connection ==========
assign o_mx = sum_x_r[6];
assign o_my = sum_y_r[6];

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
    sum_y_w[0] = ((pixel_3x[0] + pixel_2x[1]) + (pixel_1x[2] + 0)) + ((pixel_m1x[4] + pixel_m2x[5]) + pixel_m3x[6]);

    sum_x_w[1] = ((pixel_m2x[0] + pixel_m2x[1]) + (pixel_m2x[2] + pixel_m2x[3])) + ((pixel_m2x[4] + pixel_m2x[5]) + (pixel_m2x[6] + sum_x_r[0]));
    sum_y_w[1] = ((pixel_3x[0] + pixel_2x[1]) + (pixel_1x[2] + 0)) + ((pixel_m1x[4] + pixel_m2x[5]) + (pixel_m3x[6] + sum_y_r[0]));

    sum_x_w[2] = ((pixel_m1x[0] + pixel_m1x[1]) + (pixel_m1x[2] + pixel_m1x[3])) + ((pixel_m1x[4] + pixel_m1x[5]) + (pixel_m1x[6] + sum_x_r[1]));
    sum_y_w[2] = ((pixel_3x[0] + pixel_2x[1]) + (pixel_1x[2] + 0)) + ((pixel_m1x[4] + pixel_m2x[5]) + (pixel_m3x[6] + sum_y_r[1]));    

    sum_x_w[3] = sum_x_r[2];
    sum_y_w[3] = ((pixel_3x[0] + pixel_2x[1]) + (pixel_1x[2] + 0)) + ((pixel_m1x[4] + pixel_m2x[5]) + (pixel_m3x[6] + sum_y_r[2]));   

    sum_x_w[4] = ((pixel_1x[0] + pixel_1x[1]) + (pixel_1x[2] + pixel_1x[3])) + ((pixel_1x[4] + pixel_1x[5]) + (pixel_1x[6] + sum_x_r[3]));
    sum_y_w[4] = ((pixel_3x[0] + pixel_2x[1]) + (pixel_1x[2] + 0)) + ((pixel_m1x[4] + pixel_m2x[5]) + (pixel_m3x[6] + sum_y_r[3]));    

    sum_x_w[5] = ((pixel_2x[0] + pixel_2x[1]) + (pixel_2x[2] + pixel_2x[3])) + ((pixel_2x[4] + pixel_2x[5]) + (pixel_2x[6] + sum_x_r[4]));
    sum_y_w[5] = ((pixel_3x[0] + pixel_2x[1]) + (pixel_1x[2] + 0)) + ((pixel_m1x[4] + pixel_m2x[5]) + (pixel_m3x[6] + sum_y_r[4]));  

    sum_x_w[6] = ((pixel_3x[0] + pixel_3x[1]) + (pixel_3x[2] + pixel_3x[3])) + ((pixel_3x[4] + pixel_3x[5]) + (pixel_3x[6] + sum_x_r[5]));
    sum_y_w[6] = ((pixel_3x[0] + pixel_2x[1]) + (pixel_1x[2] + 0)) + ((pixel_m1x[4] + pixel_m2x[5]) + (pixel_m3x[6] + sum_y_r[5]));  

end
// ========== Sequential Block ==========
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        for(i = 0; i < 7; i = i+1) begin
            sum_x_r[i] <= 0;
            sum_y_r[i] <= 0;
        end
    end
    else begin
        for(i = 0; i < 7; i = i+1) begin
            sum_x_r[i] <= sum_x_w[i];
            sum_y_r[i] <= sum_y_w[i];
        end
    end
end
endmodule