module NMS
#(
    parameter WIDTH = 12'd640  
)
(
    input           i_clk,
    input           i_rst_n,
    input [7:0]     i_score,
    input           i_flag,
    input [15:0]     i_depth,
    input           i_valid,
    output [7:0]    o_score,
    output [15:0]    o_depth,
    output          o_flag,

    // sram interface
    input [25:0]     sram_QA,
    input [25:0]     sram_QB,
    output          sram_WENA,
    output          sram_WENB,
    output [25:0]    sram_DA,
    output [25:0]    sram_DB,
    output [9:0]    sram_AA,
    output [9:0]    sram_AB
);

// ========== function declaration ==========
function M0; // determine whether we should reserve pixel_1
    input [7:0]   score_1;
    input [7:0]   score_2;
    input         flag_1;
    input         flag_2;
    begin
        M0 = flag_1 ? (!flag_2 ? 1'b1 : score_1 > score_2) : 1'b0;
    end
endfunction

function M2; // determine whether we should reserve pixel_1
    input [7:0]   score_1;
    input [7:0]   score_2;
    input [7:0]   score_3;
    input [7:0]   score_4;
    input         flag_1;
    input         flag_2;
    input         flag_3;
    input         flag_4;
    logic           com2;
    logic           com3;
    logic           com4;
    begin
        com2 = flag_1 ? (!flag_2 ? 1'b1 : score_1 > score_2) : 1'b0;
        com3 = flag_1 ? (!flag_3 ? 1'b1 : score_1 > score_3) : 1'b0;
        com4 = flag_1 ? (!flag_4 ? 1'b1 : score_1 > score_4) : 1'b0;
        M2 = com2 && com3 && com4;
    end
endfunction
// ========== reg/wire declaration ==========
integer ia, ib, i;
logic [7:0] candidate_score_start;
logic [15:0] candidate_depth_start;
logic       candidate_flag_start;
logic       candidate_reserved_start;

logic [7:0] B_score_r [0:4],      B_score_w [0:4];
logic       B_flag_r [0:4],       B_flag_w [0:4];
logic       B_reserved_r [0:4],   B_reserved_w [0:4];
logic [15:0] B_depth_r [0:4],      B_depth_w [0:4];

logic [7:0] A_score_r [0:2],      A_score_w [0:2];
logic       A_flag_r [0:2],       A_flag_w [0:2];
logic       A_reserved_r [0:2],   A_reserved_w [0:2];
logic [15:0] A_depth_r [0:2],      A_depth_w [0:2];

logic [7:0] o_score_r, o_score_w;
logic       o_flag_r, o_flag_w;
logic [15:0] o_depth_r, o_depth_w;
logic       o_reserved;

// sram interface
logic [25:0]    sram_QB_r;
logic          sram_WENA_w, sram_WENA_r;
logic          sram_WENB_w, sram_WENB_r;
logic [25:0]    sram_DA_w, sram_DA_r;
logic [9:0]    sram_AA_w, sram_AA_r;
logic [9:0]    sram_AB_w, sram_AB_r;

logic [7:0] candidate_score_out;
logic [15:0] candidate_depth_out;
logic       candidate_flag_out;
logic       candidate_reserved_out;

logic [25:0] sram_delay [0:10];

// ========== Connection ==========
assign o_score = o_score_r;
assign o_flag = o_flag_r;
assign o_depth = o_depth_r;

assign sram_WENA = sram_WENA_r;
assign sram_WENB = sram_WENB_r;
assign sram_DA = sram_DA_r;
assign sram_DB = 0;
assign sram_AA = sram_AA_r;
assign sram_AB = sram_AB_r;
// ========== Combinational Block ==========
always_comb begin

    B_score_w[4] = i_score;
    B_flag_w[4] = i_flag;
    B_reserved_w[4] = 1'b0;
    B_depth_w[4] = i_depth;

    B_score_w[3] = B_score_r[4];
    B_flag_w[3] = B_flag_r[4];
    B_reserved_w[3] = M0(B_score_r[4], B_score_r[3], B_flag_r[4], B_flag_r[3]);
    B_depth_w[3] = B_depth_r[4];

    B_score_w[2] = B_score_r[3];
    B_flag_w[2] = B_flag_r[3];
    B_reserved_w[2] = M0(B_score_r[3], B_score_r[4], B_flag_r[3], B_flag_r[4]) && B_reserved_r[3];
    B_depth_w[2] = B_depth_r[3];

    B_score_w[1] = B_score_r[2];
    B_flag_w[1] = B_flag_r[2];
    B_reserved_w[1] = B_reserved_r[2];
    B_depth_w[1] = B_depth_r[2];

    B_score_w[0] = B_score_r[1];
    B_flag_w[0] = B_flag_r[1];
    B_reserved_w[0] = B_reserved_r[1];
    B_depth_w[0] = B_depth_r[1];

    A_score_w[2] = candidate_score_out;
    A_flag_w[2] = candidate_flag_out;
    A_reserved_w[2] = candidate_reserved_out;
    A_depth_w[2] = candidate_depth_out;

    A_score_w[1] = A_score_r[2];
    A_flag_w[1] = A_flag_r[2];
    A_reserved_w[1] = A_reserved_r[2];
    A_depth_w[1] = A_depth_r[2];

    A_score_w[0] = A_score_r[1];
    A_flag_w[0] = A_flag_r[1];
    A_reserved_w[0] = A_reserved_r[1];
    A_depth_w[0] = A_depth_r[1];

    candidate_score_start = B_score_r[1];
    candidate_flag_start = B_flag_r[1];
    candidate_reserved_start = M2(B_score_r[1], A_score_r[0], A_score_r[1], A_score_r[2], B_flag_r[1], A_flag_r[0], A_flag_r[1], A_flag_r[2]) && B_reserved_r[1];
    candidate_depth_start = B_depth_r[1];

    o_reserved = M2(A_score_r[1], B_score_r[0], B_score_r[1], B_score_r[2], A_flag_r[1], B_flag_r[0], B_flag_r[1], B_flag_r[2]) && A_reserved_r[1];
    o_flag_w = o_reserved && A_flag_r[1];
    o_score_w = o_reserved ? (A_score_r[1]) : 0;
    o_depth_w = o_reserved ? A_depth_r[1] : 0;

end

always_comb begin
    sram_WENA_w = 0;
    sram_WENB_w = 1;
    sram_DA_w = {candidate_depth_start, candidate_score_start, candidate_flag_start, candidate_reserved_start};
    sram_AA_w = (sram_AA_r == 639) ? 0 : sram_AA_r + 1;
    sram_AB_w = (sram_AB_r == 639) ? 0 : sram_AB_r + 1;
    
    candidate_depth_out = sram_delay[10][25:10];
    candidate_score_out = sram_delay[10][9:2];
    candidate_flag_out = sram_delay[10][1];
    candidate_reserved_out = sram_delay[10][0];
end

// ========== Sequential Block ==========
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        for(int ia = 0; ia < 3; ia = ia+1) begin
            A_score_r[ia] <= 0;
            A_flag_r[ia] <= 0;
            A_reserved_r[ia] <= 0;
            A_depth_r[ia] <= 0;
        end
        for(int ib = 0; ib < 5; ib = ib+1) begin
            B_score_r[ib] <= 0;
            B_flag_r[ib] <= 0;
            B_reserved_r[ib] <= 0;
            B_depth_r[ib] <= 0;
        end
        o_score_r <= 0;
        o_flag_r <= 0;
        o_depth_r <= o_depth_w;
    end
    else if(i_valid)begin
        for(int ia = 0; ia < 3; ia = ia+1) begin
            A_score_r[ia] <= A_score_w[ia];
            A_flag_r[ia] <= A_flag_w[ia];
            A_reserved_r[ia] <= A_reserved_w[ia];
            A_depth_r[ia] <= A_depth_w[ia];
        end
        for(int ib = 0; ib < 5; ib = ib+1) begin
            B_score_r[ib] <= B_score_w[ib];
            B_flag_r[ib] <= B_flag_w[ib];
            B_reserved_r[ib] <= B_reserved_w[ib];
            B_depth_r[ib] <= B_depth_w[ib];
        end
        o_score_r <= o_score_w;
        o_flag_r <= o_flag_w;
        o_depth_r <= o_depth_w;
    end

end

// sram
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        sram_QB_r <= 0;
        sram_WENA_r <= 0;
        sram_WENB_r <= 1;
        sram_DA_r <= 0;
        sram_AA_r <= 624;
        sram_AB_r <= 0;

        sram_delay[0] <= 0;
        for(int i = 1; i < 11 ; i = i+1) begin
            sram_delay[i] <= 0;
        end
    end
    else begin
        sram_QB_r <= sram_QB;
        sram_WENA_r <= sram_WENA_w;
        sram_WENB_r <= sram_WENB_w; 
        sram_DA_r <= sram_DA_w;
        sram_AA_r <= sram_AA_w;
        sram_AB_r <= sram_AB_w;

        sram_delay[0] <= sram_QB_r;
        for(int i = 1; i < 11 ; i = i+1) begin
            sram_delay[i] <= sram_delay[i-1];
        end
    end
end
endmodule