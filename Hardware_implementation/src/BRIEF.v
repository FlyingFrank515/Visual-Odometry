`include "LUT.v"
module BRIEF
(
    input           i_clk,
    input           i_rst_n,

    input [247:0]   i_col0,
    input [247:0]   i_col1,
    input [247:0]   i_col2,
    input [247:0]   i_col3,
    input [247:0]   i_col4,
    input [247:0]   i_col5,
    input [247:0]   i_col6,
    input [247:0]   i_col7,
    input [247:0]   i_col8,
    input [247:0]   i_col9,
    input [247:0]   i_col10,
    input [247:0]   i_col11,
    input [247:0]   i_col12,
    input [247:0]   i_col13,
    input [247:0]   i_col14,
    input [247:0]   i_col15,
    input [247:0]   i_col16,
    input [247:0]   i_col17,
    input [247:0]   i_col18, 
    input [247:0]   i_col19,
    input [247:0]   i_col20,
    input [247:0]   i_col21,
    input [247:0]   i_col22,
    input [247:0]   i_col23,
    input [247:0]   i_col24,
    input [247:0]   i_col25,
    input [247:0]   i_col26,
    input [247:0]   i_col27,
    input [247:0]   i_col28,
    input [247:0]   i_col29,
    input [247:0]   i_col30,

    input [9:0]     i_coor_x, 
    input [9:0]     i_coor_y, 

    input signed [11:0]    i_sin,
    input signed [11:0]    i_cos,
    input [9:0]     i_buf_coor_x, 
    input [9:0]     i_buf_coor_y, 

    output          o_hit,
    output [9:0]    o_coor_x, 
    output [9:0]    o_coor_y, 
    output [255:0]  o_descriptor,
    output          o_flag

);
    // parameter


    // ========== reg/wire declaration ==========
    integer i;
    genvar idx;
    reg [7:0] pixel [0:30][0:30];
    wire signed [7:0] x_a [0:255];
    wire signed [7:0] y_a [0:255];
    wire signed [7:0] x_b [0:255];
    wire signed [7:0] y_b [0:255];

    reg signed [7:0] x_a_cos_w [0:255], x_a_cos_r [0:255];
    reg signed [7:0] x_a_sin_w [0:255], x_a_sin_r [0:255];
    reg signed [7:0] y_a_cos_w [0:255], y_a_cos_r [0:255];
    reg signed [7:0] y_a_sin_w [0:255], y_a_sin_r [0:255];
    reg signed [7:0] x_b_cos_w [0:255], x_b_cos_r [0:255];
    reg signed [7:0] x_b_sin_w [0:255], x_b_sin_r [0:255];
    reg signed [7:0] y_b_cos_w [0:255], y_b_cos_r [0:255];
    reg signed [7:0] y_b_sin_w [0:255], y_b_sin_r [0:255];

    reg signed [19:0] x_a_cos [0:255];
    reg signed [19:0] x_a_sin [0:255];
    reg signed [19:0] y_a_cos [0:255];
    reg signed [19:0] y_a_sin [0:255];
    reg signed [19:0] x_b_cos [0:255];
    reg signed [19:0] x_b_sin [0:255];
    reg signed [19:0] y_b_cos [0:255];
    reg signed [19:0] y_b_sin [0:255];

    // reg [9:0] coor1_x_w, coor1_x_r;
    // reg [9:0] coor1_y_w, coor1_y_r;
    reg       flag1_w, flag1_r;

    reg signed [7:0] x1_w [0:255], x1_r[0:255];
    reg signed [7:0] x2_w [0:255], x2_r[0:255];
    reg signed [7:0] y1_w [0:255], y1_r[0:255];
    reg signed [7:0] y2_w [0:255], y2_r[0:255];

    // reg [9:0] coor2_x_w, coor2_x_r;
    // reg [9:0] coor2_y_w, coor2_y_r;
    reg       flag2_w, flag2_r;
    reg [7:0] center;

    reg [255:0] descriptor_w, descriptor_r;

    reg [9:0] coor3_x_w, coor3_x_r;
    reg [9:0] coor3_y_w, coor3_y_r;
    reg       flag3_w, flag3_r;

    // ========== Connection ==========
    always@(*) begin
        for(i = 0; i < 31; i = i+1) begin
            pixel[i][0] = i_col0[i*8 +: 8];
            pixel[i][1] = i_col1[i*8 +: 8];
            pixel[i][2] = i_col2[i*8 +: 8];
            pixel[i][3] = i_col3[i*8 +: 8];
            pixel[i][4] = i_col4[i*8 +: 8];
            pixel[i][5] = i_col5[i*8 +: 8];
            pixel[i][6] = i_col6[i*8 +: 8];
            pixel[i][7] = i_col7[i*8 +: 8];
            pixel[i][8] = i_col8[i*8 +: 8];
            pixel[i][9] = i_col9[i*8 +: 8];
            pixel[i][10] = i_col10[i*8 +: 8];
            pixel[i][11] = i_col11[i*8 +: 8];
            pixel[i][12] = i_col12[i*8 +: 8];
            pixel[i][13] = i_col13[i*8 +: 8];
            pixel[i][14] = i_col14[i*8 +: 8];
            pixel[i][15] = i_col15[i*8 +: 8];
            pixel[i][16] = i_col16[i*8 +: 8];
            pixel[i][17] = i_col17[i*8 +: 8];
            pixel[i][18] = i_col18[i*8 +: 8];
            pixel[i][19] = i_col19[i*8 +: 8];
            pixel[i][20] = i_col20[i*8 +: 8];
            pixel[i][21] = i_col21[i*8 +: 8];
            pixel[i][22] = i_col22[i*8 +: 8];
            pixel[i][23] = i_col23[i*8 +: 8];
            pixel[i][24] = i_col24[i*8 +: 8];
            pixel[i][25] = i_col25[i*8 +: 8];
            pixel[i][26] = i_col26[i*8 +: 8];
            pixel[i][27] = i_col27[i*8 +: 8];
            pixel[i][28] = i_col28[i*8 +: 8];
            pixel[i][29] = i_col29[i*8 +: 8];
            pixel[i][30] = i_col30[i*8 +: 8];
        end
        center = i_col15[127:120];
    end


    generate
        for (idx = 0; idx < 256; idx = idx + 1) begin
            LUT inst(
                .i_num(idx[7:0]),
                .o_xa(x_a[idx]),
                .o_ya(y_a[idx]),
                .o_xb(x_b[idx]),
                .o_yb(y_b[idx])
            );
        end
    endgenerate


    // ========== Combinational Block ==========
    assign o_hit = (i_buf_coor_x == i_coor_x) && (i_buf_coor_y == i_coor_y);
    assign o_coor_x = coor3_x_r;
    assign o_coor_y = coor3_y_r;
    assign o_flag = flag3_r;
    assign o_descriptor = descriptor_r;

    always@(*) begin
        for(i = 0; i < 256; i = i+1) begin

            x_a_cos[i] = (x_a[i]*i_cos);
            x_a_sin[i] = (x_a[i]*i_sin);
            y_a_cos[i] = (y_a[i]*i_cos);
            y_a_sin[i] = (y_a[i]*i_sin);
            x_b_cos[i] = (x_b[i]*i_cos);
            x_b_sin[i] = (x_b[i]*i_sin);
            y_b_cos[i] = (y_b[i]*i_cos);
            y_b_sin[i] = (y_b[i]*i_sin);

            x_a_cos_w[i] = x_a_cos[i][17:10];
            x_a_sin_w[i] = x_a_sin[i][17:10];
            y_a_cos_w[i] = y_a_cos[i][17:10];
            y_a_sin_w[i] = y_a_sin[i][17:10];
            x_b_cos_w[i] = x_b_cos[i][17:10];
            x_b_sin_w[i] = x_b_sin[i][17:10];
            y_b_cos_w[i] = y_b_cos[i][17:10];
            y_b_sin_w[i] = y_b_sin[i][17:10];

            x1_w[i] = (x_a_cos_r[i] - y_a_sin_r[i]) + $signed(8'd15);
            y1_w[i] = (x_a_sin_r[i] + y_a_cos_r[i]) + $signed(8'd15);
            x2_w[i] = (x_b_cos_r[i] - y_b_sin_r[i]) + $signed(8'd15);
            y2_w[i] = (x_b_sin_r[i] + y_a_cos_r[i]) + $signed(8'd15);

            descriptor_w[i] = (flag2_r) ? (pixel[y1_r[i]][x1_r[i]] > pixel[y2_r[i]][x2_r[i]]) : 0;
        end
        // coor1_x_w = ((i_buf_coor_x == i_coor_x) && (i_buf_coor_y == i_coor_y)) ? i_coor_x : 0;
        // coor1_y_w = ((i_buf_coor_x == i_coor_x) && (i_buf_coor_y == i_coor_y)) ? i_coor_y : 0;
        flag1_w = ((i_buf_coor_x == i_coor_x) && (i_buf_coor_y == i_coor_y)) && i_coor_x != 0 && i_coor_y != 0;
        flag2_w = flag1_r;
        flag3_w = flag2_r;
        // coor2_x_w = coor1_x_r;
        // coor2_y_w = coor1_y_r;
        coor3_x_w = flag2_r ? i_coor_x - 2 : 0;
        coor3_y_w = flag2_r ? i_coor_y : 0;
        
    end

    // ========== Sequential Block ==========
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            for(i = 0; i < 256; i = i+1) begin
                x_a_cos_r[i] <= 0; 
                x_a_sin_r[i] <= 0; 
                y_a_cos_r[i] <= 0; 
                y_a_sin_r[i] <= 0; 
                x_b_cos_r[i] <= 0; 
                x_b_sin_r[i] <= 0; 
                y_b_cos_r[i] <= 0; 
                y_b_sin_r[i] <= 0; 
                x1_r[i] <= 0;
                y1_r[i] <= 0;
                x2_r[i] <= 0;
                y2_r[i] <= 0;
            end
            descriptor_r <= 0;
            // coor1_x_r <= 0;
            // coor1_y_r <= 0;
            // coor2_x_r <= 0;
            // coor2_y_r <= 0;
            coor3_x_r <= 0;
            coor3_y_r <= 0;
            flag1_r <= 0;
            flag2_r <= 0;
            flag3_r <= 0;
        end
        else begin
            for(i = 0; i < 256; i = i+1) begin
                x_a_cos_r[i] <= x_a_cos_w[i]; 
                x_a_sin_r[i] <= x_a_sin_w[i]; 
                y_a_cos_r[i] <= y_a_cos_w[i]; 
                y_a_sin_r[i] <= y_a_sin_w[i]; 
                x_b_cos_r[i] <= x_b_cos_w[i]; 
                x_b_sin_r[i] <= x_b_sin_w[i]; 
                y_b_cos_r[i] <= y_b_cos_w[i]; 
                y_b_sin_r[i] <= y_b_sin_w[i]; 

                x1_r[i] <= x1_w[i];
                y1_r[i] <= y1_w[i];
                x2_r[i] <= x2_w[i];
                y2_r[i] <= y2_w[i];
            end
            descriptor_r <= descriptor_w;
            // coor1_x_r <= coor1_x_w;
            // coor1_y_r <= coor1_y_w;
            // coor2_x_r <= coor2_x_w;
            // coor2_y_r <= coor2_y_w;
            coor3_x_r <= coor3_x_w;
            coor3_y_r <= coor3_y_w;
            flag1_r <= flag1_w;
            flag2_r <= flag2_w;
            flag3_r <= flag3_w;
            
        end
    end

endmodule