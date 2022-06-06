module MATCH
#(
    parameter SIZE = 12'd500   
)
(
    input           i_clk,
    input           i_rst_n,

    input           i_flag,
    input           i_next,
    input [9:0]     i_coor_x, 
    input [9:0]     i_coor_y,
    input [7:0]     i_score,
    input [255:0]   i_descriptor,

    output reg          o_next,
    output reg          o_end,
    output reg          o_valid,
    output reg [9:0]    o_src_coor_x,
    output reg [9:0]    o_src_coor_y,
    output reg [9:0]    o_dst_coor_x,
    output reg [9:0]    o_dst_coor_y

);
    // parameter
    localparam IDLE = 2'd0;
    localparam WORK = 2'd1;
    localparam OUTPUT = 2'd2;
    localparam COPY = 2'd3;

    localparam SUB1 = 2'd1;
    localparam SUB2 = 2'd2;
    localparam SUB3 = 2'd3;

    // ========== function declaration ==========

    // ========== reg/wire declaration ==========
    integer i, j;
    // --- others ---
    reg [2:0] state_r, state_w;
    
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
    reg [9:0] DIST_coor_x_r [0:SIZE-1], DIST_coor_x_w [0:SIZE-1];
    reg [9:0] DIST_coor_y_r [0:SIZE-1], DIST_coor_y_w [0:SIZE-1];
    reg [255:0] DIST_desc_r [0:SIZE-1], DIST_desc_w [0:SIZE-1];

    reg [9:0] DIST_comp_x_r, DIST_comp_x_w;
    reg [9:0] DIST_comp_y_r, DIST_comp_y_w;
    reg [255:0] DIST_comp_desc_r, DIST_comp_desc_w;

    reg [7:0] DIST_min_r, DIST_min_w;
    reg [9:0] DIST_best_x_r, DIST_best_x_w;
    reg [9:0] DIST_best_y_r, DIST_best_y_w;

    reg [255:0] DIST_result_r, DIST_result_w;
    reg         DIST_finish_r, DIST_finish_w;

    reg [10:0] DIST_count_r, DIST_count_w;
    reg [5:0] DIST_partial_sum_w [0:7], DIST_partial_sum_r [0:7];
    reg [8:0] DIST_hamming_r, DIST_hamming_w;
    reg [12:0] DIST_len_w, DIST_len_r;
    reg [2:0] sub_state_w, sub_state_r;

    reg [9:0] DIST_target_x;
    reg [9:0] DIST_target_y;
    reg [255:0] DIST_target_desc;

    reg [1:0] DIST_sum_layer1 [0:127];
    reg [2:0] DIST_sum_layer2 [0:63];
    reg [3:0] DIST_sum_layer3 [0:31];
    reg [4:0] DIST_sum_layer4 [0:15];

    reg [6:0] DIST_sum_layer5 [0:3];
    reg [7:0] DIST_sum_layer6 [0:1];


    // ========== Combinational Block ==========
    // --- STATE & OUTPUT ---
    always@(*) begin
        // register default value
        state_w = state_r;
        o_next = 0;
        o_end = 0;
        o_valid = 0;
        o_src_coor_x = 0;
        o_src_coor_y = 0;
        o_dst_coor_x = 0;
        o_dst_coor_y = 0;

        case(state_r)
            IDLE: begin
                if(i_flag) begin
                    state_w = WORK;
                    o_next = 1;
                end
                if(i_next) begin
                    state_w = COPY;
                    o_end = 1;
                end
            end
            WORK: begin
                if(DIST_finish_r && SORT_finish_r) begin
                    state_w = OUTPUT;
                end
            end
            OUTPUT: begin
                state_w = IDLE;
                o_valid = 0;
                o_src_coor_x = DIST_best_x_r;
                o_src_coor_y = DIST_best_y_r;
                o_dst_coor_x = DIST_comp_x_r;
                o_dst_coor_y = DIST_comp_y_r;
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
            OUTPUT: begin
                
            end
            COPY: begin
                SORT_len_w = 0;
            end
        endcase
    end

    // --- MIN_DISTANCE ---
    always@(*) begin
        // connection
        DIST_target_x = DIST_coor_x_r[DIST_count_r];
        DIST_target_y = DIST_coor_y_r[DIST_count_r];
        DIST_target_desc = DIST_desc_r[DIST_count_r];

        for(j = 0; j < 128; j = j+1) begin
            DIST_sum_layer1[j] = DIST_result_r[j] + DIST_result_r[j+128];
        end
        for(j = 0; j < 64; j = j+1) begin
            DIST_sum_layer2[j] = DIST_sum_layer1[j] + DIST_sum_layer1[j+64];
        end
        for(j = 0; j < 32; j = j+1) begin
            DIST_sum_layer3[j] = DIST_sum_layer2[j] + DIST_sum_layer2[j+32];
        end
        for(j = 0; j < 16; j = j+1) begin
            DIST_sum_layer4[j] = DIST_sum_layer3[j] + DIST_sum_layer3[j+16];
        end
        for(j = 0; j < 8; j = j+1) begin
            DIST_partial_sum_w[j] = DIST_sum_layer4[j] + DIST_sum_layer4[j+8];
        end
        for(j = 0; j < 4; j = j+1) begin
            DIST_sum_layer5[j] = DIST_partial_sum_r[j] + DIST_partial_sum_r[j+4];
        end
        for(j = 0; j < 2; j = j+1) begin
            DIST_sum_layer6[j] = DIST_sum_layer5[j] + DIST_sum_layer5[j+2];
        end
        
         
        // register default value
        for(i = 0; i < SIZE; i = i+1) begin
            DIST_coor_x_w[i] = DIST_coor_x_r[i];
            DIST_coor_y_w[i] = DIST_coor_y_r[i];
            DIST_desc_w[i] = DIST_desc_r[i];
        end
        DIST_comp_x_w = DIST_comp_x_r;
        DIST_comp_y_w = DIST_comp_y_r;
        DIST_comp_desc_w = DIST_comp_desc_r;
        DIST_finish_w = DIST_finish_w;

        DIST_best_x_w = DIST_best_x_r;
        DIST_best_y_w = DIST_best_y_r;
        DIST_min_w = DIST_min_r;
        DIST_count_w = DIST_count_r;
        DIST_result_w = DIST_result_r;
        DIST_hamming_w = DIST_hamming_r;
        DIST_len_w = DIST_len_r;

        for(i = 0; i < 16; i = i+1) begin
            DIST_partial_sum_w[i] = DIST_partial_sum_r[i];
        end
        
        sub_state_w = sub_state_r;

        case(state_r)
            IDLE: begin
                DIST_finish_w = 0;
                if(i_flag) begin
                    DIST_comp_x_w = i_coor_x;
                    DIST_comp_y_w = i_coor_y;
                    DIST_comp_desc_w = i_descriptor;
                    DIST_count_w = 0;
                    DIST_finish_w = 0;

                    DIST_best_x_w = 0;
                    DIST_best_y_w = 0;
                    DIST_min_w = 255;
                    DIST_result_w = i_descriptor ^ DIST_desc_r[0];
                    
                    sub_state_w = SUB1;
                end
            end
            WORK: begin
                if(!DIST_finish_r) begin
                    case(sub_state_r)
                        SUB1: begin
                            // count partial sum
                            sub_state_w = SUB2;
                        end
                        SUB2: begin
                            // count hamming distance
                            sub_state_w = SUB3;
                            DIST_hamming_w = DIST_sum_layer6[0] + DIST_sum_layer6[1];
                        end
                        SUB3: begin
                            if(DIST_hamming_r < DIST_min_r) begin
                                DIST_best_x_w = DIST_target_x;
                                DIST_best_y_w = DIST_target_y;
                                DIST_min_w = DIST_hamming_r;
                            end
                            DIST_count_w = DIST_count_r + 1;
                            sub_state_w = SUB1;
                        end
                    endcase
                    if(DIST_count_r == DIST_len_r - 1) begin
                        DIST_finish_w = 1;
                    end
                end
            end
            OUTPUT: begin
            end
            COPY: begin
                for(i = 0; i < SIZE; i = i+1) begin
                    DIST_coor_x_w[i] = SORT_coor_x_r[i];
                    DIST_coor_y_w[i] = SORT_coor_y_r[i];
                    DIST_desc_w[i] = SORT_desc_r[i];
                end
                DIST_len_w = SORT_len_r;
            end
        endcase
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
                
                DIST_coor_x_r[i] <= 0;
                DIST_coor_y_r[i] <= 0;
                DIST_desc_r[i] <= 0;
            end
            SORT_comp_x_r <= 0;
            SORT_comp_y_r <= 0;
            SORT_comp_score_r <= 0;
            SORT_comp_desc_r <= 0;
            SORT_count_r <= 0;
            SORT_finish_r <= 0;
            SORT_len_r <= 0;

            DIST_comp_x_r <= 0;
            DIST_comp_y_r <= 0;
            DIST_comp_desc_r <= 0;
            DIST_min_r <= 0;
            DIST_best_x_r <= 0;
            DIST_best_y_r <= 0;
            DIST_finish_r <= 0;
            DIST_result_r <= 0;
            DIST_count_r <= 0;
            DIST_hamming_r <= 0;
            DIST_len_r <= 0;
            sub_state_r <= 0;

            for(i = 0; i < 8; i = i+1) begin
                DIST_partial_sum_r[i] <= 0;
            end
            
        end
        else begin
            state_r <= state_w;
            for(i = 0; i < SIZE; i = i+1) begin
                SORT_coor_x_r[i] <= SORT_coor_x_w[i];
                SORT_coor_y_r[i] <= SORT_coor_y_w[i];
                SORT_score_r[i] <= SORT_score_w[i];
                SORT_desc_r[i] <= SORT_desc_w[i];
                
                DIST_coor_x_r[i] <= DIST_coor_x_w[i];
                DIST_coor_y_r[i] <= DIST_coor_y_w[i];
                DIST_desc_r[i] <= DIST_desc_w[i];
            end
            SORT_comp_x_r <= SORT_comp_x_w;
            SORT_comp_y_r <= SORT_comp_y_w;
            SORT_comp_score_r <= SORT_comp_score_w;
            SORT_comp_desc_r <= SORT_comp_desc_w;
            SORT_count_r <= SORT_count_w;
            SORT_finish_r <= SORT_finish_w;
            SORT_len_r <= SORT_len_w;

            DIST_comp_x_r <= DIST_comp_x_w;
            DIST_comp_y_r <= DIST_comp_y_w;
            DIST_comp_desc_r <= DIST_comp_desc_w;
            DIST_min_r <= DIST_min_w;
            DIST_best_x_r <= DIST_best_x_w;
            DIST_best_y_r <= DIST_best_y_w;
            DIST_finish_r <= DIST_finish_w;
            DIST_result_r <= DIST_finish_w;
            DIST_count_r <= DIST_count_w;
            DIST_hamming_r <= DIST_hamming_w;
            DIST_len_r <= DIST_len_w;
            sub_state_r <= sub_state_w;

            for(i = 0; i < 8; i = i+1) begin
                DIST_partial_sum_r[i] <= DIST_partial_sum_w[i];
            end

            
        end
    end
    
endmodule