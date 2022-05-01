`include "FAST_9.v"
`include "Orientation.v"
`include "NMS.v"

module FAST_Detector
#(
    parameter WIDTH = 12'd640,
    parameter HEIGHT = 12'd480,
    parameter EDGE = 6'd31
)
(
    input           i_clk,
    input           i_rst_n,
    input [7:0]     i_pixel,
    input           i_start,

    output [7:0]    o_pixel,
    output [9:0]    o_coordinate_X,
    output [9:0]    o_coordinate_Y,

    output [11:0]   o_cos,
    output [11:0]   o_sin,
    output [7:0]    o_score,
    output          o_flag,
    output reg      o_start,
    output reg      o_end

);
    // parameter
    localparam S_IDLE = 3'd0;
    localparam S_WAIT = 3'd1;
    localparam S_WORK = 3'd2;

    // ========== reg/wire declaration ==========
    integer i, j, k;
    reg [2:0] state_w, state_r;
    reg [19:0] count_w, count_r;
    reg [9:0] coor_x_w, coor_x_r;
    reg [9:0] coor_y_w, coor_y_r;
    reg [7:0] LINE_BUFFER_enter;
    reg [7:0] LINE_BUFFER [0:5][0:WIDTH-1];
    reg [7:0] LINE_BUFFER_LAST [0:4];

    reg [127:0] FAST_circle;
    reg [7:0] FAST_center;
    wire [7:0] FAST_score;
    wire       FAST_flag;

    wire [7:0]    NMS_score;
    wire          NMS_flag;

    reg [55:0] Orient_col;
    reg [11:0] cos_buffer [0:WIDTH+3];
    reg [11:0] sin_buffer [0:WIDTH+3];
    wire [11:0] Orient_cos;
    wire [11:0] Orient_sin;

    // coordinates mask
    reg mask;
    reg [9:0] o_x_r, o_x_w;
    reg [9:0] o_y_r, o_y_w;
    reg [7:0] o_score_r, o_score_w;
    reg       o_flag_r, o_flag_w;
    reg [11:0] o_cos_w, o_cos_r;
    reg [11:0] o_sin_w, o_sin_r;


    // ========== Connection ==========
    assign o_flag = o_flag_r;
    assign o_score = o_score_r;
    assign o_pixel = 0;
    assign o_coordinate_X = o_x_r;
    assign o_coordinate_Y = o_y_r;
    assign o_orientation = 0;
    assign o_cos = o_cos_r;
    assign o_sin = o_sin_r;


    always@(*) begin
        FAST_circle = {LINE_BUFFER[0][2], LINE_BUFFER[0][3], LINE_BUFFER[0][4], LINE_BUFFER[1][5], LINE_BUFFER[2][6], LINE_BUFFER[3][6], LINE_BUFFER[4][6], LINE_BUFFER[5][5]
        , LINE_BUFFER_LAST[4], LINE_BUFFER_LAST[3], LINE_BUFFER_LAST[2], LINE_BUFFER[5][1], LINE_BUFFER[4][0], LINE_BUFFER[3][0], LINE_BUFFER[2][0], LINE_BUFFER[1][1]};
        FAST_center = LINE_BUFFER[3][3];

        Orient_col = {LINE_BUFFER[0][0], LINE_BUFFER[1][0], LINE_BUFFER[2][0], LINE_BUFFER[3][0], LINE_BUFFER[4][0], LINE_BUFFER[5][0], LINE_BUFFER_LAST[0]}; // up to down

    end
    
    FAST_9 
    #(
        .THRESHOLD(8'd20)
    )
    FAST_unit
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_circle(FAST_circle),
        .i_center(FAST_center),

        .o_keypoints_flag(FAST_flag),
        .o_score(FAST_score)
    );

    NMS 
    #(
        .WIDTH(WIDTH)    
    )
    NMS_unit
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_score(FAST_score),
        .i_flag(FAST_flag),

        .o_score(NMS_score),
        .o_flag(NMS_flag)
    );

    Orientation_Unit 
    #(
        .WIDTH(WIDTH) 
    )
    Orient_Unit
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_col0(Orient_col),

        .o_cos(Orient_cos),
        .o_sin(Orient_sin)
    );


    // ========== Combinational Block ==========
    always@(*) begin
        mask = coor_x_r < EDGE || coor_x_r > WIDTH-EDGE || coor_y_r < EDGE || coor_y_r > HEIGHT-EDGE;
        o_x_w = coor_x_r;
        o_y_w = coor_y_r;
        o_flag_w = mask ? 0 : NMS_flag;
        o_score_w = mask ? 0 : NMS_score;
        o_cos_w = mask ? 0 : cos_buffer[WIDTH+3];
        o_sin_w = mask ? 0 : sin_buffer[WIDTH+3];
        o_score_w = mask ? 0 : NMS_score;
    end

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
                    state_w = S_WAIT;
                    LINE_BUFFER_enter = i_pixel;
                    count_w = 0;
                    o_start = 1;
                end
            end
            S_WAIT: begin
                LINE_BUFFER_enter = i_pixel;
                count_w = count_r + 1;
                if(count_r == (4 + 9 + WIDTH*4)) begin
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

            o_x_r <= 0;
            o_y_r <= 0;
            o_score_r <= 0;
            o_flag_r <= 0;
            o_cos_r <= 0;
            o_sin_r <= 0;

            for(k = 0; k < WIDTH+4; k = k+1) begin
                cos_buffer[k] <= 0;
                sin_buffer[k] <= 0;
            end
            for(j = 0; j < 5; j = j+1) begin
                LINE_BUFFER_LAST[j] <= 0;
            end
            for(i = 0; i < 6; i = i+1) begin
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

            o_x_r <= o_x_w;
            o_y_r <= o_y_w;
            o_score_r <= o_score_w;
            o_flag_r <= o_flag_w;
            o_cos_r <= o_cos_w;
            o_sin_r <= o_sin_w;
            
            cos_buffer[0] <= Orient_cos;
            sin_buffer[0] <= Orient_sin;
            for(k = 1; k < WIDTH+4; k = k+1) begin
                cos_buffer[k] <= cos_buffer[k-1];
                sin_buffer[k] <= sin_buffer[k-1];
            end

            LINE_BUFFER_LAST[0] <= LINE_BUFFER[5][WIDTH-1];
            for(j = 1; j < 5; j = j+1) begin
                LINE_BUFFER_LAST[j] <= LINE_BUFFER_LAST[j-1];
            end
            LINE_BUFFER[0][0] <= LINE_BUFFER_enter;
            for(i = 1; i < 6; i = i+1) begin
                LINE_BUFFER[i][0] <= LINE_BUFFER[i-1][WIDTH-1];
            end
            for(i = 0; i < 6; i = i+1) begin
                for(j = 1; j < WIDTH; j = j+1) begin
                    LINE_BUFFER[i][j] <= LINE_BUFFER[i][j-1];
                end
            end
        end
    end

endmodule