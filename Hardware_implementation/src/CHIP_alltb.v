`timescale 1ns/10ps
`define CYCLE    10           	         // Modify your clock period here
`define TIME_OUT 640*1500*10       
// `define TIME_OUT 640*100*10     

`ifdef RTL
    `include "CHIP_all.sv"
`endif

// `ifdef SYN
//     `include "FFT_syn.v"
//     // `include "tsmc13.v"
//     `define SDF
//     `define SDFFILE "FFT_syn.sdf"
// `endif

// simulation
// RTL: ncverilog CHIP_alltb.v +incdir+/opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver/ -y /opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver +libext+.v+notimingchecks +define+RTL +access+r 



module CHIP_tb;
    
    integer i, j, f, err, index;
    reg clk, rst_n;

    reg [7:0] pixel_in [0:307199];
    reg [7:0] pixel_in2 [0:307199];
    reg [7:0] pixel_in3 [0:307199];
    
    reg start;
    reg [7:0] pixel;
    
    wire [9:0]    inspect_coordinate_X;
    wire [9:0]    inspect_coordinate_Y;
    wire [7:0]    inspect_score;
    wire          inspect_flag;
    wire [255:0]  inspect_descriptor;
    wire          inspect_start;
    wire          inspect_end;

    wire          o_end;
    wire          o_valid;
    wire          o_ready;
    wire [9:0]    o_src_coor_x;
    wire [9:0]    o_src_coor_y;
    wire [9:0]    o_dst_coor_x;
    wire [9:0]    o_dst_coor_y;

    CHIP
    #(
        .WIDTH(12'd640),
        .HEIGHT(12'd480),
        .EDGE(12'd31)
    )
    chip0  
    (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_pixel(pixel),
        .i_start(start),

        .inspect_coordinate_X(inspect_coordinate_X),
        .inspect_coordinate_Y(inspect_coordinate_Y),
        .inspect_score(inspect_score),
        .inspect_flag(inspect_flag),
        .inspect_descriptor(inspect_descriptor),
        .inspect_start(inspect_start),
        .inspect_end(inspect_end),

        .o_ready(o_ready),
        .o_end(o_end),
        .o_valid(o_valid),
        .o_src_coor_x(o_src_coor_x),
        .o_src_coor_y(o_src_coor_y),
        .o_dst_coor_x(o_dst_coor_x),
        .o_dst_coor_y(o_dst_coor_y)
    );



    // `ifdef SDF
    //     initial $sdf_annotate(`SDFFILE, chip0);
    // `endif
    
    initial	begin
        f = $fopen("output.txt","w");
        $readmemh ("../testfile/pixel_in.txt", pixel_in);
        $readmemh ("../testfile/pixel_in2.txt", pixel_in2);
        $readmemh ("../testfile/pixel_in3.txt", pixel_in3);
    end


    initial begin
        // f = $fopen("fft_o.txt","w");
        clk         = 1'b1;
        rst_n       = 1'b1;  
        i           = 0;
        j           = 0;
        index       = 0;
        err         = 0;
        #5 rst_n=1'b0;         
        #5 rst_n=1'b1;

    end

    always begin #(`CYCLE/2) clk = ~clk; end

    // initial begin
    //     $fsdbDumpfile("CHIP.fsdb");
    //     $fsdbDumpvars(0, CHIP_tb, "+mda");
    // end

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
        pixel = 0;
        if(i < 307200) begin
            if(i == 0) start = 1;
            else start = 0;
            case(index)
                0: pixel = pixel_in[i];
                1: pixel = pixel_in2[i];
                2: pixel = pixel_in3[i];
                default: pixel = 0;
            endcase
            i = i+1;      
        end
        else if(o_ready) begin
            i = 0;
            index = index + 1;
        end

        // if(o_ready) begin
        //     if(i == 0) start = 1;
        //     else start = 0;
        //     pixel = pixel_in2[i];
        //     i = i+1;     
        // end

    end

    always@(posedge clk) begin
        // if(inspect_flag) begin
        //     $display("keypoint found: %h %h %h %h \n", inspect_coordinate_X, inspect_coordinate_Y, inspect_score, inspect_descriptor);
        //     $fwrite(f, "%h %h %h %h \n", inspect_coordinate_X, inspect_coordinate_Y, inspect_score, inspect_descriptor);
        // end
        if(o_end) begin
            $display("frame changed");
            $fwrite(f, "frame changed\n");
        end
        if(o_valid) begin
            $display("(%h, %h) <---> (%h, %h)", o_src_coor_x, o_src_coor_y, o_dst_coor_x, o_dst_coor_y);
            $fwrite(f, "(%h, %h) <---> (%h, %h)\n", o_src_coor_x, o_src_coor_y, o_dst_coor_x, o_dst_coor_y);
        end
    end

endmodule