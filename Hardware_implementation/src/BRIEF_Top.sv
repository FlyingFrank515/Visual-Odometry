`include "BRIEF.sv"
`include "Key_Buffer1.sv"

module BRIEF_Top
#(
    parameter WIDTH = 12'd640,
    parameter HEIGHT = 12'd480
)
(
    input           i_clk,
    input           i_rst_n,
    input           i_point_valid,
    input           i_pixel_valid,
    input [7:0]     i_pixel,
    input           i_start,
    input           i_end,

    input           i_flag,
    input [11:0]    i_sin,
    input [11:0]    i_cos,
    input [9:0]     i_coor_x, 
    input [9:0]     i_coor_y, 
    input [7:0]     i_score,
    input [9:0]     i_depth,

    output [9:0]    o_coordinate_X,
    output [9:0]    o_coordinate_Y,
    output [255:0]  o_descriptor,
    output [9:0]    o_depth,
    output [7:0]    o_score,
    output          o_flag,
    output logic    o_start,
    output logic      o_end,

    // sram interface -- BRIEF window
    input [7:0]     BRIEF_lb_sram_QA [30],
    input [7:0]     BRIEF_lb_sram_QB [30],
    output          BRIEF_lb_sram_WENA [30],
    output          BRIEF_lb_sram_WENB [30],
    output [7:0]    BRIEF_lb_sram_DA [30],
    output [7:0]    BRIEF_lb_sram_DB [30],
    output [9:0]    BRIEF_lb_sram_AA [30],
    output [9:0]    BRIEF_lb_sram_AB [30]

    // // sram interface -- BRIEF window
    // input [51:0]     BRIEF_keybuf_sram_QA,
    // input [51:0]     BRIEF_keybuf_sram_QB,
    // output          BRIEF_keybuf_sram_WENA,
    // output          BRIEF_keybuf_sram_WENB,
    // output [51:0]    BRIEF_keybuf_sram_DA,
    // output [51:0]    BRIEF_keybuf_sram_DB,
    // output [6:0]    BRIEF_keybuf_sram_AA,
    // output [6:0]    BRIEF_keybuf_sram_AB

);
    // parameter
    localparam S_IDLE = 3'd0;
    localparam S_WAIT1 = 3'd1;
    localparam S_WAIT2 = 3'd2;
    localparam S_WORK = 3'd3;

    // ========== reg/wire declaration ==========
    integer i, j, k;
    logic [2:0] state_w, state_r;
    logic [19:0] count_w, count_r;
    logic [9:0] coor_x_w, coor_x_r;
    logic [9:0] coor_y_w, coor_y_r;
    logic start_delay_r, start_delay_w;
    logic [7:0] LINE_BUFFER_enter;
    logic [7:0] LINE_BUFFER [0:29][0:WIDTH-1];
    logic [7:0] LINE_BUFFER_LAST [0:31];

    logic BUFFER_hit;
    logic [11:0] BUFFER_sin, BUFFER_cos;
    logic [9:0] BUFFER_x, BUFFER_y;
    logic [7:0] BUFFER_score;
    logic [9:0] BUFFER_depth;

    logic [7:0] window [0:30][0:30];

    // BRIEF_lb_sram interface
    logic [7:0]    BRIEF_lb_sram_QB_r [0:29];
    logic          BRIEF_lb_sram_WENA_w [0:29], BRIEF_lb_sram_WENA_r [0:29];
    logic          BRIEF_lb_sram_WENB_w [0:29], BRIEF_lb_sram_WENB_r [0:29];
    logic [7:0]    BRIEF_lb_sram_DA_w [0:29], BRIEF_lb_sram_DA_r [0:29];
    logic [9:0]    BRIEF_lb_sram_AA_w [0:29], BRIEF_lb_sram_AA_r [0:29];
    logic [9:0]    BRIEF_lb_sram_AB_w [0:29], BRIEF_lb_sram_AB_r [0:29];

    logic [7:0] inspect1, inspect2;
    assign inspect1 = LINE_BUFFER[0][639];
    assign inspect2 = BRIEF_lb_sram_QB_r[0];

    Key_Buffer1 
    #(
        .SIZE(12'd100)   
    )
    buffer
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_flag(i_flag && i_point_valid),
        .i_hit(BUFFER_hit),
        .i_depth(i_depth),
        .i_sin(i_sin),
        .i_cos(i_cos),
        .i_coor_x(i_coor_x), 
        .i_coor_y(i_coor_y), 
        .i_score(i_score),

        .o_sin(BUFFER_sin),
        .o_cos(BUFFER_cos),
        .o_coor_x(BUFFER_x), 
        .o_coor_y(BUFFER_y),
        .o_score(BUFFER_score),
        .o_depth(BUFFER_depth)
    );

    BRIEF brief_unit
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        
        .i_window(window),

        .i_coor_x(coor_x_r), 
        .i_coor_y(coor_y_r), 
        .i_score(BUFFER_score),
        .i_depth(BUFFER_depth),

        .i_sin(BUFFER_sin),
        .i_cos(BUFFER_cos),
        .i_buf_coor_x(BUFFER_x), 
        .i_buf_coor_y(BUFFER_y), 

        .o_hit(BUFFER_hit),
        .o_coor_x(o_coordinate_X), 
        .o_coor_y(o_coordinate_Y), 
        .o_depth(o_depth),
        .o_descriptor(o_descriptor),
        .o_flag(o_flag),
        .o_score(o_score)

        // .BRIEF_keybuf_sram_QA(BRIEF_keybuf_sram_QA),
        // .BRIEF_keybuf_sram_QB(BRIEF_keybuf_sram_QB),
        // .BRIEF_keybuf_sram_WENA(BRIEF_keybuf_sram_WENA),
        // .BRIEF_keybuf_sram_WENB(BRIEF_keybuf_sram_WENB),
        // .BRIEF_keybuf_sram_DA(BRIEF_keybuf_sram_DA),
        // .BRIEF_keybuf_sram_DB(BRIEF_keybuf_sram_DB),
        // .BRIEF_keybuf_sram_AA(BRIEF_keybuf_sram_AA),
        // .BRIEF_keybuf_sram_AB(BRIEF_keybuf_sram_AB)
    );


    // ========== Connection ==========
    // FAST_lb_sram connection
    for(genvar i = 0; i < 30; i = i+1) begin
        assign BRIEF_lb_sram_WENA[i] = BRIEF_lb_sram_WENA_r[i];
        assign BRIEF_lb_sram_WENB[i] = BRIEF_lb_sram_WENB_r[i];
        assign BRIEF_lb_sram_DA[i] = BRIEF_lb_sram_DA_r[i];
        assign BRIEF_lb_sram_DB[i] = 0;
        assign BRIEF_lb_sram_AA[i] = BRIEF_lb_sram_AA_r[i];
        assign BRIEF_lb_sram_AB[i] = BRIEF_lb_sram_AB_r[i];
    end

    always_comb begin
        for(int j = 0; j < 31; j = j+1) begin
            window[0][j] = LINE_BUFFER_LAST[30-j];
        end
        for(int i = 1; i < 31; i = i+1) begin
            for (int j = 0; j < 31; j = j+1) begin
                window[i][j] = LINE_BUFFER[30-i][30-j];
            end           
        end
        // for(int i = 0; i < 30; i = i+1) begin
        //     for (int j = 0; j < 31; j = j+1) begin
        //         window[i][j] = LINE_BUFFER[i][j];
        //     end           
        // end
        // for (int j = 0; j < 31; j = j+1) begin
        //     window[30][j] = LINE_BUFFER_LAST[j];
        // end      
    end

    

    // ========== Combinational Block ==========
    always_comb begin
        state_w = state_r;
        count_w = count_r;
        coor_x_w = coor_x_r;
        coor_y_w = coor_y_r;
        // start_delay_w = start_delay_r;
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

                if((coor_x_r == WIDTH-1 && coor_y_r == HEIGHT-1)) begin
                    o_end = 1;
                    state_w = S_IDLE;
                    coor_x_w = 0;
                    coor_y_w = 0;
                end
                if(i_start) begin
                    o_end = 1;
                    state_w = S_WAIT2;
                    LINE_BUFFER_enter = i_pixel;
                    count_w = 0;
                    o_start = 1;
                end
            end
        endcase
    end

    // line buffer
    always_comb begin
        for(int i = 0; i < 30; i = i+1) begin
            BRIEF_lb_sram_WENA_w[i] = 1; // 1 for read
            BRIEF_lb_sram_WENB_w[i] = 1;
            BRIEF_lb_sram_DA_w[i] = BRIEF_lb_sram_DA_r[i];
            BRIEF_lb_sram_AA_w[i] = BRIEF_lb_sram_AA_r[i];
            BRIEF_lb_sram_AB_w[i] = BRIEF_lb_sram_AB_r[i];
        end
        case(state_r)
            S_IDLE: begin
                if(i_start) begin
                    for(int i = 0; i < 30; i = i+1) begin
                        BRIEF_lb_sram_WENA_w[i] = 0;
                        BRIEF_lb_sram_WENB_w[i] = 1;
                        BRIEF_lb_sram_DA_w[i] = LINE_BUFFER[i][30];
                        BRIEF_lb_sram_AA_w[i] = 608;
                        BRIEF_lb_sram_AB_w[i] = 0;
                    end
                end
            end
            S_WAIT2: begin
                for(int i = 0; i < 30; i = i+1) begin
                    BRIEF_lb_sram_WENA_w[i] = 0;
                    BRIEF_lb_sram_WENB_w[i] = 1;
                    BRIEF_lb_sram_DA_w[i] = LINE_BUFFER[i][30];
                    BRIEF_lb_sram_AA_w[i] = (BRIEF_lb_sram_AA_r[i] == 639) ? 0 : BRIEF_lb_sram_AA_r[i] + 1;
                    BRIEF_lb_sram_AB_w[i] = (BRIEF_lb_sram_AB_r[i] == 639) ? 0 : BRIEF_lb_sram_AB_r[i] + 1;
                end   
            end
            S_WORK: begin
                for(int i = 0; i < 30; i = i+1) begin
                    BRIEF_lb_sram_WENA_w[i] = 0;
                    BRIEF_lb_sram_WENB_w[i] = 1;
                    BRIEF_lb_sram_DA_w[i] = LINE_BUFFER[i][30];
                    BRIEF_lb_sram_AA_w[i] = (BRIEF_lb_sram_AA_r[i] == 639) ? 0 : BRIEF_lb_sram_AA_r[i] + 1;
                    BRIEF_lb_sram_AB_w[i] = (BRIEF_lb_sram_AB_r[i] == 639) ? 0 : BRIEF_lb_sram_AB_r[i] + 1;
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
            // start_delay_r <= 0;

            for(int j = 0; j < 32; j = j+1) begin
                LINE_BUFFER_LAST[j] <= 0;
            end
            for(int i = 0; i < 30; i = i+1) begin
                for(int j = 0; j < WIDTH; j = j+1) begin
                    LINE_BUFFER[i][j] <= 0;
                end
            end

            for(int i = 0; i < 30; i = i+1) begin
                BRIEF_lb_sram_QB_r[i] <= 0;
                BRIEF_lb_sram_WENA_r[i] <= 1; // read
                BRIEF_lb_sram_WENB_r[i] <= 1; // read
                BRIEF_lb_sram_DA_r[i] <= 0;
                BRIEF_lb_sram_AA_r[i] <= 0;
                BRIEF_lb_sram_AB_r[i] <= 0;
            end
        end
        else if(i_pixel_valid) begin
            state_r <= state_w;
            count_r <= count_w;
            coor_x_r <= coor_x_w;
            coor_y_r <= coor_y_w;
            // start_delay_r <= start_delay_w;

            LINE_BUFFER_LAST[0] <= LINE_BUFFER[29][WIDTH-1];
            for(int j = 1; j < 32; j = j+1) begin
                LINE_BUFFER_LAST[j] <= LINE_BUFFER_LAST[j-1];
            end
            LINE_BUFFER[0][0] <= LINE_BUFFER_enter;
            for(int i = 1; i < 30; i = i+1) begin
                LINE_BUFFER[i][0] <= LINE_BUFFER[i-1][WIDTH-1];
            end
            for(int i = 0; i < 30; i = i+1) begin
                for(int j = 1; j < WIDTH; j = j+1) begin
                    LINE_BUFFER[i][j] <= LINE_BUFFER[i][j-1];
                end
            end

            for(int i = 0; i < 30; i = i+1) begin
                BRIEF_lb_sram_QB_r[i] <= BRIEF_lb_sram_QB[i];
                BRIEF_lb_sram_WENA_r[i] <= BRIEF_lb_sram_WENA_w[i];
                BRIEF_lb_sram_WENB_r[i] <= BRIEF_lb_sram_WENB_w[i];
                BRIEF_lb_sram_DA_r[i] <= BRIEF_lb_sram_DA_w[i];
                BRIEF_lb_sram_AA_r[i] <= BRIEF_lb_sram_AA_w[i];
                BRIEF_lb_sram_AB_r[i] <= BRIEF_lb_sram_AB_w[i];
            end
        end
    end

endmodule