module Key_Buffer1
#(
    parameter SIZE = 12'd60   
)
(
    input           i_clk,
    input           i_rst_n,
    input           i_flag,
    input           i_hit,
    input [15:0]     i_depth,

    input [11:0]    i_sin,
    input [11:0]    i_cos,
    input [9:0]     i_coor_x, 
    input [9:0]     i_coor_y, 
    input [7:0]     i_score,

    output [11:0]    o_sin,
    output [11:0]    o_cos,
    output [9:0]     o_coor_x, 
    output [9:0]     o_coor_y,
    output [7:0]     o_score,
    output [15:0]     o_depth

    // sram interface -- BRIEF window
    // input [51:0]     BRIEF_keybuf_sram_QA,
    // input [51:0]     BRIEF_keybuf_sram_QB,
    // output          BRIEF_keybuf_sram_WENA,
    // output          BRIEF_keybuf_sram_WENB,
    // output [51:0]    BRIEF_keybuf_sram_DA,
    // output [51:0]    BRIEF_keybuf_sram_DB,
    // output [6:0]    BRIEF_keybuf_sram_AA,
    // output [6:0]    BRIEF_keybuf_sram_AB
);

    integer i;
    logic [9:0] coor_x_w [0:SIZE-1], coor_x_r[0:SIZE-1]; // 10+10+8+12+12 = 52
    logic [9:0] coor_y_w [0:SIZE-1], coor_y_r[0:SIZE-1];
    logic [7:0] score_w [0:SIZE-1], score_r [0:SIZE-1];
    logic [11:0] sin_w [0:SIZE-1], sin_r[0:SIZE-1];
    logic [11:0] cos_w [0:SIZE-1], cos_r[0:SIZE-1];
    logic [15:0] depth_w [0:SIZE-1], depth_r[0:SIZE-1];
    
    logic [9:0] count_r, count_w;
    logic [9:0] count_plus;

    // // sincos_sram interface
    // logic [51:0]   BRIEF_keybuf_sram_QB_r;
    // logic          BRIEF_keybuf_sram_WENA_w, BRIEF_keybuf_sram_WENA_r;
    // logic          BRIEF_keybuf_sram_WENB_w, BRIEF_keybuf_sram_WENB_r;
    // logic [51:0]   BRIEF_keybuf_sram_DA_w, BRIEF_keybuf_sram_DA_r;
    // logic [6:0]    BRIEF_keybuf_sram_AA_w, BRIEF_keybuf_sram_AA_r;
    // logic [6:0]    BRIEF_keybuf_sram_AB_w, BRIEF_keybuf_sram_AB_r;
    // logic update_enable;

    // assign BRIEF_keybuf_sram_WENA = BRIEF_keybuf_sram_WENA_r;
    // assign BRIEF_keybuf_sram_WENB = BRIEF_keybuf_sram_WENB_r;
    // assign BRIEF_keybuf_sram_DA = BRIEF_keybuf_sram_DA_r;
    // assign BRIEF_keybuf_sram_DB = 0;
    // assign BRIEF_keybuf_sram_AA = BRIEF_keybuf_sram_AA_r;
    // assign BRIEF_keybuf_sram_AB = BRIEF_keybuf_sram_AB_r;

    assign o_sin = sin_r[SIZE-1];
    assign o_cos = cos_r[SIZE-1];
    assign o_coor_x = coor_x_r[SIZE-1];
    assign o_coor_y = coor_y_r[SIZE-1];
    assign o_score = score_r[SIZE-1];
    assign o_depth = depth_r[SIZE-1];
    
    // initial begin $monitor("count = %d", count_r); end

    always_comb begin
        count_plus = count_r + 1;

        // default
        count_w = count_r;
        for(int i = 0; i < SIZE; i = i+1) begin
            coor_x_w[i] = coor_x_r[i];
            coor_y_w[i] = coor_y_r[i];
            sin_w[i] = sin_r[i];
            cos_w[i] = cos_r[i];
            score_w[i] = score_r[i];
            depth_w[i] = depth_r[i];
        end

        // hit -> move elements in buffer forward
        if(!i_flag && i_hit) begin
            for(int i = 1; i < SIZE; i = i+1) begin
                coor_x_w[i] = coor_x_r[i-1];
                coor_y_w[i] = coor_y_r[i-1];
                sin_w[i] = sin_r[i-1];
                cos_w[i] = cos_r[i-1];
                score_w[i] = score_r[i-1];
                depth_w[i] = depth_r[i-1];
            end
            coor_x_w[0] = 0;
            coor_y_w[0] = 0;
            sin_w[0] = 0;
            cos_w[0] = 0;
            score_w[0] = 0;
            depth_w[0] = 0;
            count_w = (count_r != (SIZE-1)) ? count_r + 1 : count_r;
        end
        // flag -> put the input in backmost position
        if(i_flag) begin
            if(!i_hit) begin
                coor_x_w[count_r] = i_coor_x;
                coor_y_w[count_r] = i_coor_y;
                sin_w[count_r] = i_sin;
                cos_w[count_r] = i_cos;
                score_w[count_r] = i_score;
                depth_w[count_r] = i_depth;
                count_w = count_r != 0 ? count_r - 1 : count_r;
            end
            else begin
                for(int i = 1; i < SIZE; i = i+1) begin
                    coor_x_w[i] = coor_x_r[i-1];
                    coor_y_w[i] = coor_y_r[i-1];
                    sin_w[i] = sin_r[i-1];
                    cos_w[i] = cos_r[i-1];
                    score_w[i] = score_r[i-1];
                    depth_w[i] = depth_r[i-1];

                end
                // coor_x_w[count_r] = 0;
                // coor_y_w[count_r] = 0;
                // sin_w[count_r] = 0;
                // cos_w[count_r] = 0;
                // score_w[count_r] = 0;

                coor_x_w[count_plus] = i_coor_x;
                coor_y_w[count_plus] = i_coor_y;
                sin_w[count_plus] = i_sin;
                cos_w[count_plus] = i_cos;
                score_w[count_plus] = i_score;
                depth_w[count_plus] = i_depth;
            end
        end
    end

    // // sram
    // always_comb begin
    //     // default
    //     BRIEF_keybuf_sram_WENA_w = 1; // 1 for read
    //     BRIEF_keybuf_sram_WENB_w = 1;
    //     BRIEF_keybuf_sram_DA_w = BRIEF_keybuf_sram_DA_r;
    //     BRIEF_keybuf_sram_AA_w = BRIEF_keybuf_sram_AA_r;
    //     BRIEF_keybuf_sram_AB_w = BRIEF_keybuf_sram_AB_r;
    //     update_enable = 0;

    //     // hit -> move elements in buffer forward
    //     if(!i_flag && i_hit) begin
    //         update_enable = 1;
    //         BRIEF_keybuf_sram_AB_w = BRIEF_keybuf_sram_AB_r == 0 ? 0 : BRIEF_keybuf_sram_AB_r-1;
    //     end
    //     // flag -> put the input in backmost position
    //     if(i_flag) begin
    //         if(!i_hit) begin
    //             BRIEF_keybuf_sram_DA_w = {i_sin, i_cos, i_coor_x, i_coor_y, i_score};
    //             BRIEF_keybuf_sram_AA_w = BRIEF_keybuf_sram_AA_r + 1;
    //             BRIEF_keybuf_sram_WENA_w = 0;
    //         end
    //         else begin
    //             BRIEF_keybuf_sram_DA_w = {i_sin, i_cos, i_coor_x, i_coor_y, i_score};
    //             BRIEF_keybuf_sram_AA_w = BRIEF_keybuf_sram_AA_r;
    //             BRIEF_keybuf_sram_WENA_w = 0;

                
    //         end
    //     end
    // end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            for(int i = 0; i < SIZE; i = i+1) begin
                coor_x_r[i] <= 0;
                coor_y_r[i] <= 0;
                sin_r[i] <= 0;
                cos_r[i] <= 0;
                score_r[i] <= 0;
                depth_r[i] <= 0;
            end
            count_r <= SIZE-1;
        end
        else begin
            for(int i = 0; i < SIZE; i = i+1) begin
                coor_x_r[i] <= coor_x_w[i];
                coor_y_r[i] <= coor_y_w[i];
                sin_r[i] <= sin_w[i];
                cos_r[i] <= cos_w[i];
                score_r[i] <= score_w[i];
                depth_r[i] <= depth_w[i];

            end
            count_r <= count_w;
        end
    end

    // always_ff @(posedge i_clk or negedge i_rst_n) begin
    //     if(!i_rst_n) begin
    //         for(int i = 0; i < SIZE; i = i+1) begin
    //             coor_x_r[i] <= 0;
    //             coor_y_r[i] <= 0;
    //             sin_r[i] <= 0;
    //             cos_r[i] <= 0;
    //             score_r[i] <= 0;
    //         end
    //         // BRIEF_keybuf_sram_QB_r <= 0;
    //         // BRIEF_keybuf_sram_WENA_r <= 1; // read
    //         // BRIEF_keybuf_sram_WENB_r <= 1; // read
    //         // BRIEF_keybuf_sram_DA_r <= 0;
    //         // BRIEF_keybuf_sram_AA_r <= 0;
    //         // BRIEF_keybuf_sram_AB_r <= 0;
    //         // count_r <= SIZE-1;
    //     end
    //     else begin
    //         for(int i = 0; i < SIZE; i = i+1) begin
    //             coor_x_r[i] <= coor_x_w[i];
    //             coor_y_r[i] <= coor_y_w[i];
    //             sin_r[i] <= sin_w[i];
    //             cos_r[i] <= cos_w[i];
    //             score_r[i] <= score_w[i];
    //         end
    //         // BRIEF_keybuf_sram_QB_r <= BRIEF_keybuf_sram_QB;
    //         // BRIEF_keybuf_sram_WENA_r <= BRIEF_keybuf_sram_WENA_w; // read
    //         // BRIEF_keybuf_sram_WENB_r <= BRIEF_keybuf_sram_WENB_w; // read
    //         // BRIEF_keybuf_sram_DA_r <= BRIEF_keybuf_sram_DA_w;
    //         // BRIEF_keybuf_sram_AA_r <= BRIEF_keybuf_sram_AA_w;
    //         // BRIEF_keybuf_sram_AB_r <= BRIEF_keybuf_sram_AB_w;
    //         // count_r <= count_w;
    //     end
    // end


endmodule