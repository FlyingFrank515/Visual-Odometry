module NMS
#(
    parameter WIDTH = 12'd640;    
)
(
    input           i_clk,
    input           i_rst_n,
    input [7:0]     i_score,
    input           i_flag,
    output [7:0]    o_score,
    output          o_flag,
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
    reg           com2;
    reg           com3;
    reg           com4;
    begin
        com2 = flag_1 ? (!flag_2 ? 1'b1 : score_1 > score_2) : 1'b0;
        com3 = flag_1 ? (!flag_3 ? 1'b1 : score_1 > score_3) : 1'b0;
        com4 = flag_1 ? (!flag_4 ? 1'b1 : score_1 > score_4) : 1'b0;
        M2 = com2 && com3 && com4;
    end
endfunction
// ========== reg/wire declaration ==========
integer ia, ib, i;
reg [7:0] candidate_score_buffer [0:WIDTH-1];
reg       candidate_flag_buffer [0:WIDTH-1];
reg       candidate_reserved_buffer [0:WIDTH-1];
reg [7:0] candidate_score_start;
reg       candidate_flag_start;
reg       candidate_reserved_start;

reg [7:0] B_score_r [0:4],      B_score_w [0:4];
reg       B_flag_r [0:4],       B_flag_w [0:4];
reg       B_reserved_r [0:4],   B_reserved_w [0:4];
reg [7:0] A_score_r [0:2],      A_score_w [0:2];
reg       A_flag_r [0:2],       A_flag_w [0:2];
reg       A_reserved_r [0:2],   A_reserved_w [0:2];
reg [7:0] o_score_r, o_score_w;
reg [7:0] o_flag_r, o_flag_w;
reg       o_reserved;

// ========== Connection ==========
assign o_score = o_score_r;
assign o_flag = o_flag_r;
// ========== Combinational Block ==========
always@(*) begin
    B_score_w[4] = i_score;
    B_flag_w[4] = i_flag;
    B_reserved_w[4] = 1'b0;

    B_score_w[3] = B_score_r[4];
    B_flag_w[3] = B_flag_r[4];
    B_reserved_w[3] = M0(B_score_r[4], B_score_r[3], B_flag_r[4], B_flag_r[3]);

    B_score_w[2] = B_score_r[3];
    B_flag_w[2] = B_flag_r[3];
    B_reserved_w[2] = M0(B_score_r[3], B_score_r[4], B_flag_r[3], B_flag_r[4]);

    B_score_w[1] = B_score_r[2];
    B_flag_w[1] = B_flag_r[2];
    B_reserved_w[1] = B_reserved_r[2];

    B_score_w[0] = B_score_r[1];
    B_flag_w[0] = B_flag_r[1];
    B_reserved_w[0] = B_reserved_r[1];

    A_score_w[2] = candidate_score_buffer[WIDTH-1];
    A_flag_w[2] = candidate_flag_buffer[WIDTH-1];
    A_reserved_w[2] = candidate_reserved_buffer[WIDTH-1];

    A_score_w[1] = A_score_r[2];
    A_flag_w[1] = A_flag_r[2];
    A_reserved_w[1] = A_reserved_r[2];

    A_score_w[0] = A_score_r[1];
    A_flag_w[0] = A_flag_r[1];
    A_reserved_w[0] = A_reserved_r[1];

    candidate_score_start = B_score_r[1];
    candidate_flag_start = B_flag_r[1];
    candidate_reserved_start = M2(B_score_r[1], A_score_r[0], A_score_r[1], A_score_r[2], B_flag_r[1], A_flag_r[0], A_flag_r[1], A_flag_r[2]);

    o_reserved = M2(A_score_r[1], B_score_r[0], B_score_r[1], B_score_r[2], A_flag_r[1], B_flag_r[0], B_flag_r[1], B_flag_r[2]);
    o_flag_w = o_reserved && A_flag_r[1];
    o_score_w = o_reserved ? (A_score_r[1]) : 0;

    
end
// ========== Sequential Block ==========
always@(posedge i_clk) begin
    if(!i_rst_n) begin
        for(ia = 0; ia < 3; ia = ia+1) begin
            A_score_r[ia] <= 0;
            A_flag_r[ia] <= 0;
            A_reserved_r[ia] <= 0;
        end
        for(ib = 0; ib < 5; ib = ib+1) begin
            B_score_r[ib] <= 0;
            B_flag_r[ib] <= 0;
            B_reserved_r[ib] <= 0;
        end
        for(i = 0; i < WIDTH; i = i+1) begin
            candidate_score_buffer[i] <= 0;
            candidate_flag_buffer[i] <= 0;
            candidate_reserved_buffer[i] <= 0;
        end
        o_score_r <= 0;
        o_flag_r <= 0;
    end
    else begin
        for(ia = 0; ia < 3; ia = ia+1) begin
            A_score_r[ia] <= A_score_w[ia];
            A_flag_r[ia] <= A_flag_w[ia];
            A_reserved_r[ia] <= A_reserved_w[ia];
        end
        for(ib = 0; ib < 5; ib = ib+1) begin
            B_score_r[ib] <= B_score_w[ib];
            B_flag_r[ib] <= B_flag_w[ib];
            B_reserved_r[ib] <= B_reserved_w[ib];
        end
        for(i = 1; i < WIDTH; i = i+1) begin
            candidate_score_buffer[i] <= candidate_flag_buffer[i-1];
            candidate_flag_buffer[i] <= candidate_flag_buffer[i-1];
            candidate_reserved_buffer[i] <= candidate_reserved_buffer[i-1];
        end
        candidate_score_buffer[0] <= candidate_score_start;
        candidate_flag_buffer[0] <= candidate_flag_start;
        candidate_reserved_buffer[0] <= candidate_reserved_start;
        o_score_r <= 0;
        o_flag_r <= 0;
    end

end
endmodule