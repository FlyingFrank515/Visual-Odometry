module SMOOTH
#(
    parameter WIDTH = 12'd640    
)
(
    input           i_clk,
    input           i_rst_n,
    input [39:0]    i_col0, // up to down

    output [7:0]    o_pixel
);

// ========== function declaration ==========

// ========== reg/wire declaration ==========
integer i;
reg [16:0] sum_r [0:4], sum_w [0:4]; // used to store the sum in each stage
reg [7:0] pixel [0:4];

always@(*) begin
    pixel[0] = i_col0[39:32];
    pixel[1] = i_col0[31:24];
    pixel[2] = i_col0[23:16];
    pixel[3] = i_col0[15:8];
    pixel[4] = i_col0[7:0];
end



// ========== Connection ==========
assign o_pixel = sum_r[4][15:8];

// ========== Combinational Block ==========
always@(*) begin
    // 1 4 6 4 1
    sum_w[0] = (pixel[0] + pixel[1] << 2) + (pixel[2] << 2 + pixel[2] << 1) + (pixel[3] << 2 + pixel[4]);
    // 4 16 24 16 4
    sum_w[1] = ((pixel[0] << 2 + pixel[1] << 4) + (pixel[2] << 4 + pixel[2] << 3)) + ((pixel[3] << 4 + pixel[4] << 2) + sum_r[0]); 
    // 6 24 36 24 6
    sum_w[2] = ((pixel[0] << 2 + pixel[0] << 1 + pixel[1] << 4 + pixel[1] << 3) + (pixel[2] << 5 + pixel[2] << 2)) + ((pixel[4] << 2 + pixel[4] << 1 + pixel[3] << 4 + pixel[3] << 3) + sum_r[1]); 
    // 4 16 24 16 4
    sum_w[3] = ((pixel[0] << 2 + pixel[1] << 4) + (pixel[2] << 4 + pixel[2] << 3)) + ((pixel[3] << 4 + pixel[4] << 2) + sum_r[2]); 
    // 1 4 6 4 1
    sum_w[4] = (pixel[0] + pixel[1] << 2) + (pixel[2] << 2 + pixel[2] << 1) + (pixel[3] << 2 + pixel[4]) + sum_r_[3];

end
// ========== Sequential Block ==========
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        for(i = 0; i < 5; i = i+1) begin
            sum_r[i] <= 0;
        end
    end
    else begin
        for(i = 0; i < 5; i = i+1) begin
            sum_r[i] <= sum_w[i];
        end
    end
end
endmodule