`include "HAMMING.v"

module MATCH
#(
    parameter SIZE = 12'd500   
)
(
    input           i_clk,
    input           i_rst_n,

    input           i_flag,
    input           i_end,
    input [9:0]     i_coor_x, 
    input [9:0]     i_coor_y,
    input [7:0]     i_score,
    input [255:0]   i_descriptor,

    output reg      o_next,
    output reg      o_end,
    output          o_valid,
    output [9:0]    o_src_coor_x,
    output [9:0]    o_src_coor_y,
    output [9:0]    o_dst_coor_x,
    output [9:0]    o_dst_coor_y

);
    // parameter
    localparam IDLE = 2'd0;
    localparam WORK = 2'd1;
    localparam OUTPUT = 2'd2;
    localparam COPY = 2'd3;

    // ========== function declaration ==========

    // ========== reg/wire declaration ==========
    integer i, j;
    // --- others ---
    reg [2:0] state_r, state_w;

    // output reg
    reg          o_valid_r, o_valid_w;
    reg [9:0]    o_src_coor_x_r, o_src_coor_x_w;
    reg [9:0]    o_src_coor_y_r, o_src_coor_y_w;
    reg [9:0]    o_dst_coor_x_r, o_dst_coor_x_w;
    reg [9:0]    o_dst_coor_y_r, o_dst_coor_y_w;

    assign o_valid = o_valid_r;
    assign o_src_coor_x = o_src_coor_x_r;
    assign o_src_coor_y = o_src_coor_y_r;
    assign o_dst_coor_x = o_dst_coor_x_r;
    assign o_dst_coor_y = o_dst_coor_y_r;

    // --- SORT --- 
    reg [9:0] SORT_coor_x_r [0:SIZE-1], SORT_coor_x_w [0:SIZE-1];
    reg [9:0] SORT_coor_y_r [0:SIZE-1], SORT_coor_y_w [0:SIZE-1];
    reg [7:0] SORT_score_r [0:SIZE-1], SORT_score_w [0:SIZE-1];
    reg [255:0] SORT_desc_r [0:SIZE-1], SORT_desc_w [0:SIZE-1];

    reg [9:0] SORT_comp_x_r, SORT_comp_x_w;
    reg [9:0] SORT_comp_y_r, SORT_comp_y_w;
    reg [7:0] SORT_comp_score_r, SORT_comp_score_w;
    reg [255:0] SORT_comp_desc_r, SORT_comp_desc_w;

    reg [10:0] SORT_count_r, SORT_count_w;
    reg        SORT_finish_r, SORT_finish_w;
    reg [12:0] SORT_len_r, SORT_len_w;

    reg [9:0] SORT_target_x;
    reg [9:0] SORT_target_y;
    reg [7:0] SORT_target_score;
    reg [255:0] SORT_target_desc;


    // --- MIN_DISTANCE ---
    reg [9:0] COMP1_coor_x_r [0:SIZE-1], COMP1_coor_x_w [0:SIZE-1];
    reg [9:0] COMP1_coor_y_r [0:SIZE-1], COMP1_coor_y_w [0:SIZE-1];
    reg [255:0] COMP1_desc_r [0:SIZE-1], COMP1_desc_w [0:SIZE-1];
    reg [12:0] COMP1_len_r, COMP1_len_w;
    
    reg [9:0] COMP2_coor_x_r [0:SIZE-1], COMP2_coor_x_w [0:SIZE-1];
    reg [9:0] COMP2_coor_y_r [0:SIZE-1], COMP2_coor_y_w [0:SIZE-1];
    reg [255:0] COMP2_desc_r [0:SIZE-1], COMP2_desc_w [0:SIZE-1];
    reg [12:0] COMP2_len_r, COMP2_len_w;

    reg [12:0] COMP1_count_r, COMP1_count_w;
    reg [12:0] COMP2_count_r, COMP2_count_w;

    reg [12:0] best_count_r, best_count_w;
    reg [8:0] best_dist_r, best_dist_w;

    // connection
    reg [255:0] COMP1_target_desc, COMP2_target_desc;
    reg [12:0] COMP1_count_prev3;
    reg [9:0] COMP1_target_x, COMP1_target_y, COMP2_target_x, COMP2_target_y;
    reg [9:0] COMP1_best_x, COMP1_best_y;
    reg HAMMING_valid;
    wire [8:0] HAMMING_dist;
    wire HAMMING_o_valid;



    // ========== Combinational Block ==========
    // --- STATE MACHINE ---
    always@(*) begin
        // register default value
        state_w = state_r;
        o_next = 0;
        o_end = 0;
        case(state_r)
            IDLE: begin
                if(i_flag) begin
                    state_w = WORK;
                    o_next = 1;
                end
                if(i_end) begin
                    state_w = COPY;
                    o_end = 1;
                end
            end
            WORK: begin
                if(SORT_finish_r) begin
                    state_w = IDLE;
                end
            end
            COPY: begin
                state_w = IDLE;
            end
        endcase
    end
    
    // --- SORT ---
    always@(*) begin
        // connection
        SORT_target_x = SORT_coor_x_r[SORT_count_r];
        SORT_target_y = SORT_coor_y_r[SORT_count_r];
        SORT_target_score = SORT_score_r[SORT_count_r];
        SORT_target_desc = SORT_desc_r[SORT_count_r];
         
        // register default value
        for(i = 0; i < SIZE; i = i+1) begin
            SORT_coor_x_w[i] = SORT_coor_x_r[i];
            SORT_coor_y_w[i] = SORT_coor_y_r[i];
            SORT_score_w[i] = SORT_score_r[i];
            SORT_desc_w[i] = SORT_desc_r[i];
        end
        SORT_comp_x_w = SORT_comp_x_r;
        SORT_comp_y_w = SORT_comp_y_r;
        SORT_comp_score_w = SORT_comp_score_r;
        SORT_comp_desc_w = SORT_comp_desc_r;
        SORT_finish_w = SORT_finish_r;
        SORT_count_w = SORT_count_r;
        SORT_len_w = SORT_len_r;

        case(state_r)
            IDLE: begin
                SORT_finish_w = 0;
                if(i_flag) begin
                    SORT_comp_x_w = i_coor_x;
                    SORT_comp_y_w = i_coor_y;
                    SORT_comp_score_w = i_score;
                    SORT_comp_desc_w = i_descriptor;
                    SORT_count_w = 0;
                    SORT_finish_w = 0;
                    SORT_len_w = SORT_len_r < 500 ? SORT_len_r + 1 : 500;
                end
            end
            WORK: begin
                if(!SORT_finish_r) begin
                    SORT_count_w = SORT_count_r + 1;
                    // insert and move behind forward
                    if(SORT_comp_score_r > SORT_target_score) begin
                        // swap 
                        SORT_comp_x_w = SORT_target_x;
                        SORT_comp_y_w = SORT_target_y;
                        SORT_comp_score_w = SORT_target_score;
                        SORT_comp_desc_w = SORT_target_desc;

                        SORT_coor_x_w[SORT_count_r] = SORT_comp_x_r;
                        SORT_coor_y_w[SORT_count_r] = SORT_comp_y_r;
                        SORT_score_w[SORT_count_r] = SORT_comp_score_r;
                        SORT_desc_w[SORT_count_r] = SORT_comp_desc_r;
                    end
                    if(SORT_count_r == SORT_len_r - 1) begin
                        SORT_finish_w = 1;
                    end
                end 
            end
            COPY: begin
                SORT_len_w = 0;
                for(i = 0; i < SIZE; i = i+1) begin
                    SORT_coor_x_w[i] = 0;
                    SORT_coor_y_w[i] = 0;
                    SORT_score_w[i] = 0;
                    SORT_desc_w[i] = 0;
                end
            end
        endcase
    end

    // --- COPY ---
    always@(*) begin
        // default value
        for (i = 0; i < SIZE; i = i+1) begin
            COMP1_coor_x_w[i] = COMP1_coor_x_r[i]; 
            COMP1_coor_y_w[i] = COMP1_coor_y_r[i];
            COMP1_desc_w[i] = COMP1_desc_r[i];

            COMP2_coor_x_w[i] = COMP2_coor_x_r[i]; 
            COMP2_coor_y_w[i] = COMP2_coor_y_r[i];
            COMP2_desc_w[i] = COMP2_desc_r[i];
        end
        COMP1_len_w = COMP1_len_r;
        COMP2_len_w = COMP2_len_r;

        case(state_r)
            COPY: begin
                for (i = 0; i < SIZE; i = i+1) begin
                    COMP2_coor_x_w[i] = SORT_coor_x_r[i]; 
                    COMP2_coor_y_w[i] = SORT_coor_y_r[i];
                    COMP2_desc_w[i] = SORT_desc_r[i];

                    COMP1_coor_x_w[i] = COMP2_coor_x_r[i]; 
                    COMP1_coor_y_w[i] = COMP2_coor_y_r[i];
                    COMP1_desc_w[i] = COMP2_desc_r[i];
                end
                COMP2_len_w = SORT_len_r;
                COMP1_len_w = COMP2_len_r;
            end
        endcase

    end

    HAMMING dist_unit(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),

        .i_valid(HAMMING_valid),
        .i_src_desc(COMP1_target_desc),
        .i_dst_desc(COMP2_target_desc),
        .o_dist(HAMMING_dist),
        .o_valid(HAMMING_o_valid)
    );

    // --- MIN_DISTANCE ---
    // for each keypoints in comp2 array, find the closet keypoint in comp1 array
    always@(*) begin
        // default
        COMP1_count_w = COMP1_count_r;
        COMP2_count_w = COMP2_count_r;
        best_count_w = best_count_r;
        best_dist_w = best_dist_r;

        o_src_coor_x_w = 0;
        o_src_coor_y_w = 0;
        o_dst_coor_x_w = 0;
        o_dst_coor_y_w = 0;
        o_valid_w = 0;

        // connection
        COMP1_target_desc = COMP1_desc_r[COMP1_count_r];
        COMP2_target_desc = COMP2_desc_r[COMP2_count_r];
        HAMMING_valid = COMP1_count_r < COMP1_len_r && COMP2_count_r < COMP2_len_r;
        COMP1_best_x = COMP1_coor_x_r[best_count_r];
        COMP1_best_y = COMP1_coor_y_r[best_count_r];

        COMP1_count_prev3 = COMP1_count_r - 2;
        COMP1_target_x = COMP1_coor_x_r[COMP1_count_prev3];
        COMP1_target_y = COMP1_coor_y_r[COMP1_count_prev3];

        COMP2_target_x = COMP2_coor_x_r[COMP2_count_r];
        COMP2_target_y = COMP2_coor_y_r[COMP2_count_r];



        if(state_r == COPY) begin // RESET
            COMP1_count_w = 0;
            COMP2_count_w = 0;
            best_dist_w = 9'b111111111;
        end

        if(COMP2_count_r < COMP2_len_r) begin
            if(HAMMING_o_valid && COMP1_count_r > 1) begin
                if(HAMMING_dist < best_dist_r) begin
                    best_dist_w = HAMMING_dist;
                    best_count_w = COMP1_count_prev3;
                end
            end
            COMP1_count_w = COMP1_count_r + 1;
            // output
            if(COMP1_count_prev3 == COMP1_len_r - 1) begin
                // output reg
                if(best_dist_r <= 30) begin
                    o_dst_coor_x_w = COMP2_target_x;
                    o_dst_coor_y_w = COMP2_target_y;
                    o_src_coor_x_w = COMP1_best_x;
                    o_src_coor_y_w = COMP1_best_y;
                    o_valid_w = 1;
                end
                
                // move comp2_count forward
                COMP2_count_w = COMP2_count_r + 1;
                COMP1_count_w = 0;
                best_dist_w = 9'b111111111;
            end
        end
    end


    // ========== Sequential Block ==========
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            state_r <= 0;
            for(i = 0; i < SIZE; i = i+1) begin
                SORT_coor_x_r[i] <= 0;
                SORT_coor_y_r[i] <= 0;
                SORT_score_r[i] <= 0;
                SORT_desc_r[i] <= 0;
                
                COMP1_coor_x_r[i] <= 0;
                COMP1_coor_y_r[i] <= 0;
                COMP1_desc_r[i] <= 0;

                COMP2_coor_x_r[i] <= 0;
                COMP2_coor_y_r[i] <= 0;
                COMP2_desc_r[i] <= 0;
            end
            SORT_comp_x_r <= 0;
            SORT_comp_y_r <= 0;
            SORT_comp_score_r <= 0;
            SORT_comp_desc_r <= 0;
            SORT_count_r <= 0;
            SORT_finish_r <= 0;
            SORT_len_r <= 0;

            o_valid_r <= 0;
            o_src_coor_x_r <= 0;
            o_src_coor_y_r <= 0;
            o_dst_coor_x_r <= 0;
            o_dst_coor_y_r <= 0;

            COMP1_len_r <= 0;
            COMP2_len_r <= 0;
            COMP1_count_r <= 0;
            COMP2_count_r <= 0;
            best_count_r <= 0;
            best_dist_r <= 0;
        end
            
        else begin
            state_r <= state_w;
            for(i = 0; i < SIZE; i = i+1) begin
                SORT_coor_x_r[i] <= SORT_coor_x_w[i];
                SORT_coor_y_r[i] <= SORT_coor_y_w[i];
                SORT_score_r[i] <= SORT_score_w[i];
                SORT_desc_r[i] <= SORT_desc_w[i];
                
                COMP1_coor_x_r[i] <= COMP1_coor_x_w[i];
                COMP1_coor_y_r[i] <= COMP1_coor_y_w[i];
                COMP1_desc_r[i] <= COMP1_desc_w[i];

                COMP2_coor_x_r[i] <= COMP2_coor_x_w[i];
                COMP2_coor_y_r[i] <= COMP2_coor_y_w[i];
                COMP2_desc_r[i] <= COMP2_desc_w[i];
            end
            SORT_comp_x_r <= SORT_comp_x_w;
            SORT_comp_y_r <= SORT_comp_y_w;
            SORT_comp_score_r <= SORT_comp_score_w;
            SORT_comp_desc_r <= SORT_comp_desc_w;
            SORT_count_r <= SORT_count_w;
            SORT_finish_r <= SORT_finish_w;
            SORT_len_r <= SORT_len_w;

            o_valid_r <= o_valid_w;
            o_src_coor_x_r <= o_src_coor_x_w;
            o_src_coor_y_r <= o_src_coor_y_w;
            o_dst_coor_x_r <= o_dst_coor_x_w;
            o_dst_coor_y_r <= o_dst_coor_y_w;

            COMP1_len_r <= COMP1_len_w;
            COMP2_len_r <= COMP2_len_w;
            COMP1_count_r <= COMP1_count_w;
            COMP2_count_r <= COMP2_count_w;
            best_count_r <= best_count_w;
            best_dist_r <= best_dist_w;
        end
    end
    
endmodule