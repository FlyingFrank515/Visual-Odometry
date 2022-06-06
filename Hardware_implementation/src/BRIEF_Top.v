`include "BRIEF.v"
`include "Key_Buffer1.v"

module BRIEF_Top
#(
    parameter WIDTH = 12'd640,
    parameter HEIGHT = 12'd480
)
(
    input           i_clk,
    input           i_rst_n,
    input [7:0]     i_pixel,
    input           i_start,
    input           i_end,

    input           i_flag,
    input [11:0]    i_sin,
    input [11:0]    i_cos,
    input [9:0]     i_coor_x, 
    input [9:0]     i_coor_y, 
    input [7:0]     i_score,

    output [9:0]    o_coordinate_X,
    output [9:0]    o_coordinate_Y,
    output [255:0]  o_descriptor,

    output [7:0]    o_score,
    output          o_flag,
    output reg      o_start,
    output reg      o_end

);
    // parameter
    localparam S_IDLE = 3'd0;
    localparam S_WAIT1 = 3'd1;
    localparam S_WAIT2 = 3'd2;
    localparam S_WORK = 3'd3;

    // ========== reg/wire declaration ==========
    integer i, j, k;
    reg [2:0] state_w, state_r;
    reg [19:0] count_w, count_r;
    reg [9:0] coor_x_w, coor_x_r;
    reg [9:0] coor_y_w, coor_y_r;
    reg [7:0] LINE_BUFFER_enter;
    reg [7:0] LINE_BUFFER [0:29][0:WIDTH-1];
    reg [7:0] LINE_BUFFER_LAST [0:31];

    wire BUFFER_hit;
    wire [11:0] BUFFER_sin, BUFFER_cos;
    wire [9:0] BUFFER_x, BUFFER_y;
    wire [7:0] BUFFER_score;

    reg [247:0] BRIEF_col [0:30];


    // ========== Connection ==========
    always@(*) begin
        for(i = 0; i < 31; i = i+1) begin
            BRIEF_col[i] = {LINE_BUFFER[0][i], LINE_BUFFER[1][i], LINE_BUFFER[2][i], LINE_BUFFER[3][i], LINE_BUFFER[4][i], LINE_BUFFER[5][i],
                            LINE_BUFFER[6][i], LINE_BUFFER[7][i], LINE_BUFFER[8][i], LINE_BUFFER[9][i], LINE_BUFFER[10][i], LINE_BUFFER[11][i],
                            LINE_BUFFER[12][i], LINE_BUFFER[13][i], LINE_BUFFER[14][i], LINE_BUFFER[15][i], LINE_BUFFER[16][i], LINE_BUFFER[17][i],
                            LINE_BUFFER[18][i], LINE_BUFFER[19][i], LINE_BUFFER[20][i], LINE_BUFFER[21][i], LINE_BUFFER[22][i], LINE_BUFFER[23][i],
                            LINE_BUFFER[24][i], LINE_BUFFER[25][i], LINE_BUFFER[26][i], LINE_BUFFER[27][i], LINE_BUFFER[28][i], LINE_BUFFER[29][i], LINE_BUFFER_LAST[i]};
                            
        end
    end

    Key_Buffer1 
    #(
        .SIZE(12'd100)   
    )
    buffer
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_flag(i_flag),
        .i_hit(BUFFER_hit),
        .i_sin(i_sin),
        .i_cos(i_cos),
        .i_coor_x(i_coor_x), 
        .i_coor_y(i_coor_y), 
        .i_score(i_score),

        .o_sin(BUFFER_sin),
        .o_cos(BUFFER_cos),
        .o_coor_x(BUFFER_x), 
        .o_coor_y(BUFFER_y),
        .o_score(BUFFER_score)
    );

    BRIEF brief_unit
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_col0(BRIEF_col[0]),
        .i_col1(BRIEF_col[1]),
        .i_col2(BRIEF_col[2]),
        .i_col3(BRIEF_col[3]),
        .i_col4(BRIEF_col[4]),
        .i_col5(BRIEF_col[5]),
        .i_col6(BRIEF_col[6]),
        .i_col7(BRIEF_col[7]),
        .i_col8(BRIEF_col[8]),
        .i_col9(BRIEF_col[9]),
        .i_col10(BRIEF_col[10]),
        .i_col11(BRIEF_col[11]),
        .i_col12(BRIEF_col[12]),
        .i_col13(BRIEF_col[13]),
        .i_col14(BRIEF_col[14]),
        .i_col15(BRIEF_col[15]),
        .i_col16(BRIEF_col[16]),
        .i_col17(BRIEF_col[17]),
        .i_col18(BRIEF_col[18]), 
        .i_col19(BRIEF_col[19]),
        .i_col20(BRIEF_col[20]),
        .i_col21(BRIEF_col[21]),
        .i_col22(BRIEF_col[22]),
        .i_col23(BRIEF_col[23]),
        .i_col24(BRIEF_col[24]),
        .i_col25(BRIEF_col[25]),
        .i_col26(BRIEF_col[26]),
        .i_col27(BRIEF_col[27]),
        .i_col28(BRIEF_col[28]),
        .i_col29(BRIEF_col[29]),
        .i_col30(BRIEF_col[30]),

        .i_coor_x(coor_x_r), 
        .i_coor_y(coor_y_r), 
        .i_score(BUFFER_score),

        .i_sin(BUFFER_sin),
        .i_cos(BUFFER_cos),
        .i_buf_coor_x(BUFFER_x), 
        .i_buf_coor_y(BUFFER_y), 

        .o_hit(BUFFER_hit),
        .o_coor_x(o_coordinate_X), 
        .o_coor_y(o_coordinate_Y), 
        .o_descriptor(o_descriptor),
        .o_flag(o_flag),
        .o_score(o_score)
    );

    // ========== Combinational Block ==========
    always@(*) begin
        state_w = state_r;
        count_w = count_r;
        coor_x_w = coor_x_r;
        coor_y_w = coor_y_r;
        LINE_BUFFER_enter = 0;
        o_start = 0;
        o_end = 0;
        case(state_r)
            S_IDLE: begin
                if(i_start) begin
                    state_w = S_WAIT2;
                    LINE_BUFFER_enter = i_pixel;
                    count_w = 0;
                    o_start = 1;
                end
            end
            // S_WAIT1: begin
            //     count_w = count_r + 1;
            //     if(count_r == (4 + 9 + WIDTH*4)) begin
            //         state_w = S_WAIT2;
            //     end          
            // end
            S_WAIT2: begin
                LINE_BUFFER_enter = i_pixel;
                count_w = count_r + 1;
                if(count_r == (11 + WIDTH*15)) begin
                    coor_x_w = 0;
                    coor_y_w = 0;
                    state_w = S_WORK;
                end          
            end
            S_WORK: begin
                LINE_BUFFER_enter = i_pixel;
                count_w = count_r + 1;
                coor_x_w = (coor_x_r == WIDTH-1) ? 0 : coor_x_r + 1;
                coor_y_w = (coor_x_r == WIDTH-1) ? coor_y_r + 1 : coor_y_r;

                if(coor_x_r == WIDTH-1 && coor_y_r == HEIGHT-1) begin
                    o_end = 1;
                    state_w = S_IDLE;
                    coor_x_w = 0;
                    coor_y_w = 0;
                end
            end
        endcase
    end

    // ========== Sequential Block ==========
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            state_r <= 0;
            count_r <= 0;
            coor_x_r <= 0;
            coor_y_r <= 0;

            for(j = 0; j < 32; j = j+1) begin
                LINE_BUFFER_LAST[j] <= 0;
            end
            for(i = 0; i < 30; i = i+1) begin
                for(j = 0; j < WIDTH; j = j+1) begin
                    LINE_BUFFER[i][j] <= 0;
                end
            end
        end
        else begin
            state_r <= state_w;
            count_r <= count_w;
            coor_x_r <= coor_x_w;
            coor_y_r <= coor_y_w;

            LINE_BUFFER_LAST[0] <= LINE_BUFFER[29][WIDTH-1];
            for(j = 1; j < 32; j = j+1) begin
                LINE_BUFFER_LAST[j] <= LINE_BUFFER_LAST[j-1];
            end
            LINE_BUFFER[0][0] <= LINE_BUFFER_enter;
            for(i = 1; i < 30; i = i+1) begin
                LINE_BUFFER[i][0] <= LINE_BUFFER[i-1][WIDTH-1];
            end
            for(i = 0; i < 30; i = i+1) begin
                for(j = 1; j < WIDTH; j = j+1) begin
                    LINE_BUFFER[i][j] <= LINE_BUFFER[i][j-1];
                end
            end
        end
    end

endmodule