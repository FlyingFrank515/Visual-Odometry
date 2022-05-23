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
reg [16:0] col [0:2][0:4];
reg [7:0] o_pixel_r, o_pixel_w;
assign o_pixel = o_pixel_r;

always@(*) begin
    pixel[0] = i_col0[39:32];
    pixel[1] = i_col0[31:24];
    pixel[2] = i_col0[23:16];
    pixel[3] = i_col0[15:8];
    pixel[4] = i_col0[7:0];
end

always@(*) begin
    col[0][0] = pixel[0];
    col[0][1] = {7'd0, pixel[1], 2'd0};
    col[0][2] = {7'd0, pixel[2], 2'd0} + {8'd0, pixel[2], 1'd0};
    col[0][3] = {7'd0, pixel[3], 2'd0};
    col[0][4] = pixel[4];
    
    col[1][0] = {7'd0, pixel[0], 2'd0};
    col[1][1] = {3'd0, pixel[1], 4'd0};
    col[1][2] = {5'd0, pixel[2], 4'd0} + {6'd0, pixel[2], 3'd0};
    col[1][3] = {3'd0, pixel[3], 4'd0};
    col[1][4] = {7'd0, pixel[4], 2'd0};
    
    col[2][0] = {7'd0, pixel[0], 2'd0} + {8'd0, pixel[0], 1'd0};
    col[2][1] = {5'd0, pixel[1], 4'd0} + {6'd0, pixel[1], 3'd0};
    col[2][2] = {4'd0, pixel[2], 5'd0} + {7'd0, pixel[2], 2'd0};
    col[2][3] = {5'd0, pixel[3], 4'd0} + {6'd0, pixel[3], 3'd0};
    col[2][4] = {7'd0, pixel[4], 2'd0} + {8'd0, pixel[4], 1'd0};
end



// ========== Connection ==========

// ========== Combinational Block ==========
always@(*) begin
    // 1 4 6 4 1
    sum_w[0] = (col[0][0] + col[0][1]) + (col[0][2] + col[0][3]) + (col[0][4]);
    // 4 16 24 16 4
    sum_w[1] = (col[1][0] + col[1][1]) + (col[1][2] + col[1][3]) + (col[1][4] + sum_r[0]);
    // 6 24 36 24 6
    sum_w[2] = (col[2][0] + col[2][1]) + (col[2][2] + col[2][3]) + (col[2][4] + sum_r[1]);
    // 4 16 24 16 4
    sum_w[3] = (col[1][0] + col[1][1]) + (col[1][2] + col[1][3]) + (col[1][4] + sum_r[2]);
    // 1 4 6 4 1
    sum_w[4] = (col[0][0] + col[0][1]) + (col[0][2] + col[0][3]) + (col[0][4] + sum_r[3]);
    
    o_pixel_w = sum_r[4][7] ? sum_r[4][15:8]+1 : sum_r[4][15:8];

end
// ========== Sequential Block ==========
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        for(i = 0; i < 5; i = i+1) begin
            sum_r[i] <= 0;
        end
        o_pixel_r <= 0;
    end
    else begin
        for(i = 0; i < 5; i = i+1) begin
            sum_r[i] <= sum_w[i];
        end
        o_pixel_r <= o_pixel_w;
    end
end
endmodule