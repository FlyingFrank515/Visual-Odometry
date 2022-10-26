module HAMMING
(
    input           i_clk,
    input           i_rst_n,

    input           i_valid,
    input [255:0]   i_src_desc,
    input [255:0]   i_dst_desc,

    output [8:0]    o_dist,
    output          o_valid
);
    integer j;

    // stage 1
    logic [255:0] comp_desc;
    logic [1:0]   sum_layer1 [0:127];
    logic [2:0]   sum_layer2 [0:63];
    logic [3:0]   sum_layer3 [0:31];
    logic [4:0]   sum_layer4 [0:15];
    logic         stg1_valid_w, stg1_valid_r;
    logic [5:0]   stg1_sum_w [0:7], stg1_sum_r[0:7];

    logic [6:0]   sum_layer5 [0:3];
    logic [7:0]   sum_layer6 [0:1];
    logic [8:0]   stg2_sum_w, stg2_sum_r;
    logic         stg2_valid_w, stg2_valid_r;

    // connection
    assign o_dist = stg2_sum_r;
    assign o_valid = stg2_valid_r;

    always_comb begin
        // input 
        comp_desc = i_src_desc ^ i_dst_desc;

        // stage 1
        stg1_valid_w = i_valid;
        for(int j = 0; j < 128; j = j+1) begin
            sum_layer1[j] = comp_desc[j] + comp_desc[j+128];
        end
        for(int j = 0; j < 64; j = j+1) begin
            sum_layer2[j] = sum_layer1[j] + sum_layer1[j+64];
        end
        for(int j = 0; j < 32; j = j+1) begin
            sum_layer3[j] = sum_layer2[j] + sum_layer2[j+32];
        end
        for(int j = 0; j < 16; j = j+1) begin
            sum_layer4[j] = sum_layer3[j] + sum_layer3[j+16];
        end
        for(int j = 0; j < 8; j = j+1) begin
            stg1_sum_w[j] = sum_layer4[j] + sum_layer4[j+8];
        end

        // stage 2
        stg2_valid_w = stg1_valid_r;
        for(int j = 0; j < 4; j = j+1) begin
            sum_layer5[j] = stg1_sum_r[j] + stg1_sum_r[j+4];
        end
        for(int j = 0; j < 2; j = j+1) begin
            sum_layer6[j] = sum_layer5[j] + sum_layer5[j+2];
        end
        stg2_sum_w = sum_layer6[0] + sum_layer6[1];

    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            // stg1
            stg1_valid_r <= 0;
            for(int j = 0; j < 8; j = j+1) begin
                stg1_sum_r[j] <= 0;
            end
            // stg2
            stg2_valid_r <= 0;
            stg2_sum_r <= 0;
        end
        else begin
            // stg1
            stg1_valid_r <= stg1_valid_w;
            for(int j = 0; j < 8; j = j+1) begin
                stg1_sum_r[j] <= stg1_sum_w[j];
            end
            // stg2
            stg2_valid_r <= stg2_valid_w;
            stg2_sum_r <= stg2_sum_w;
        end
    end

endmodule