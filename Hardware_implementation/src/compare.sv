`timescale 1ns/10ps
`define CYCLE    10           	         // Modify your clock period here
`define TIME_OUT 6400       
// `define TIME_OUT 640*100*10     

module CHIP_tb;

    function bit compare(
        input logic [9:0]  golden_src_coor_x,
        input logic [9:0]  golden_src_coor_y,
        input logic [9:0]  golden_src_depth,
        input logic [9:0]  golden_dst_coor_x,
        input logic [9:0]  golden_dst_coor_y,
        input logic [9:0]  golden_dst_depth,
        input logic [9:0]  o_src_coor_x,
        input logic [9:0]  o_src_coor_y,
        input logic [9:0]  o_src_depth,
        input logic [9:0]  o_dst_coor_x,
        input logic [9:0]  o_dst_coor_y,
        input logic [9:0]  o_dst_depth);

        // $display("%h, %h, %b", golden_src_coor_x, o_src_coor_x, golden_src_coor_x == o_src_coor_x);
        // $display("%h, %h, %b", golden_src_coor_y, o_src_coor_y, golden_src_coor_y == o_src_coor_y);
        // $display("%h, %h, %b", golden_src_depth, o_src_depth, golden_src_depth == o_src_depth);
        // $display("%h, %h, %b", golden_dst_coor_x, o_dst_coor_x, golden_dst_coor_x == o_dst_coor_x);
        // $display("%h, %h, %b", golden_dst_coor_y, o_dst_coor_y, golden_dst_coor_y == o_dst_coor_y);
        // $display("%h, %h, %b", golden_dst_depth, o_dst_depth, golden_dst_depth == o_dst_depth);
        
        return (golden_src_coor_x == o_src_coor_x) &&
                (golden_src_coor_y == o_src_coor_y) &&
                (golden_src_depth == o_src_depth) &&
                (golden_dst_coor_x == o_dst_coor_x) &&
                (golden_dst_coor_y == o_dst_coor_y) &&
                (golden_dst_depth == o_dst_depth);
    endfunction

    
    integer i, j, f1, f2, err, index;
    // genvar s;
    logic clk, rst_n;

    logic [71:0] golden_raw [0:199];
    logic [9:0]  golden_src_coor_x[0:199];
    logic [9:0]  golden_src_coor_y[0:199];
    logic [9:0]  golden_src_depth[0:199];
    logic [9:0]  golden_dst_coor_x[0:199];
    logic [9:0]  golden_dst_coor_y[0:199];
    logic [9:0]  golden_dst_depth[0:199];

    logic [71:0] mine_raw [0:199];
    logic [9:0]  mine_src_coor_x[0:199];
    logic [9:0]  mine_src_coor_y[0:199];
    logic [9:0]  mine_src_depth[0:199];
    logic [9:0]  mine_dst_coor_x[0:199];
    logic [9:0]  mine_dst_coor_y[0:199];
    logic [9:0]  mine_dst_depth[0:199];

    logic          o_valid;
    logic          o_ready;
    logic [9:0]    o_src_coor_x;
    logic [9:0]    o_src_coor_y;
    logic [9:0]    o_src_depth;
    logic [9:0]    o_dst_coor_x;
    logic [9:0]    o_dst_coor_y;
    logic [9:0]    o_dst_depth;
    
    logic [9:0] golden_pos, start_pos, end_pos, mine_pos, mine_end_pos;
    logic       check_again, same, reach_end, checking;
    

    logic start;
    logic [7:0] pixel;
    logic [9:0] depth;
    logic valid;

    // `ifdef SDF
    //     initial $sdf_annotate(`SDFFILE, chip0);
    // `endif
    

    always_comb begin // golden connection
        for(int i = 0; i < 199; i = i+1) begin
            golden_src_coor_x[i] = golden_raw[i+1][69:60];
            golden_src_coor_y[i] = golden_raw[i+1][57:48];
            golden_src_depth[i] = golden_raw[i+1][45:36];
            golden_dst_coor_x[i] = golden_raw[i+1][33:24];
            golden_dst_coor_y[i] = golden_raw[i+1][21:12];
            golden_dst_depth[i] = golden_raw[i+1][9:0];
        end
        for(int i = 0; i < 199; i = i+1) begin
            mine_src_coor_x[i] = mine_raw[i+1][69:60];
            mine_src_coor_y[i] = mine_raw[i+1][57:48];
            mine_src_depth[i] = mine_raw[i+1][45:36];
            mine_dst_coor_x[i] = mine_raw[i+1][33:24];
            mine_dst_coor_y[i] = mine_raw[i+1][21:12];
            mine_dst_depth[i] = mine_raw[i+1][9:0];
        end

        o_src_coor_x = mine_src_coor_x[mine_pos];
        o_src_coor_y = mine_src_coor_y[mine_pos];
        o_src_depth = mine_src_depth[mine_pos];
        o_dst_coor_x = mine_dst_coor_x[mine_pos];
        o_dst_coor_y = mine_dst_coor_y[mine_pos];
        o_dst_depth = mine_dst_depth[mine_pos];
        

        checking = (index == 2);

        

        end_pos = golden_raw[0];
        mine_end_pos = mine_raw[0];
    end

    initial begin
        $fsdbDumpfile("test.fsdb");
        $fsdbDumpvars(0, CHIP_tb, "+mda");
    end

    initial begin
        // f = $fopen("fft_o.txt","w");
        clk         = 1'b1;
        rst_n       = 1'b1;  
        i           = 0;
        j           = 0;
        index       = 0;
        err         = 0;
        valid       = 0;
        check_again = 0;
        golden_pos  = 0;
        mine_pos    = 0;
        o_valid     = 0;
        start       = 0;
        same        = 0;
        $readmemh ("Hardware_implementation/testfile/golden.txt", golden_raw);
        $readmemh ("Hardware_implementation/result/coores1.txt", mine_raw);
        $display ("initialize sucessfully");
        #5 rst_n=1'b0;         
        #5 rst_n=1'b1;

    end

    always begin #(`CYCLE/2) clk = ~clk; end

    initial #(`TIME_OUT) begin
        $display("Time_out! AAAAAA");
        $display("⠄⠄⠄⠄⠄⠄⠄⠈⠉⠁⠈⠉⠉⠙⠿⣿⣿⣿⣿⣿");
        $display("⠄⠄⠄⠄⠄⠄⠄⠄⣀⣀⣀⠄⠄⠄⠄⠄⠹⣿⣿⣿");
        $display("⠄⠄⠄⠄⠄⢐⣲⣿⣿⣯⠭⠉⠙⠲⣄⡀⠄⠈⢿⣿");
        $display("⠐⠄⠄⠰⠒⠚⢩⣉⠼⡟⠙⠛⠿⡟⣤⡳⡀⠄⠄⢻");
        $display("⠄⠄⢀⣀⣀⣢⣶⣿⣦⣭⣤⣭⣵⣶⣿⣿⣏⠄⠄⣿");
        $display("⠄⣼⣿⣿⣿⡉⣿⣀⣽⣸⣿⣿⣿⣿⣿⣿⣿⡆⣀⣿");
        $display("⢠⣿⣿⣿⠿⠟⠛⠻⢿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣼");
        $display("⠄⣿⣿⣿⡆⠄⠄⠄⠄⠳⡈⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⠄⢹⣿⣿⡇⠄⠄⠄⠄⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⠄⠄⢿⣿⣷⣨⣽⣭⢁⣡⣿⣿⠟⣩⣿⣿⣿⠿⠿⠟");
        $display("⠄⠄⠈⡍⠻⣿⣿⣿⣿⠟⠋⢁⣼⠿⠋⠉⠄⠄⠄⠄");
        $display("⠄⠄⠄⠈⠴⢬⣙⣛⡥⠴⠂⠄⠄⠄⠄⠄⠄⠄⠄.");
        $finish;
    end

    always @(negedge clk)begin
        // feed data
        if(index != 2) begin
            index = index + 1;
        end
        else begin
            if(mine_pos < mine_end_pos-1) begin
                o_valid = 1;
                if(start == 0) begin
                    start = 1;
                end
                else mine_pos = mine_pos + 1;
            end
            else begin
                o_valid = 0;
                index = index + 1;
            end
        end
    end

    always@(posedge clk) begin
        if(index == 3) begin
            for(int j = golden_pos; j < end_pos; j = j+1) begin
                $display("Error(lack): (%h, %h, %h) <---> (%h, %h, %h)", golden_src_coor_x[j], golden_src_coor_y[j], golden_src_depth[j], golden_dst_coor_x[j], golden_dst_coor_y[j], golden_dst_depth[j]);
            end
            $display("end of checking");
            $finish;
        end 

        if(o_valid) begin
            while(checking || check_again) begin
                same = compare(golden_src_coor_x[golden_pos], golden_src_coor_y[golden_pos], golden_src_depth[golden_pos], golden_dst_coor_x[golden_pos], golden_dst_coor_y[golden_pos], golden_dst_depth[golden_pos], o_src_coor_x, o_src_coor_y, o_src_depth, o_dst_coor_x, o_dst_coor_y, o_dst_depth);
                // $display("golden_pos = %d, same = %b, golden_src_coor_x = %h, mine_src_coor_x = %h", golden_pos, same, golden_src_coor_x[golden_pos], o_src_coor_x);
                if(check_again == 0) begin
                    if(same) begin
                        // $display("1");
                        $display("pass");
                        golden_pos = golden_pos + 1;
                        break;
                    end
                    else begin
                        // check forward, see if the coores would be found 
                        // (if so, means "lack")
                        // (if not, means "extra")
                        // $display("2");                      
                        check_again = 1;
                        start_pos = golden_pos;
                        golden_pos = golden_pos + 1;
                        continue;
                    end
                end
                else begin
                    if(golden_pos == end_pos) begin // extra
                        // $display("3"); 
                        $display("Error(extra): (%h, %h, %h) <---> (%h, %h, %h)", o_src_coor_x, o_src_coor_y, o_src_depth, o_dst_coor_x, o_dst_coor_y, o_dst_depth);
                        golden_pos = start_pos;
                        check_again = 0;
                        break;
                    end
                    else if(same) begin // lack
                        // $display("4"); 
                        for(int j = start_pos; j < golden_pos; j = j+1) begin
                            $display("Error(lack): (%h, %h, %h) <---> (%h, %h, %h)", golden_src_coor_x[j], golden_src_coor_y[j], golden_src_depth[j], golden_dst_coor_x[j], golden_dst_coor_y[j], golden_dst_depth[j]);
                        end
                        $display("pass");
                        golden_pos = golden_pos + 1;
                        check_again = 0;
                        break;
                    end
                    else begin
                        golden_pos = golden_pos + 1;
                        continue;
                    end
                end
            end
        end
    end


endmodule