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
    output [9:0]    o_dst_depth,

    // to memory controller
    output logic [10:0]   mem1_addr,
    output logic [285:0]  mem1_wdata,
    output logic         mem1_wen,
    input [285:0]   mem1_rdata,

    output logic [10:0]   mem2_addr,
    output logic [285:0]  mem2_wdata,
    output logic         mem2_wen,
    input [285:0]   mem2_rdata
);
    // parameter
    localparam IDLE = 2'd0;
    localparam WORK = 2'd1;
    localparam START = 2'd2;
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
    logic compare_flag_r, compare_flag_w;
    logic [10:0] compare_count_r, compare_count_w;
    logic [12:0] COMP1_len_r, COMP1_len_w;
    logic [12:0] COMP2_len_r, COMP2_len_w;

    logic [12:0] src_count_r, src_count_w;
    logic [12:0] dst_count_r, dst_count_w;

    logic [8:0] best_dist_r, best_dist_w;
    logic src_num_r, src_num_w;

    // best (src)
    logic [9:0] src_best_x_r, src_best_x_w;
    logic [9:0] src_best_y_r, src_best_y_w;
    logic [9:0] src_best_depth_r, src_best_depth_w;

    // buffer for point data
    logic [9:0] src_delay_x_1, src_delay_x_2;
    logic [9:0] src_delay_y_1, src_delay_y_2;
    logic [9:0] src_delay_depth_1, src_delay_depth_2;

    // connection
    logic [255:0] src_target_desc, dst_target_desc;
    logic [9:0] src_target_x, src_target_y, src_target_depth, src_len;
    logic [9:0] dst_target_x, dst_target_y, dst_target_depth, dst_len;

    logic [9:0] dst_this_x_w, dst_this_y_w, dst_this_depth_w;
    logic [9:0] dst_this_x_r, dst_this_y_r, dst_this_depth_r;
    logic HAMMING_valid;
    logic [8:0] HAMMING_dist;
    logic HAMMING_o_valid;

    assign HAMMING_valid = 1;

    // start end signal
    logic start_flag_r, start_flag_w;
    logic o_frame_start_r, o_frame_start_w;
    logic o_frame_end_r, o_frame_end_w;

    assign o_frame_end = o_frame_end_r;
    assign o_frame_start = o_frame_start_r;

    // src, dst signals connection
    always_comb begin
        case(src_num_r)
            1: begin // mem1: src/mem2: dst
                src_target_x = mem1_rdata[285:276];
                src_target_y = mem1_rdata[275:266];
                src_target_depth = mem1_rdata[265:256];
                src_target_desc = mem1_rdata[255:0];
                src_len = COMP1_len_r;
                dst_target_x = mem2_rdata[285:276];
                dst_target_y = mem2_rdata[275:266];
                dst_target_depth = mem2_rdata[265:256];
                dst_target_desc = mem2_rdata[255:0];
                dst_len = COMP2_len_r;
            end
            default: begin // mem1: dst/mem2: src
                dst_target_x = mem1_rdata[285:276];
                dst_target_y = mem1_rdata[275:266];
                dst_target_depth = mem1_rdata[265:256];
                dst_target_desc = mem1_rdata[255:0];
                dst_len = COMP1_len_r;
                src_target_x = mem2_rdata[285:276];
                src_target_y = mem2_rdata[275:266];
                src_target_depth = mem2_rdata[265:256];
                src_target_desc = mem2_rdata[255:0];
                src_len = COMP2_len_r;
            end
        endcase
    end

    HAMMING dist_unit(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),

        .i_valid(HAMMING_valid),
        .i_src_desc(src_target_desc),
        .i_dst_desc(dst_target_desc),
        .o_dist(HAMMING_dist),
        .o_valid(HAMMING_o_valid)
    );

    // ========== Combinational Block ==========
    // --- STATE MACHINE ---
    always_comb begin
        // register default value
        state_w = state_r;
        o_next = 0;
        o_frame_start_w = 0;
        o_frame_end_w = 0;
        start_flag_w = start_flag_r;
        src_num_w = src_num_r;
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
                if(src_count_r == SORT_len_r-1) begin
                    state_w = IDLE;
                    src_num_w = !src_num_r;
                end
            end
            START: begin
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
    // bubble sort the input to the SORT array
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
                SORT_coor_x_w[src_count_r] = 0;
                SORT_coor_y_w[src_count_r] = 0;
                SORT_depth_w[src_count_r] = 0;
                SORT_score_w[src_count_r] = 0;
                SORT_desc_w[src_count_r] = 0;

                if(src_count_r == SORT_len_r-1) begin
                    SORT_len_w = 0;
                end
            end
        endcase
    end

    // --- memory ---
    always_comb begin
        // default value (read, read)

        mem1_addr = src_num_r ? src_count_r : dst_count_r;
        mem2_addr = src_num_r ? dst_count_r : src_count_r;

        mem1_wdata = 0;
        mem1_wen = 0;
        mem2_wdata = 0;
        mem2_wen = 0;

        COMP1_len_w = COMP1_len_r;
        COMP2_len_w = COMP2_len_r;

        // src_num_r indicates which mem is the src array in last frame
        // will switch to another after i_end 
        case(state_r)
            IDLE: begin
                if(i_end) begin
                // next state: COPY
                    if(src_num_r) begin // write, read
                        COMP1_len_w = SORT_len_r;
                    end
                    else begin // read, write
                        COMP2_len_w = SORT_len_r;
                    end
                end
            end
            COPY: begin // right before i_end
                // write SORT contents into src array (last frame)
                //                          dst array (this frame)

                // last frame dst array will become this frame src array 
                // thus if (src_num_r == 1), we should write to another array
                if(src_num_r) begin // write, read
                    mem1_addr = src_count_r;
                    mem1_wdata = {SORT_coor_x_r[src_count_r], SORT_coor_y_r[src_count_r], SORT_depth_r[src_count_r], SORT_desc_r[src_count_r]};
                    mem1_wen = 1;
                end
                else begin // read, write
                    mem2_addr = src_count_r;
                    mem2_wdata = {SORT_coor_x_r[src_count_r], SORT_coor_y_r[src_count_r], SORT_depth_r[src_count_r], SORT_desc_r[src_count_r]};
                    mem2_wen = 1;
                end
            end
            
        endcase
    end

    // --- MIN_DISTANCE ---
    // src_count and dst count
    always_comb begin   
        // default
        src_count_w = src_count_r;
        dst_count_w = dst_count_r;  
        compare_flag_w = compare_flag_r;
        if(state_r == IDLE && i_end) begin
            src_count_w = 0;
        end

        if(state_r == COPY) begin // RESET, start comparing
            if(src_count_r == SORT_len_r-1) begin
                src_count_w = 0;
                dst_count_w = 0;
                compare_flag_w = 0;
            end
            else begin
                src_count_w = src_count_r + 1;
            end
        end

        else if(dst_count_r < dst_len) begin
            // compare start
            if(src_count_r == 4) begin
                compare_flag_w = 1;
            end
            src_count_w = (src_count_r < src_len-1) ? src_count_r + 1 : 0;
            dst_count_w = (src_count_r < src_len-1) ? dst_count_r : dst_count_r + 1;
        end
    end

    // for each keypoints in dst array, find the closet keypoint in src array
    always_comb begin     
        // default
        compare_count_w = compare_count_r;
        
        src_best_x_w  = src_best_x_r;
        src_best_y_w  = src_best_y_r;
        src_best_depth_w  = src_best_depth_r;

        dst_this_x_w = dst_this_x_r;
        dst_this_y_w = dst_this_y_r;
        dst_this_depth_w = dst_this_depth_r;
        best_dist_w = best_dist_r;

        o_src_coor_x_w = 0;
        o_src_coor_y_w = 0;
        o_src_depth_w = 0;
        o_dst_coor_x_w = 0;
        o_dst_coor_y_w = 0;
        o_dst_depth_w = 0;
        o_valid_w = 0;

        if(state_r == COPY) begin // RESET, start comparing
            compare_count_w = 0;
            best_dist_w = 9'b111111111;
        end

        // compare
        if(compare_flag_r) begin
            compare_count_w = compare_count_r + 1;
            // update best point
            if(HAMMING_o_valid) begin
                if(HAMMING_dist < best_dist_r) begin
                    best_dist_w = HAMMING_dist;
                    src_best_x_w = src_delay_x_2;
                    src_best_y_w = src_delay_y_2;
                    src_best_depth_w = src_delay_depth_2;
                end
            end
            // output
            if(compare_count_r == src_len-1) begin
                if(HAMMING_dist < best_dist_r && HAMMING_dist <= 30) begin
                    o_dst_coor_x_w = dst_this_x_r;
                    o_dst_coor_y_w = dst_this_y_r;
                    o_dst_depth_w = dst_this_depth_r;
                    o_src_coor_x_w = src_delay_x_2;
                    o_src_coor_y_w = src_delay_y_2;
                    o_src_depth_w = src_delay_depth_2;
                    o_valid_w = 1;
                end             
                else if(best_dist_r <= 30) begin
                    o_dst_coor_x_w = dst_this_x_r;
                    o_dst_coor_y_w = dst_this_y_r;
                    o_dst_depth_w = dst_this_depth_r;
                    o_src_coor_x_w = src_best_x_r;
                    o_src_coor_y_w = src_best_y_r;
                    o_src_depth_w = src_best_depth_r;
                    o_valid_w = 1;
                end
            
                best_dist_w = 9'b111111111;
                compare_count_w = 0;
                dst_this_x_w = dst_target_x;
                dst_this_y_w = dst_target_y;
                dst_this_depth_w = dst_target_depth;
            end
        end
        else begin
            compare_count_w = 0;
            dst_this_x_w = dst_target_x;
            dst_this_y_w = dst_target_y;
            dst_this_depth_w = dst_target_depth;
        end
    end

    // ========== Sequential Block ==========
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            state_r <= 0;
            o_valid_r <= 0;
            o_src_coor_x_r <= 0;
            o_src_coor_y_r <= 0;
            o_dst_coor_x_r <= 0;
            o_dst_coor_y_r <= 0;
            o_src_depth_r <= 0;
            o_dst_depth_r <= 0;

            for(int i = 0; i < SIZE; i = i+1) begin
                SORT_coor_x_r[i] <= 0;
                SORT_coor_y_r[i] <= 0;
                SORT_depth_r[i] <= 0;
                SORT_score_r[i] <= 0;
                SORT_desc_r[i] <= 0;
            end
            SORT_comp_x_r <= 0;
            SORT_comp_y_r <= 0;
            SORT_comp_depth_r <= 0;
            SORT_comp_score_r <= 0;
            SORT_comp_desc_r <= 0;

            SORT_count_r <= 0;
            SORT_finish_r <= 0;
            SORT_len_r <= 0;

            COMP1_len_r <= 0;
            COMP2_len_r <= 0;
            compare_flag_r <= 0;
            compare_count_r <= 0;
            src_count_r <= 0;
            dst_count_r <= 0;
            best_dist_r <= 0;
            src_num_r <= 0;

            src_best_x_r <= 0;
            src_best_y_r <= 0;
            src_best_depth_r <= 0;

            dst_this_x_r <= 0;
            dst_this_y_r <= 0;
            dst_this_depth_r <= 0;

            // delay
            src_delay_x_1 <= 0;
            src_delay_y_1 <= 0;
            src_delay_depth_1 <= 0;
            src_delay_x_2 <= 0;
            src_delay_y_2 <= 0;
            src_delay_depth_2 <= 0;
        end
            
        else begin
            state_r <= state_w;
            o_valid_r <= o_valid_w;
            o_src_coor_x_r <= o_src_coor_x_w;
            o_src_coor_y_r <= o_src_coor_y_w;
            o_dst_coor_x_r <= o_dst_coor_x_w;
            o_dst_coor_y_r <= o_dst_coor_y_w;
            o_src_depth_r <= o_src_depth_w;
            o_dst_depth_r <= o_dst_depth_w;

            for(int i = 0; i < SIZE; i = i+1) begin
                SORT_coor_x_r[i] <= SORT_coor_x_w[i];
                SORT_coor_y_r[i] <= SORT_coor_y_w[i];
                SORT_depth_r[i] <= SORT_depth_w[i];
                SORT_score_r[i] <= SORT_score_w[i];
                SORT_desc_r[i] <= SORT_desc_w[i];
            end

            SORT_comp_x_r <= SORT_comp_x_w;
            SORT_comp_y_r <= SORT_comp_y_w;
            SORT_comp_score_r <= SORT_comp_score_w;
            SORT_comp_depth_r <= SORT_comp_depth_w;
            SORT_comp_desc_r <= SORT_comp_desc_w;
            
            SORT_count_r <= SORT_count_w;
            SORT_finish_r <= SORT_finish_w;
            SORT_len_r <= SORT_len_w;

            COMP1_len_r <= COMP1_len_w;
            COMP2_len_r <= COMP2_len_w;
            compare_flag_r <= compare_flag_w;
            compare_count_r <= compare_count_w;
            src_count_r <= src_count_w;
            dst_count_r <= dst_count_w;
            best_dist_r <= best_dist_w;
            src_num_r <= src_num_w;

            src_best_x_r <= src_best_x_w;
            src_best_y_r <= src_best_y_w;
            src_best_depth_r <= src_best_depth_w;

            dst_this_x_r <= dst_this_x_w;
            dst_this_y_r <= dst_this_y_w;
            dst_this_depth_r <= dst_this_depth_w;

            // delay
            src_delay_x_1 <= src_target_x;
            src_delay_y_1 <= src_target_y;
            src_delay_depth_1 <= src_target_depth;
            src_delay_x_2 <= src_delay_x_1;
            src_delay_y_2 <= src_delay_y_1;
            src_delay_depth_2 <= src_delay_depth_1;
        end
    end
    
endmodule