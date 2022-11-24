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

    // sram interface -- FAST window
    input [7:0]     FAST_lb_sram_QA [6],
    input [7:0]     FAST_lb_sram_QB [6],
    output          FAST_lb_sram_WENA [6],
    output          FAST_lb_sram_WENB [6],
    output [7:0]    FAST_lb_sram_DA [6],
    output [7:0]    FAST_lb_sram_DB [6],
    output [9:0]    FAST_lb_sram_AA [6],
    output [9:0]    FAST_lb_sram_AB [6],

    // sram interface -- FAST sin, cos delay FIFO
    input [11:0]     FAST_sincos_sram_QA [2],
    input [11:0]     FAST_sincos_sram_QB [2],
    output          FAST_sincos_sram_WENA [2],
    output          FAST_sincos_sram_WENB [2],
    output [11:0]    FAST_sincos_sram_DA [2],
    output [11:0]    FAST_sincos_sram_DB [2],
    output [9:0]    FAST_sincos_sram_AA [2],
    output [9:0]    FAST_sincos_sram_AB [2],

    // sram interface -- FAST NMS FIFO
    input [9:0]     FAST_NMS_sram_QA,
    input [9:0]     FAST_NMS_sram_QB,
    output          FAST_NMS_sram_WENA,
    output          FAST_NMS_sram_WENB,
    output [9:0]    FAST_NMS_sram_DA,
    output [9:0]    FAST_NMS_sram_DB,
    output [9:0]    FAST_NMS_sram_AA,
    output [9:0]    FAST_NMS_sram_AB

);
    // parameter
    localparam S_IDLE = 3'd0;
    localparam S_WAIT = 3'd1;
    localparam S_WORK = 3'd2;

    // ========== reg/wire declaration ==========
    // integer i, j, k;
    logic [2:0] state_w, state_r;
    logic [19:0] count_w, count_r;
    logic [9:0] coor_x_w, coor_x_r;
    logic [9:0] coor_y_w, coor_y_r;
    logic [7:0] LINE_BUFFER_enter;
    logic [7:0] LINE_BUFFER [0:5][0:12];
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
    // logic [11:0] cos_buffer [0:WIDTH+3];
    // logic [11:0] sin_buffer [0:WIDTH+3];
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

    // FAST_lb_sram interface
    logic [7:0]    FAST_lb_sram_QB_r [0:5];
    logic          FAST_lb_sram_WENA_w [0:5], FAST_lb_sram_WENA_r [0:5];
    logic          FAST_lb_sram_WENB_w [0:5], FAST_lb_sram_WENB_r [0:5];
    logic [7:0]    FAST_lb_sram_DA_w [0:5], FAST_lb_sram_DA_r [0:5];
    logic [9:0]    FAST_lb_sram_AA_w [0:5], FAST_lb_sram_AA_r [0:5];
    logic [9:0]    FAST_lb_sram_AB_w [0:5], FAST_lb_sram_AB_r [0:5];

    // sincos_sram interface
    logic [11:0]    FAST_sincos_sram_QB_r [0:1];
    logic          FAST_sincos_sram_WENA_w [0:1], FAST_sincos_sram_WENA_r [0:1];
    logic          FAST_sincos_sram_WENB_w [0:1], FAST_sincos_sram_WENB_r [0:1];
    logic [11:0]    FAST_sincos_sram_DA_w [0:1], FAST_sincos_sram_DA_r [0:1];
    logic [9:0]    FAST_sincos_sram_AA_w [0:1], FAST_sincos_sram_AA_r [0:1];
    logic [9:0]    FAST_sincos_sram_AB_w [0:1], FAST_sincos_sram_AB_r [0:1];

    logic [11:0] sram_sin_delay [0:16];
    logic [11:0] sram_cos_delay [0:16];


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

    // FAST_lb_sram connection
    for(genvar i = 0; i < 6; i = i+1) begin
        assign FAST_lb_sram_WENA[i] = FAST_lb_sram_WENA_r[i];
        assign FAST_lb_sram_WENB[i] = FAST_lb_sram_WENB_r[i];
        assign FAST_lb_sram_DA[i] = FAST_lb_sram_DA_r[i];
        assign FAST_lb_sram_DB[i] = 0;
        assign FAST_lb_sram_AA[i] = FAST_lb_sram_AA_r[i];
        assign FAST_lb_sram_AB[i] = FAST_lb_sram_AB_r[i];
    end

    // isincos_sram connection
    for(genvar i = 0; i < 2; i = i+1) begin
        assign FAST_sincos_sram_WENA[i] = FAST_sincos_sram_WENA_r[i];
        assign FAST_sincos_sram_WENB[i] = FAST_sincos_sram_WENB_r[i];
        assign FAST_sincos_sram_DA[i] = FAST_sincos_sram_DA_r[i];
        assign FAST_sincos_sram_DB[i] = 0;
        assign FAST_sincos_sram_AA[i] = FAST_sincos_sram_AA_r[i];
        assign FAST_sincos_sram_AB[i] = FAST_sincos_sram_AB_r[i];
    end


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
        .o_flag(NMS_flag),

        .sram_QA(FAST_NMS_sram_QA),
        .sram_QB(FAST_NMS_sram_QB),
        .sram_WENA(FAST_NMS_sram_WENA),
        .sram_WENB(FAST_NMS_sram_WENB),
        .sram_DA(FAST_NMS_sram_DA),
        .sram_DB(FAST_NMS_sram_DB),
        .sram_AA(FAST_NMS_sram_AA),
        .sram_AB(FAST_NMS_sram_AB)
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
        o_cos_w = mask ? 0 : sram_cos_delay[16];
        o_sin_w = mask ? 0 : sram_sin_delay[16];
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

    // sin cos delay
    always_comb begin
        for(int i = 0; i < 6; i = i+1) begin
            FAST_sincos_sram_WENA_w[i] = 1; // 1 for read
            FAST_sincos_sram_WENB_w[i] = 1;
            FAST_sincos_sram_DA_w[i] = FAST_sincos_sram_DA_r[i];
            FAST_sincos_sram_AA_w[i] = FAST_sincos_sram_AA_r[i];
            FAST_sincos_sram_AB_w[i] = FAST_sincos_sram_AB_r[i];
        end
        case(state_r)
            S_IDLE: begin
                if(i_start) begin
                    for(int i = 0; i < 2; i = i+1) begin
                        FAST_sincos_sram_WENA_w[i] = 0;
                        FAST_sincos_sram_WENB_w[i] = 1;
                        FAST_sincos_sram_AA_w[i] = 624;
                        FAST_sincos_sram_AB_w[i] = 0;
                    end
                    FAST_sincos_sram_DA_w[0] = Orient_sin;
                    FAST_sincos_sram_DA_w[1] = Orient_cos;
                end
            end
            S_WAIT: begin
                for(int i = 0; i < 2; i = i+1) begin
                    FAST_sincos_sram_WENA_w[i] = 0;
                    FAST_sincos_sram_WENB_w[i] = 1;
                    FAST_sincos_sram_AA_w[i] = FAST_sincos_sram_AA_r[i] == 639 ? 0 : FAST_sincos_sram_AA_r[i] + 1;
                    FAST_sincos_sram_AB_w[i] = FAST_sincos_sram_AB_r[i] == 639 ? 0 : FAST_sincos_sram_AB_r[i] + 1;
                end
                FAST_sincos_sram_DA_w[0] = Orient_sin;
                FAST_sincos_sram_DA_w[1] = Orient_cos;
            
            end
            S_WORK: begin
               for(int i = 0; i < 2; i = i+1) begin
                    FAST_sincos_sram_WENA_w[i] = 0;
                    FAST_sincos_sram_WENB_w[i] = 1;
                    FAST_sincos_sram_AA_w[i] = FAST_sincos_sram_AA_r[i] == 639 ? 0 : FAST_sincos_sram_AA_r[i] + 1;
                    FAST_sincos_sram_AB_w[i] = FAST_sincos_sram_AB_r[i] == 639 ? 0 : FAST_sincos_sram_AB_r[i] + 1;
                end
                FAST_sincos_sram_DA_w[0] = Orient_sin;
                FAST_sincos_sram_DA_w[1] = Orient_cos;
            end
        endcase
    end

    // line buffer
    always_comb begin
        for(int i = 0; i < 6; i = i+1) begin
            FAST_lb_sram_WENA_w[i] = 1; // 1 for read
            FAST_lb_sram_WENB_w[i] = 1;
            FAST_lb_sram_DA_w[i] = FAST_lb_sram_DA_r[i];
            FAST_lb_sram_AA_w[i] = FAST_lb_sram_AA_r[i];
            FAST_lb_sram_AB_w[i] = FAST_lb_sram_AB_r[i];
        end
        case(state_r)
            S_IDLE: begin
                if(i_start) begin
                    for(int i = 0; i < 6; i = i+1) begin
                        FAST_lb_sram_WENA_w[i] = 0;
                        FAST_lb_sram_WENB_w[i] = 1;
                        FAST_lb_sram_DA_w[i] = LINE_BUFFER[i][12];
                        FAST_lb_sram_AA_w[i] = 624;
                        FAST_lb_sram_AB_w[i] = 0;
                    end
                end
            end
            S_WAIT: begin
                for(int i = 0; i < 6; i = i+1) begin
                    FAST_lb_sram_WENA_w[i] = 0;
                    FAST_lb_sram_WENB_w[i] = 1;
                    FAST_lb_sram_DA_w[i] = LINE_BUFFER[i][12];
                    FAST_lb_sram_AA_w[i] = (FAST_lb_sram_AA_r[i] == 639) ? 0 : FAST_lb_sram_AA_r[i] + 1;
                    FAST_lb_sram_AB_w[i] = (FAST_lb_sram_AB_r[i] == 639) ? 0 : FAST_lb_sram_AB_r[i] + 1;
                end   
            end
            S_WORK: begin
                for(int i = 0; i < 6; i = i+1) begin
                    FAST_lb_sram_WENA_w[i] = 0;
                    FAST_lb_sram_WENB_w[i] = 1;
                    FAST_lb_sram_DA_w[i] = LINE_BUFFER[i][12];
                    FAST_lb_sram_AA_w[i] = (FAST_lb_sram_AA_r[i] == 639) ? 0 : FAST_lb_sram_AA_r[i] + 1;
                    FAST_lb_sram_AB_w[i] = (FAST_lb_sram_AB_r[i] == 639) ? 0 : FAST_lb_sram_AB_r[i] + 1;
                end 
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

            // for(int k = 0; k < WIDTH+4; k = k+1) begin
            //     cos_buffer[k] <= 0;
            //     sin_buffer[k] <= 0;
            // end
            for(int j = 0; j < 5; j = j+1) begin
                LINE_BUFFER_LAST[j] <= 0;
            end
            for(int i = 0; i < 6; i = i+1) begin
                for(int j = 0; j < 13; j = j+1) begin
                    LINE_BUFFER[i][j] <= 0;
                end
            end

            for(int i = 0; i < 6; i = i+1) begin
                FAST_lb_sram_QB_r[i] <= 0;
                FAST_lb_sram_WENA_r[i] <= 1; // read
                FAST_lb_sram_WENB_r[i] <= 1; // read
                FAST_lb_sram_DA_r[i] <= 0;
                FAST_lb_sram_AA_r[i] <= 0;
                FAST_lb_sram_AB_r[i] <= 0;
            end

            for(int i = 0; i < 2; i = i+1) begin
                FAST_sincos_sram_QB_r[i] <= 0;
                FAST_sincos_sram_WENA_r[i] <= 1; // read
                FAST_sincos_sram_WENB_r[i] <= 1; // read
                FAST_sincos_sram_DA_r[i] <= 0;
                FAST_sincos_sram_AA_r[i] <= 0;
                FAST_sincos_sram_AB_r[i] <= 0;
            end

            sram_sin_delay[0] <= 0;
            sram_cos_delay[0] <= 0;
            for(int i = 1; i < 17 ; i = i+1) begin
                sram_sin_delay[i] <= 0;
                sram_cos_delay[i] <= 0;
            end

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
            
            // cos_buffer[0] <= Orient_cos;
            // sin_buffer[0] <= Orient_sin;
            // for(int k = 1; k < WIDTH+4; k = k+1) begin
            //     cos_buffer[k] <= cos_buffer[k-1];
            //     sin_buffer[k] <= sin_buffer[k-1];
            // end

            for(int j = 1; j < 5; j = j+1) begin
                LINE_BUFFER_LAST[j] <= LINE_BUFFER_LAST[j-1];
            end
            LINE_BUFFER[0][0] <= LINE_BUFFER_enter;
            LINE_BUFFER[1][0] <= FAST_lb_sram_QB_r[0];
            LINE_BUFFER[2][0] <= FAST_lb_sram_QB_r[1];
            LINE_BUFFER[3][0] <= FAST_lb_sram_QB_r[2];
            LINE_BUFFER[4][0] <= FAST_lb_sram_QB_r[3];
            LINE_BUFFER[5][0] <= FAST_lb_sram_QB_r[4];
            LINE_BUFFER_LAST[0] <= FAST_lb_sram_QB_r[5];
            for(int i = 0; i < 6; i = i+1) begin
                for(int j = 1; j < 13; j = j+1) begin
                    LINE_BUFFER[i][j] <= LINE_BUFFER[i][j-1];
                end
            end

            for(int i = 0; i < 6; i = i+1) begin
                FAST_lb_sram_QB_r[i] <= FAST_lb_sram_QB[i];
                FAST_lb_sram_WENA_r[i] <= FAST_lb_sram_WENA_w[i]; // read
                FAST_lb_sram_WENB_r[i] <= FAST_lb_sram_WENB_w[i]; // read
                FAST_lb_sram_DA_r[i] <= FAST_lb_sram_DA_w[i];
                FAST_lb_sram_AA_r[i] <= FAST_lb_sram_AA_w[i];
                FAST_lb_sram_AB_r[i] <= FAST_lb_sram_AB_w[i];
            end

            for(int i = 0; i < 2; i = i+1) begin
                FAST_sincos_sram_QB_r[i] <= FAST_sincos_sram_QB[i];
                FAST_sincos_sram_WENA_r[i] <= FAST_sincos_sram_WENA_w[i]; // read
                FAST_sincos_sram_WENB_r[i] <= FAST_sincos_sram_WENB_w[i]; // read
                FAST_sincos_sram_DA_r[i] <= FAST_sincos_sram_DA_w[i];
                FAST_sincos_sram_AA_r[i] <= FAST_sincos_sram_AA_w[i];
                FAST_sincos_sram_AB_r[i] <= FAST_sincos_sram_AB_w[i];
            end

            sram_sin_delay[0] <= FAST_sincos_sram_QB_r[0];
            sram_cos_delay[0] <= FAST_sincos_sram_QB_r[1];
            for(int i = 1; i < 17 ; i = i+1) begin
                sram_sin_delay[i] <= sram_sin_delay[i-1];
                sram_cos_delay[i] <= sram_cos_delay[i-1];
            end
        end
    end

endmodule