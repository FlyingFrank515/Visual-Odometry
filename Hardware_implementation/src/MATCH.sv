`include "HAMMING.sv"

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
    input [9:0]     i_depth,
    input [7:0]     i_score,
    input [255:0]   i_descriptor,

    output logic    o_next,
    output          o_frame_end,
    output          o_frame_start,
    output          o_valid,
    output [9:0]    o_src_coor_x,
    output [9:0]    o_src_coor_y,
    output [9:0]    o_src_depth,
    output [9:0]    o_dst_coor_x,
    output [9:0]    o_dst_coor_y,
    output [9:0]    o_dst_depth

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
    logic [2:0] state_r, state_w;

    // output logic
    logic          o_valid_r, o_valid_w;
    logic [9:0]    o_src_coor_x_r, o_src_coor_x_w;
    logic [9:0]    o_src_coor_y_r, o_src_coor_y_w;
    logic [9:0]    o_src_depth_r, o_src_depth_w;
    logic [9:0]    o_dst_coor_x_r, o_dst_coor_x_w;
    logic [9:0]    o_dst_coor_y_r, o_dst_coor_y_w;
    logic [9:0]    o_dst_depth_r, o_dst_depth_w;

    assign o_valid = o_valid_r;
    assign o_src_coor_x = o_src_coor_x_r;
    assign o_src_coor_y = o_src_coor_y_r;
    assign o_dst_coor_x = o_dst_coor_x_r;
    assign o_dst_coor_y = o_dst_coor_y_r;
    assign o_src_depth = o_src_depth_r;
    assign o_dst_depth = o_dst_depth_r;

    // --- SORT --- 
    logic [9:0] SORT_coor_x_r [0:SIZE-1], SORT_coor_x_w [0:SIZE-1];
    logic [9:0] SORT_coor_y_r [0:SIZE-1], SORT_coor_y_w [0:SIZE-1];
    logic [9:0] SORT_depth_r [0:SIZE-1], SORT_depth_w [0:SIZE-1];
    logic [7:0] SORT_score_r [0:SIZE-1], SORT_score_w [0:SIZE-1];
    logic [255:0] SORT_desc_r [0:SIZE-1], SORT_desc_w [0:SIZE-1];

    logic [9:0] SORT_comp_x_r, SORT_comp_x_w;
    logic [9:0] SORT_comp_y_r, SORT_comp_y_w;
    logic [9:0] SORT_comp_depth_r, SORT_comp_depth_w;
    logic [7:0] SORT_comp_score_r, SORT_comp_score_w;
    logic [255:0] SORT_comp_desc_r, SORT_comp_desc_w;

    logic [10:0] SORT_count_r, SORT_count_w;
    logic        SORT_finish_r, SORT_finish_w;
    logic [12:0] SORT_len_r, SORT_len_w;

    logic [9:0] SORT_target_x;
    logic [9:0] SORT_target_y;
    logic [9:0] SORT_target_depth;
    logic [7:0] SORT_target_score;
    logic [255:0] SORT_target_desc;


    // --- MIN_DISTANCE ---
    logic [9:0] COMP1_coor_x_r [0:SIZE-1], COMP1_coor_x_w [0:SIZE-1];
    logic [9:0] COMP1_coor_y_r [0:SIZE-1], COMP1_coor_y_w [0:SIZE-1];
    logic [9:0] COMP1_depth_r [0:SIZE-1], COMP1_depth_w [0:SIZE-1];
    logic [255:0] COMP1_desc_r [0:SIZE-1], COMP1_desc_w [0:SIZE-1];
    logic [12:0] COMP1_len_r, COMP1_len_w;
    
    logic [9:0] COMP2_coor_x_r [0:SIZE-1], COMP2_coor_x_w [0:SIZE-1];
    logic [9:0] COMP2_coor_y_r [0:SIZE-1], COMP2_coor_y_w [0:SIZE-1];
    logic [9:0] COMP2_depth_r [0:SIZE-1], COMP2_depth_w [0:SIZE-1];
    logic [255:0] COMP2_desc_r [0:SIZE-1], COMP2_desc_w [0:SIZE-1];
    logic [12:0] COMP2_len_r, COMP2_len_w;

    logic [12:0] COMP1_count_r, COMP1_count_w;
    logic [12:0] COMP2_count_r, COMP2_count_w;

    logic [12:0] best_count_r, best_count_w;
    logic [8:0] best_dist_r, best_dist_w;

    // connection
    logic [255:0] COMP1_target_desc, COMP2_target_desc;
    logic [12:0] COMP1_count_prev3;
    logic [9:0] COMP1_target_x, COMP1_target_y, COMP2_target_x, COMP2_target_y;
    logic [9:0] COMP1_target_depth, COMP2_target_depth;
    logic [9:0] COMP1_best_x, COMP1_best_y, COMP1_best_depth;
    logic HAMMING_valid;
    logic [8:0] HAMMING_dist;
    logic HAMMING_o_valid;

    // start end signal
    logic start_flag_r, start_flag_w;
    logic o_frame_start_r, o_frame_start_w;
    logic o_frame_end_r, o_frame_end_w;

    assign o_frame_end = o_frame_end_r;
    assign o_frame_start = o_frame_start_r;



    // ========== Combinational Block ==========
    // --- STATE MACHINE ---
    always_comb begin
        // register default value
        state_w = state_r;
        o_next = 0;
        o_frame_start_w = 0;
        o_frame_end_w = 0;
        start_flag_w = start_flag_r;
        case(state_r)
            IDLE: begin
                if(start_flag_r == 0) begin
                    o_frame_start_w = 1;
                    start_flag_w = 1;
                end 
                if(i_flag) begin
                    state_w = WORK;
                    o_next = 1;
                end
                if(i_end) begin
                    state_w = COPY;
                    o_frame_end_w = 1;
                    start_flag_w = 0;
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

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            o_frame_start_r <= 0;
            o_frame_end_r <= 0;
            start_flag_r <= 0;
        end
        else begin
            o_frame_start_r <= o_frame_start_w;
            o_frame_end_r <= o_frame_end_w;
            start_flag_r <= start_flag_w;
        end
    end
    
    // --- SORT ---
    always_comb begin
        // connection
        SORT_target_x = SORT_coor_x_r[SORT_count_r];
        SORT_target_y = SORT_coor_y_r[SORT_count_r];
        SORT_target_score = SORT_score_r[SORT_count_r];
        SORT_target_desc = SORT_desc_r[SORT_count_r];
        SORT_target_depth = SORT_depth_r[SORT_count_r];
         
        // register default value
        for(int i = 0; i < SIZE; i = i+1) begin
            SORT_coor_x_w[i] = SORT_coor_x_r[i];
            SORT_coor_y_w[i] = SORT_coor_y_r[i];
            SORT_depth_w[i] = SORT_depth_r[i];
            SORT_score_w[i] = SORT_score_r[i];
            SORT_desc_w[i] = SORT_desc_r[i];
        end
        SORT_comp_x_w = SORT_comp_x_r;
        SORT_comp_y_w = SORT_comp_y_r;
        SORT_comp_depth_w = SORT_comp_depth_r;
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
                    SORT_comp_depth_w = i_depth;
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
                        SORT_comp_depth_w = SORT_target_depth;

                        SORT_coor_x_w[SORT_count_r] = SORT_comp_x_r;
                        SORT_coor_y_w[SORT_count_r] = SORT_comp_y_r;
                        SORT_depth_w[SORT_count_r] = SORT_comp_depth_r;
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
                for(int i = 0; i < SIZE; i = i+1) begin
                    SORT_coor_x_w[i] = 0;
                    SORT_coor_y_w[i] = 0;
                    SORT_depth_w[i] = 0;
                    SORT_score_w[i] = 0;
                    SORT_desc_w[i] = 0;
                end
            end
        endcase
    end

    // --- COPY ---
    always_comb begin
        // default value
        for (i = 0; i < SIZE; i = i+1) begin
            COMP1_coor_x_w[i] = COMP1_coor_x_r[i]; 
            COMP1_coor_y_w[i] = COMP1_coor_y_r[i];
            COMP1_desc_w[i] = COMP1_desc_r[i];
            COMP1_depth_w[i] = COMP1_depth_r[i];

            COMP2_coor_x_w[i] = COMP2_coor_x_r[i]; 
            COMP2_coor_y_w[i] = COMP2_coor_y_r[i];
            COMP2_desc_w[i] = COMP2_desc_r[i];
            COMP2_depth_w[i] = COMP2_depth_r[i];
        end
        COMP1_len_w = COMP1_len_r;
        COMP2_len_w = COMP2_len_r;

        case(state_r)
            COPY: begin
                for (i = 0; i < SIZE; i = i+1) begin
                    COMP2_coor_x_w[i] = SORT_coor_x_r[i]; 
                    COMP2_coor_y_w[i] = SORT_coor_y_r[i];
                    COMP2_desc_w[i] = SORT_desc_r[i];
                    COMP2_depth_w[i] = SORT_depth_r[i];

                    COMP1_coor_x_w[i] = COMP2_coor_x_r[i]; 
                    COMP1_coor_y_w[i] = COMP2_coor_y_r[i];
                    COMP1_desc_w[i] = COMP2_desc_r[i];
                    COMP1_depth_w[i] = COMP2_depth_r[i];
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
    always_comb begin
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
        COMP1_best_depth = COMP1_depth_r[best_count_r];

        COMP1_count_prev3 = COMP1_count_r - 2;
        COMP1_target_x = COMP1_coor_x_r[COMP1_count_prev3];
        COMP1_target_y = COMP1_coor_y_r[COMP1_count_prev3];
        COMP1_target_depth = COMP1_depth_r[COMP1_count_prev3];

        COMP2_target_x = COMP2_coor_x_r[COMP2_count_r];
        COMP2_target_y = COMP2_coor_y_r[COMP2_count_r];
        COMP2_target_depth = COMP2_depth_r[COMP2_count_r];



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
                    o_dst_depth_w = COMP2_target_depth;
                    o_src_coor_x_w = COMP1_best_x;
                    o_src_coor_y_w = COMP1_best_y;
                    o_src_depth_w = COMP1_best_depth;
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
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            state_r <= 0;
            for(int i = 0; i < SIZE; i = i+1) begin
                SORT_coor_x_r[i] <= 0;
                SORT_coor_y_r[i] <= 0;
                SORT_depth_r[i] <= 0;
                SORT_score_r[i] <= 0;
                SORT_desc_r[i] <= 0;
                
                COMP1_coor_x_r[i] <= 0;
                COMP1_coor_y_r[i] <= 0;
                COMP1_depth_r[i] <= 0;
                COMP1_desc_r[i] <= 0;

                COMP2_coor_x_r[i] <= 0;
                COMP2_coor_y_r[i] <= 0;
                COMP2_depth_r[i] <= 0;
                COMP2_desc_r[i] <= 0;
            end
            SORT_comp_x_r <= 0;
            SORT_comp_y_r <= 0;
            SORT_comp_depth_r <= 0;
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
            o_src_depth_r <= 0;
            o_dst_depth_r <= 0;

            COMP1_len_r <= 0;
            COMP2_len_r <= 0;
            COMP1_count_r <= 0;
            COMP2_count_r <= 0;
            best_count_r <= 0;
            best_dist_r <= 0;
        end
            
        else begin
            state_r <= state_w;
            for(int i = 0; i < SIZE; i = i+1) begin
                SORT_coor_x_r[i] <= SORT_coor_x_w[i];
                SORT_coor_y_r[i] <= SORT_coor_y_w[i];
                SORT_depth_r[i] <= SORT_depth_w[i];
                SORT_score_r[i] <= SORT_score_w[i];
                SORT_desc_r[i] <= SORT_desc_w[i];
                
                COMP1_coor_x_r[i] <= COMP1_coor_x_w[i];
                COMP1_coor_y_r[i] <= COMP1_coor_y_w[i];
                COMP1_depth_r[i] <= COMP1_depth_w[i];
                COMP1_desc_r[i] <= COMP1_desc_w[i];

                COMP2_coor_x_r[i] <= COMP2_coor_x_w[i];
                COMP2_coor_y_r[i] <= COMP2_coor_y_w[i];
                COMP2_depth_r[i] <= COMP2_depth_w[i];
                COMP2_desc_r[i] <= COMP2_desc_w[i];
            end
            SORT_comp_x_r <= SORT_comp_x_w;
            SORT_comp_y_r <= SORT_comp_y_w;
            SORT_comp_score_r <= SORT_comp_score_w;
            SORT_comp_depth_r <= SORT_comp_depth_w;
            SORT_comp_desc_r <= SORT_comp_desc_w;
            SORT_count_r <= SORT_count_w;
            SORT_finish_r <= SORT_finish_w;
            SORT_len_r <= SORT_len_w;

            o_valid_r <= o_valid_w;
            o_src_coor_x_r <= o_src_coor_x_w;
            o_src_coor_y_r <= o_src_coor_y_w;
            o_dst_coor_x_r <= o_dst_coor_x_w;
            o_dst_coor_y_r <= o_dst_coor_y_w;
            o_src_depth_r <= o_src_depth_w;
            o_dst_depth_r <= o_dst_depth_w;

            COMP1_len_r <= COMP1_len_w;
            COMP2_len_r <= COMP2_len_w;
            COMP1_count_r <= COMP1_count_w;
            COMP2_count_r <= COMP2_count_w;
            best_count_r <= best_count_w;
            best_dist_r <= best_dist_w;
        end
    end
    
endmodule