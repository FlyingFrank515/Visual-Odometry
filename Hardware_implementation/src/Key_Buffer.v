module Key_Buffer
#(
    parameter SIZE = 12'd100   
)
(
    input           i_clk,
    input           i_rst_n,
    input           i_flag,
    input           i_hit,

    input [11:0]    i_sin,
    input [11:0]    i_cos,
    input [9:0]     i_coor_x, 
    input [9:0]     i_coor_y, 

    output [11:0]    o_sin,
    output [11:0]    o_cos,
    output [9:0]     o_coor_x, 
    output [9:0]     o_coor_y
);
    integer i;
    reg [9:0] coor_x_w [0:SIZE-1], coor_x_r[0:SIZE-1];
    reg [9:0] coor_y_w [0:SIZE-1], coor_y_r[0:SIZE-1];
    reg [11:0] sin_w [0:SIZE-1], sin_r[0:SIZE-1];
    reg [11:0] cos_w [0:SIZE-1], cos_r[0:SIZE-1];
    
    reg [9:0] count_r, count_w;

    assign o_sin = sin_r[SIZE-1];
    assign o_cos = cos_r[SIZE-1];
    assign o_coor_x = coor_x_r[SIZE-1];
    assign o_coor_y = coor_y_r[SIZE-1];

    always@(*) begin
        // default
        count_w = count_r;
        for(i = 0; i < SIZE; i = i+1) begin
            coor_x_w[i] = coor_x_r[i];
            coor_y_w[i] = coor_y_r[i];
            sin_w[i] = sin_r[i];
            cos_w[i] = cos_r[i];
        end

        // hit -> move elements in buffer forward
        if(!i_flag && i_hit) begin
            for(i = 1; i < SIZE; i = i+1) begin
                coor_x_w[i] = coor_x_r[i-1];
                coor_y_w[i] = coor_y_r[i-1];
                sin_w[i] = sin_r[i-1];
                cos_w[i] = cos_r[i-1];
            end
            coor_x_w[0] = 0;
            coor_y_w[0] = 0;
            sin_w[0] = 0;
            cos_w[0] = 0;
        end
        // flag -> put the input in backmost position
        if(i_flag) begin
            if(!i_hit) begin
                coor_x_w[count_r] = i_coor_x;
                coor_y_w[count_r] = i_coor_y;
                sin_w[count_r] = i_sin;
                cos_w[count_r] = i_cos;
                count_w = count_r != 0 ? count_r - 1 : count_r;
            end
            else begin
                coor_x_w[count_r-1] = i_coor_x;
                coor_y_w[count_r-1] = i_coor_y;
                sin_w[count_r-1] = i_sin;
                cos_w[count_r-1] = i_cos;
            end
        end
    end

    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            for(i = 0; i < SIZE; i = i+1) begin
                coor_x_r[i] <= 0;
                coor_y_r[i] <= 0;
                sin_r[i] <= 0;
                cos_r[i] <= 0;
            end
            count_r <= SIZE-1;
        end
        else begin
            for(i = 0; i < SIZE; i = i+1) begin
                coor_x_r[i] <= coor_x_w[i];
                coor_y_r[i] <= coor_y_w[i];
                sin_r[i] <= sin_w[i];
                cos_r[i] <= cos_w[i];
            end
            count_r <= count_w;
        end
    end


endmodule