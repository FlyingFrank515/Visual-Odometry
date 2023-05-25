// contains score unit and test unit
module FAST_9
#(
    parameter THRESHOLD = 8'd20
)
(
    input           i_clk,
    input           i_rst_n,
    input [127:0]   i_circle, // flattened
    input [23:0]     i_center, // with depth information
    input           i_valid,

    output          o_keypoints_flag,
    output [7:0]    o_score,
    output [15:0]    o_depth
    // output          o_valid,

);
// ========== function declaration ==========
function [7:0] MIN;
    input [7:0]   num1;
    input [7:0]   num2;
    input [7:0]   num3;
    input [7:0]   num4;
    logic [7:0] min1, min2;
    begin
        min1 = (num1 < num2) ? num1 : num2;
        min2 = (num3 < num4) ? num3 : num4;
        MIN = (min1 < min2) ? min1 : min2;
    end
endfunction

function [7:0] MAX;
    input [7:0]   num1;
    input [7:0]   num2;
    input [7:0]   num3;
    input [7:0]   num4;
    logic [7:0] max1, max2;
    begin
        max1 = (num1 > num2) ? num1 : num2;
        max2 = (num3 > num4) ? num3 : num4;
        MAX = (max1 > max2) ? max1 : max2;
    end
endfunction

// ========== reg/wire declaration ==========
integer i;
logic [7:0]  pixel [0:15];
logic [7:0] center_pixel;
logic [15:0] center_depth;
logic [7:0]  diff [0:15];

logic [15:0] sign;
logic [15:0] brighter_w, brighter_r;
logic [15:0] darker_w, darker_r;
logic [31:0] brighter_ext, darker_ext;

logic flag_r, flag_w;

logic [15:0] continuous_b;
logic [15:0] continuous_d;


logic [7:0]  diff_stage0 [0:15], diff_stage0_ext [0:31];
logic [7:0]  diff_stage1 [0:15], diff_stage1_ext [0:31];
logic [7:0]  diff_stage2 [0:15], diff_stage2_ext [0:31];


logic [7:0]  min_stage0_w [0:15], min_stage0_r[0:15];
logic [7:0]  min_stage1_w [0:15], min_stage1_r[0:15];
logic [7:0]  min_stage2_w [0:15], min_stage2_r[0:15];

logic [7:0] max_stage0_w [0:3], max_stage0_r [0:3];
logic flag_delay [0:3];
logic [15:0] depth_delay [0:8];
logic [15:0] depth_r;

logic [7:0] score_w, score_r;


// ========== Connection ==========
assign o_score = score_r;
assign o_keypoints_flag = flag_r;
assign o_depth = depth_r;
assign center_pixel = i_center[23:16];
assign center_depth = i_center[15:0];

always_comb begin
    pixel[0] = i_circle[7:0];
    pixel[1] = i_circle[15:8];
    pixel[2] = i_circle[23:16];
    pixel[3] = i_circle[31:24];
    pixel[4] = i_circle[39:32];
    pixel[5] = i_circle[47:40];
    pixel[6] = i_circle[55:48];
    pixel[7] = i_circle[63:56];
    pixel[8] = i_circle[71:64];
    pixel[9] = i_circle[79:72];
    pixel[10] = i_circle[87:80];
    pixel[11] = i_circle[95:88];
    pixel[12] = i_circle[103:96];
    pixel[13] = i_circle[111:104];
    pixel[14] = i_circle[119:112];
    pixel[15] = i_circle[127:120];
end

// 16 subtractors
always_comb begin
    for(int i = 0; i < 16; i = i+1) begin
        sign[i] = center_pixel > pixel[i];
        diff[i] = center_pixel > pixel[i] ? (center_pixel - pixel[i]) : (pixel[i] - center_pixel);    
    end
end


// comparators
always_comb begin
    for(int i = 0; i < 16; i = i+1) begin
        darker_w[i] = sign[i] && (diff[i] > THRESHOLD);
        brighter_w[i] = !sign[i] && (diff[i] > THRESHOLD);
    end
end

