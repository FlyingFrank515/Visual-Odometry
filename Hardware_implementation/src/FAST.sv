`include "FAST_9.sv"
`include "Orientation.sv"
`include "NMS.sv"
`include "SMOOTH.sv"

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
    input           i_valid,

    output [7:0]    o_pixel,
    output          o_pixel_valid,

    output [9:0]    o_coordinate_X,
    output [9:0]    o_coordinate_Y,

    output logic    o_ready,
    output [11:0]   o_cos,
    output [11:0]   o_sin,
    output [7:0]    o_score,
    output          o_flag,
    output logic    o_start,
    output logic    o_end,
    output          o_point_valid,

    // SRAM interface
    input [7:0]     sram_QA,
    input [7:0]     sram_QB,
    output          sram_WENA,
    output          sram_WENB,
    output [7:0]    sram_DA,
    output [7:0]    sram_DB,
    output [9:0]    sram_AA,
    output [9:0]    sram_AB

);
    // parameter
    localparam S_IDLE = 3'd0;
    localparam S_WAIT = 3'd1;
    localparam S_WORK = 3'd2;

    // ========== reg/wire declaration ==========
    integer i, j, k;
    logic [2:0] state_w, state_r;
    logic [19:0] count_w, count_r;
    logic [9:0] coor_x_w, coor_x_r;
    logic [9:0] coor_y_w, coor_y_r;
    logic [7:0] LINE_BUFFER_enter;
    logic [7:0] LINE_BUFFER [0:5][0:WIDTH-1];
    logic [7:0] LINE_BUFFER_LAST [0:4];

    logic [127:0] FAST_circle;
    logic [7:0] FAST_center;
    logic [7:0] FAST_score;
    logic       FAST_flag;

    logic [7:0]    NMS_score;
    logic          NMS_flag;

    logic [55:0] Orient_col;
    logic [39:0] SMOOTH_col;
    logic [7:0] SMOOTH_pixel;
    logic       SMOOTH_valid;
    logic [11:0] cos_buffer [0:WIDTH+3];
    logic [11:0] sin_buffer [0:WIDTH+3];
    logic [11:0] Orient_cos;
    logic [11:0] Orient_sin;

    // coordinates mask
    logic mask;
    logic [9:0] o_x_r, o_x_w;
    logic [9:0] o_y_r, o_y_w;
    logic [7:0] o_score_r, o_score_w;
    logic       o_flag_r, o_flag_w;
    logic [11:0] o_cos_w, o_cos_r;
    logic [11:0] o_sin_w, o_sin_r;

    // sram interface
    logic [7:0]    sram_QA_r;
    logic [7:0]    sram_QB_r;
    logic          sram_WENA_w, sram_WENA_r;
    logic          sram_WENB_w, sram_WENB_r;
    logic [7:0]    sram_DA_w, sram_DA_r;
    logic [7:0]    sram_DB_w, sram_DB_r;
    logic [9:0]    sram_AA_w, sram_AA_r;
    logic [9:0]    sram_AB_w, sram_AB_r;


    // ========== Connection ==========
    assign o_flag = o_flag_r;
    assign o_score = o_score_r;
    assign o_pixel = SMOOTH_pixel;
    assign o_coordinate_X = o_x_r;
    assign o_coordinate_Y = o_y_r;
    assign o_cos = o_cos_r;
    assign o_sin = o_sin_r;
    assign o_valid = i_valid;
    assign o_pixel_valid = SMOOTH_valid;
    assign o_point_valid = i_valid;

    // sram connection
    assign sram_WENA = sram_WENA_r;
    assign sram_WENB = sram_WENB_r;
    assign sram_DA = sram_DA_r;
    assign sram_DB = sram_DB_r;
    assign sram_AA = sram_AA_r;
    assign sram_AB = sram_AB_r;


    always_comb begin
        FAST_circle = {LINE_BUFFER[0][2], LINE_BUFFER[0][3], LINE_BUFFER[0][4], LINE_BUFFER[1][5], LINE_BUFFER[2][6], LINE_BUFFER[3][6], LINE_BUFFER[4][6], LINE_BUFFER[5][5]
        , LINE_BUFFER_LAST[4], LINE_BUFFER_LAST[3], LINE_BUFFER_LAST[2], LINE_BUFFER[5][1], LINE_BUFFER[4][0], LINE_BUFFER[3][0], LINE_BUFFER[2][0], LINE_BUFFER[1][1]};
        FAST_center = LINE_BUFFER[3][3];

        Orient_col = {LINE_BUFFER[0][0], LINE_BUFFER[1][0], LINE_BUFFER[2][0], LINE_BUFFER[3][0], LINE_BUFFER[4][0], LINE_BUFFER[5][0], LINE_BUFFER_LAST[0]}; // up to down
        SMOOTH_col = {LINE_BUFFER[0][0], LINE_BUFFER[1][0], LINE_BUFFER[2][0], LINE_BUFFER[3][0], LINE_BUFFER[4][0]};
    end

    SMOOTH
    #(
        .WIDTH(12'd640)
    )
    SMOOTH_unit
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_col0(SMOOTH_col),
        .i_valid(i_valid),

        .o_pixel(SMOOTH_pixel),
        .o_valid(SMOOTH_valid)
    );
    
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
        .i_valid(i_valid),

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
        .i_valid(i_valid),

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
        .i_valid(i_valid),

        .o_cos(Orient_cos),
        .o_sin(Orient_sin)
    );


    // ========== Combinational Block ==========
    always_comb begin
        mask = coor_x_r < EDGE || coor_x_r > WIDTH-EDGE || coor_y_r < EDGE || coor_y_r > HEIGHT-EDGE;
        o_x_w = coor_x_r;
        o_y_w = coor_y_r;
        o_flag_w = mask ? 0 : NMS_flag;
        o_score_w = mask ? 0 : NMS_score;
        o_cos_w = mask ? 0 : cos_buffer[WIDTH+3];
        o_sin_w = mask ? 0 : sin_buffer[WIDTH+3];
        o_score_w = mask ? 0 : NMS_score;
    end

    always_comb begin
        state_w = state_r;
        count_w = count_r;
        coor_x_w = coor_x_r;
        coor_y_w = coor_y_r;
        LINE_BUFFER_enter = 0;
        o_start = 0;
        o_end = 0;
        o_ready = 0;
        case(state_r)
            S_IDLE: begin
                o_ready = 1;
                if(i_start) begin
                    state_w = S_WAIT;
                    LINE_BUFFER_enter = i_pixel;
                    count_w = 0;
                    // o_start = 1;
                end
            end
            S_WAIT: begin
                LINE_BUFFER_enter = i_pixel;
                count_w = count_r + 1;
                if(count_r == (2*WIDTH + 5)) begin
                    o_start = 1;
                end
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

    always_comb begin
        sram_WENA_w = 1; // 1 for read
        sram_WENB_w = 1;
        sram_DA_w = sram_DA_r;
        sram_DB_w = sram_DB_r;
        sram_AA_w = sram_AA_r;
        sram_AB_w = sram_AB_r;
        case(state_r)
            S_IDLE: begin
                if(i_start) begin
                    sram_DA_w = LINE_BUFFER[0][6];
                    sram_AA_w = 0;
                    sram_WENA_w = 0;
                    // sram_DB_w = i_pixel;
                    sram_AB_w = 1;
                    sram_WENB_w = 1;
                end
            end
            S_WAIT: begin
                sram_DA_w = LINE_BUFFER[0][6];
                sram_AA_w = (sram_AA_r == 632) ? 0 : sram_AA_r + 1;
                sram_WENA_w = 0;
                // sram_DB_w = i_pixel;
                sram_AB_w = (sram_AB_r == 632) ? 0 : sram_AB_r + 1;
                sram_WENB_w = 1;     
            end
            S_WORK: begin
                sram_DA_w = i_pixel;
                sram_AA_w = (sram_AA_r == 632) ? 0 : sram_AA_r + 1;
                sram_WENA_w = 0;
                // sram_DB_w = i_pixel;
                sram_AB_w = (sram_AB_r == 632) ? 0 : sram_AB_r + 1;
                sram_WENB_w = 1;    
            end
        endcase

    end

    // ========== Sequential Block ==========
    always_ff @(posedge i_clk or negedge i_rst_n) begin
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

            for(int k = 0; k < WIDTH+4; k = k+1) begin
                cos_buffer[k] <= 0;
                sin_buffer[k] <= 0;
            end
            for(int j = 0; j < 5; j = j+1) begin
                LINE_BUFFER_LAST[j] <= 0;
            end
            for(int i = 0; i < 6; i = i+1) begin
                for(int j = 0; j < WIDTH; j = j+1) begin
                    LINE_BUFFER[i][j] <= 0;
                end
            end

            sram_QA_r <= 0;
            sram_QB_r <= 0;
            sram_WENA_r <= 1; // read
            sram_WENB_r <= 1; // read
            sram_DA_r <= 0;
            sram_DB_r <= 0;
            sram_AA_r <= 0;
            sram_AB_r <= 1;

        end
        else if(i_valid) begin
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
            for(int k = 1; k < WIDTH+4; k = k+1) begin
                cos_buffer[k] <= cos_buffer[k-1];
                sin_buffer[k] <= sin_buffer[k-1];
            end

            LINE_BUFFER_LAST[0] <= LINE_BUFFER[5][WIDTH-1];
            for(int j = 1; j < 5; j = j+1) begin
                LINE_BUFFER_LAST[j] <= LINE_BUFFER_LAST[j-1];
            end
            LINE_BUFFER[0][0] <= LINE_BUFFER_enter;
            LINE_BUFFER[1][0] <= sram_QB_r;
            LINE_BUFFER[2][0] <= LINE_BUFFER[1][WIDTH-1];
            LINE_BUFFER[3][0] <= LINE_BUFFER[2][WIDTH-1];
            LINE_BUFFER[4][0] <= LINE_BUFFER[3][WIDTH-1];
            LINE_BUFFER[5][0] <= LINE_BUFFER[4][WIDTH-1];
            for(int i = 0; i < 6; i = i+1) begin
                for(int j = 1; j < WIDTH; j = j+1) begin
                    LINE_BUFFER[i][j] <= LINE_BUFFER[i][j-1];
                end
            end

            sram_QA_r <= sram_QA;
            sram_QB_r <= sram_QB;
            sram_WENA_r <= sram_WENA_w;
            sram_WENB_r <= sram_WENB_w;
            sram_DA_r <= sram_DA_w;
            sram_DB_r <= sram_DB_w;
            sram_AA_r <= sram_AA_w;
            sram_AB_r <= sram_AB_w;
        end
    end

endmodule