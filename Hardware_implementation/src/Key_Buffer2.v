module Key_Buffer2
#(
    parameter SIZE = 12'd100   
)
(
    input           i_clk,
    input           i_rst_n,

    input           i_next,
    input           i_valid,
    
    input [9:0]     i_coor_x, 
    input [9:0]     i_coor_y, 
    input [7:0]     i_score,
    input [255:0]   i_descriptor,

    output [9:0]     o_coor_x, 
    output [9:0]     o_coor_y,
    output [7:0]     o_score,
    output [255:0]   o_descriptor,
    output           o_flag
);

    integer i;
    reg [9:0] coor_x_w [0:SIZE-1], coor_x_r[0:SIZE-1];
    reg [9:0] coor_y_w [0:SIZE-1], coor_y_r[0:SIZE-1];
    reg [7:0] score_w [0:SIZE-1], score_r [0:SIZE-1];
    reg [255:0] desc_w [0:SIZE-1], desc_r[0:SIZE-1];
    
    reg [9:0] count_r, count_w;
    reg [9:0] count_plus;

    assign o_coor_x = coor_x_r[SIZE-1];
    assign o_coor_y = coor_y_r[SIZE-1];
    assign o_score = score_r[SIZE-1];
    assign o_descriptor = desc_r[SIZE-1];
    assign o_flag = (count_r != 99);


    always@(*) begin
        count_plus = count_r + 1;

        // default
        count_w = count_r;
        for(i = 0; i < SIZE; i = i+1) begin
            coor_x_w[i] = coor_x_r[i];
            coor_y_w[i] = coor_y_r[i];
            score_w[i] = score_r[i];
            desc_w[i] = desc_r[i];
        end

        // hit -> move elements in buffer forward
        if(!i_valid && i_next) begin
            for(i = 1; i < SIZE; i = i+1) begin
                coor_x_w[i] = coor_x_r[i-1];
                coor_y_w[i] = coor_y_r[i-1];
                score_w[i] = score_r[i-1];
                desc_w[i] = desc_r[i-1];
            end
            coor_x_w[0] = 0;
            coor_y_w[0] = 0;
            score_w[0] = 0;
            desc_w[0] = 0;
            count_w = (count_r != (SIZE-1)) ? count_r + 1 : count_r;
        end
        // flag -> put the input in backmost position
        if(i_valid) begin
            if(!i_next) begin
                coor_x_w[count_r] = i_coor_x;
                coor_y_w[count_r] = i_coor_y;
                score_w[count_r] = i_score;
                desc_w[count_r] = i_descriptor;
                count_w = count_r != 0 ? count_r - 1 : count_r;
            end
            else begin
                for(i = 1; i < SIZE; i = i+1) begin
                    coor_x_w[i] = coor_x_r[i-1];
                    coor_y_w[i] = coor_y_r[i-1];
                    desc_w[i] = desc_r[i-1];
                    score_w[i] = score_r[i-1];
                end

                coor_x_w[count_plus] = i_coor_x;
                coor_y_w[count_plus] = i_coor_y;
                desc_w[count_plus] = i_descriptor;
                score_w[count_plus] = i_score;
            end
        end
    end

    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            for(i = 0; i < SIZE; i = i+1) begin
                coor_x_r[i] <= 0;
                coor_y_r[i] <= 0;
                desc_r[i] <= 0;
                score_r[i] <= 0;
            end
            count_r <= SIZE-1;
        end
        else begin
            for(i = 0; i < SIZE; i = i+1) begin
                coor_x_r[i] <= coor_x_w[i];
                coor_y_r[i] <= coor_y_w[i];
                desc_r[i] <= desc_w[i];
                score_r[i] <= score_w[i];
            end
            count_r <= count_w;
        end
    end


endmodule