// brighter, darker, stage extension
always_comb begin
    for(int i = 0; i < 16; i = i+1) begin
        darker_ext[i] = darker_r[i];
        darker_ext[i+16] = darker_r[i];
        brighter_ext[i] = brighter_r[i];
        brighter_ext[i+16] = brighter_r[i];

        diff_stage0_ext[i] = diff_stage0[i];
        diff_stage0_ext[i+16] = diff_stage0[i];
        diff_stage1_ext[i] = diff_stage1[i];
        diff_stage1_ext[i+16] = diff_stage1[i];
        diff_stage2_ext[i] = diff_stage2[i];
        diff_stage2_ext[i+16] = diff_stage2[i];
    end
end

// AND/OR gates
always_comb begin
    for(int i = 0; i < 16; i = i+1) begin
        continuous_b[i] = brighter_ext[i] && brighter_ext[i+1] && brighter_ext[i+2] && brighter_ext[i+3] && brighter_ext[i+4] && brighter_ext[i+5] && brighter_ext[i+6] && brighter_ext[i+7] && brighter_ext[i+8];
        continuous_d[i] = darker_ext[i] && darker_ext[i+1] && darker_ext[i+2] && darker_ext[i+3] && darker_ext[i+4] && darker_ext[i+5] && darker_ext[i+6] && darker_ext[i+7] && darker_ext[i+8];
    end
    flag_w = (continuous_b != 0) || (continuous_d != 0);
end

// moving MINs
always_comb begin
    for(int i = 0; i < 16; i = i+1) begin
        min_stage0_w[i] = MIN(diff_stage0_ext[i], diff_stage0_ext[i+1], diff_stage0_ext[i+2], diff_stage0_ext[i+3]);
        min_stage1_w[i] = MIN(min_stage0_r[i], diff_stage1_ext[i+4], diff_stage1_ext[i+5], diff_stage1_ext[i+6]);
        min_stage2_w[i] = MIN(min_stage1_r[i], diff_stage2_ext[i+7], diff_stage2_ext[i+8], diff_stage2_ext[i+8]);
    end
end

// MAX tree
always_comb begin
    for(int i = 0; i < 4; i = i+1) begin
        max_stage0_w[i] = MAX(min_stage2_r[i*4], min_stage2_r[i*4+1], min_stage2_r[i*4+2], min_stage2_r[i*4+3]);
    end
    score_w = MAX(max_stage0_r[0], max_stage0_r[1], max_stage0_r[2], max_stage0_r[3]);
end



// ========== Combinational Block ==========

// ========== Sequential Block ==========
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        darker_r <= 0;
        brighter_r <= 0;
        flag_r <= 0;
        depth_r <= 0;
        score_r <= 0;
        for(int i = 0; i < 16; i = i+1) begin
            diff_stage0[i] <= 0;
            diff_stage1[i] <= 0; 
            diff_stage2[i] <= 0; 
            min_stage0_r[i] <= 0;
            min_stage1_r[i] <= 0;
            min_stage2_r[i] <= 0;
        end
        for(int i = 0; i < 4; i = i+1) begin
            max_stage0_r[i] <= 0; 
        end
        for(int i = 0; i < 4; i = i+1) begin
            flag_delay[i] <= 0; 
        end
        for(int i = 0; i < 9; i = i+1) begin
            depth_delay[i] <= 0; 
        end
    end
    else if(i_valid)begin
        darker_r <= darker_w;
        brighter_r <= brighter_w;
        flag_r <= flag_delay[3];
        depth_r <= depth_delay[4];
        score_r <= score_w;
        for(int i = 0; i < 16; i = i+1) begin
            diff_stage0[i] <= diff[i]; 
            diff_stage1[i] <= diff_stage0[i]; 
            diff_stage2[i] <= diff_stage1[i]; 
            min_stage0_r[i] <= min_stage0_w[i];
            min_stage1_r[i] <= min_stage1_w[i];
            min_stage2_r[i] <= min_stage2_w[i];
        end
        for(int i = 0; i < 4; i = i+1) begin
            max_stage0_r[i] <= max_stage0_w[i]; 
        end
        flag_delay[0] <= flag_w;
        depth_delay[0] <= center_depth;
        for(int i = 1; i < 4; i = i+1) begin
            flag_delay[i] <= flag_delay[i-1]; 
        end
        for(int i = 1; i < 9; i = i+1) begin
            depth_delay[i] <= depth_delay[i-1]; 
        end
    end
    
end

endmodule