`timescale 1ns/10ps
`define CYCLE    10           	         // Modify your clock period here
`define TIME_OUT 640*1500*10       
// `define TIME_OUT 640*100*10     

`ifdef RTL
    `include "CHIP_all.sv"
    `include "sram/sram_FAST_lb.v"
    `include "sram/sram_dp_NMS.v"
    `include "sram/sram_dp_sincos.v"
`endif

// `ifdef SYN
//     `include "FFT_syn.v"
//     // `include "tsmc13.v"
//     `define SDF
//     `define SDFFILE "FFT_syn.sdf"
// `endif

// simulation
// RTL: ncverilog CHIP_alltb.sv +incdir+/opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver/ -y /opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver +libext+.v+notimingchecks +define+RTL +access+r 



module CHIP_tb;
    
    integer i, j, f1, f2, err, index;
    // genvar s;
    logic clk, rst_n;

    logic [7:0] pixel_in [0:307199];
    logic [7:0] pixel_in2 [0:307199];
    logic [7:0] pixel_in3 [0:307199];
    
    logic start;
    logic [7:0] pixel;
    logic valid;
    
    logic [9:0]    inspect_coordinate_X;
    logic [9:0]    inspect_coordinate_Y;
    logic [7:0]    inspect_score;
    logic          inspect_flag;
    logic [255:0]  inspect_descriptor;
    logic          inspect_start;
    logic          inspect_end;

    logic          o_frame_end, o_frame_start;
    logic          o_valid;
    logic          o_ready;
    logic [9:0]    o_src_coor_x;
    logic [9:0]    o_src_coor_y;
    logic [9:0]    o_dst_coor_x;
    logic [9:0]    o_dst_coor_y;

    // SRAM used ports:
    // ---------------------------------------------------------------------------
    //      clkA, clkB <- clk
    //      AA, DA, WENA, QA <- port A (note that wenA 0 for WRITE and 1 for READ)
    //      AB, DB, WENB, QB <- port B (note that wenB 0 for WRITE and 1 for READ)
    // ---------------------------------------------------------------------------
    // other ports-input are given in testbench (in simulation)
    // sram interface
    logic [7:0]     bus1_sram_QA [0:5];
    logic [7:0]     bus1_sram_QB [0:5];
    logic          bus1_sram_WENA [0:5];
    logic          bus1_sram_WENB [0:5];
    logic [7:0]    bus1_sram_DA [0:5];
    logic [7:0]    bus1_sram_DB [0:5];
    logic [9:0]    bus1_sram_AA [0:5];
    logic [9:0]    bus1_sram_AB [0:5];

    logic [11:0]     bus2_sram_QA [0:1];
    logic [11:0]     bus2_sram_QB [0:1];
    logic          bus2_sram_WENA [0:1];
    logic          bus2_sram_WENB [0:1];
    logic [11:0]    bus2_sram_DA [0:1];
    logic [11:0]    bus2_sram_DB [0:1];
    logic [9:0]    bus2_sram_AA [0:1];
    logic [9:0]    bus2_sram_AB [0:1];

    logic [9:0]     bus3_sram_QA;
    logic [9:0]     bus3_sram_QB;
    logic          bus3_sram_WENA;
    logic          bus3_sram_WENB;
    logic [9:0]    bus3_sram_DA;
    logic [9:0]    bus3_sram_DB;
    logic [9:0]    bus3_sram_AA;
    logic [9:0]    bus3_sram_AB;

    logic [7:0]     bus4_sram_QA [0:29];
    logic [7:0]     bus4_sram_QB [0:29];
    logic          bus4_sram_WENA [0:29];
    logic          bus4_sram_WENB [0:29];
    logic [7:0]    bus4_sram_DA [0:29];
    logic [7:0]    bus4_sram_DB [0:29];
    logic [9:0]    bus4_sram_AA [0:29];
    logic [9:0]    bus4_sram_AB [0:29];

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
        .i_frame_start(start),
        .i_valid(valid),

        // .inspect_coordinate_X(inspect_coordinate_X),
        // .inspect_coordinate_Y(inspect_coordinate_Y),
        // .inspect_score(inspect_score),
        // .inspect_flag(inspect_flag),
        // .inspect_descriptor(inspect_descriptor),
        // .inspect_start(inspect_start),
        // .inspect_end(inspect_end),

        .o_ready(o_ready),
        .o_frame_end(o_frame_end),
        .o_frame_start(o_frame_start),
        .o_valid(o_valid),
        .o_src_coor_x(o_src_coor_x),
        .o_src_coor_y(o_src_coor_y),
        .o_dst_coor_x(o_dst_coor_x),
        .o_dst_coor_y(o_dst_coor_y),

        .FAST_lb_sram_QA(bus1_sram_QA),
        .FAST_lb_sram_QB(bus1_sram_QB),
        .FAST_lb_sram_WENA(bus1_sram_WENA),
        .FAST_lb_sram_WENB(bus1_sram_WENB),
        .FAST_lb_sram_DA(bus1_sram_DA),
        .FAST_lb_sram_DB(bus1_sram_DB),
        .FAST_lb_sram_AA(bus1_sram_AA),
        .FAST_lb_sram_AB(bus1_sram_AB),

        .FAST_sincos_sram_QA(bus2_sram_QA),
        .FAST_sincos_sram_QB(bus2_sram_QB),
        .FAST_sincos_sram_WENA(bus2_sram_WENA),
        .FAST_sincos_sram_WENB(bus2_sram_WENB),
        .FAST_sincos_sram_DA(bus2_sram_DA),
        .FAST_sincos_sram_DB(bus2_sram_DB),
        .FAST_sincos_sram_AA(bus2_sram_AA),
        .FAST_sincos_sram_AB(bus2_sram_AB),

        .FAST_NMS_sram_QA(bus3_sram_QA),
        .FAST_NMS_sram_QB(bus3_sram_QB),
        .FAST_NMS_sram_WENA(bus3_sram_WENA),
        .FAST_NMS_sram_WENB(bus3_sram_WENB),
        .FAST_NMS_sram_DA(bus3_sram_DA),
        .FAST_NMS_sram_DB(bus3_sram_DB),
        .FAST_NMS_sram_AA(bus3_sram_AA),
        .FAST_NMS_sram_AB(bus3_sram_AB),

        .BRIEF_lb_sram_QA(bus4_sram_QA),
        .BRIEF_lb_sram_QB(bus4_sram_QB),
        .BRIEF_lb_sram_WENA(bus4_sram_WENA),
        .BRIEF_lb_sram_WENB(bus4_sram_WENB),
        .BRIEF_lb_sram_DA(bus4_sram_DA),
        .BRIEF_lb_sram_DB(bus4_sram_DB),
        .BRIEF_lb_sram_AA(bus4_sram_AA),
        .BRIEF_lb_sram_AB(bus4_sram_AB)
    );
    generate
        for(genvar s = 0; s < 6; s = s+1) begin
            sram_FAST_lb uut1 (
                // clock signal
                .CLKA(clk),
                .CLKB(clk),

                // sync clock (active high)
                .STOVA(1'b1),
                .STOVB(1'b1),

                // setting
                // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
                // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
                // if the read row address and write row address match.
                .COLLDISN(1'b0),

                // address
                .AA(bus1_sram_AA[s]),
                .AB(bus1_sram_AB[s]),
                // data 
                .DA(bus1_sram_DA[s]),
                .DB(bus1_sram_DB[s]),

                // chip enable (active low, 0 for ON and 1 for OFF)
                // .CENA(1'b1),
                // .CENB(1'b1),
                .CENA(1'b0),
                .CENB(1'b0),

                // write enable (active low, 0 for WRITE and 1 for READ)
                .WENA(bus1_sram_WENA[s]),
                .WENB(bus1_sram_WENB[s]),

                // data output bus
                .QA(bus1_sram_QA[s]),
                .QB(bus1_sram_QB[s]),

                // test mode (active low, 1 for regular operation)
                .TENA(1'b1),
                .TENB(1'b1),

                // bypass
                .BENA(1'b1),
                .BENB(1'b1),

                // useless
                .EMAA(3'd0),
                .EMAB(3'd0),
                .EMAWA(2'd0),
                .EMAWB(2'd0),
                .EMASA(1'b0),
                .EMASB(1'b0),
                .TCENA(1'b1),
                .TWENA(1'b1),
                .TAA(8'd0),
                .TDA(8'd0),
                .TQA(8'd0),
                .TCENB(1'b1),
                .TWENB(1'b1),
                .TAB(8'd0),
                .TDB(8'd0),
                .TQB(8'd0),
                .RET1N(1'b1)
            );
        end
    endgenerate

    generate
        for(genvar s = 0; s < 2; s = s+1) begin
            sram_dp_sincos uut2 (
                // clock signal
                .CLKA(clk),
                .CLKB(clk),

                // sync clock (active high)
                .STOVA(1'b1),
                .STOVB(1'b1),

                // setting
                // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
                // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
                // if the read row address and write row address match.
                .COLLDISN(1'b0),

                // address
                .AA(bus2_sram_AA[s]),
                .AB(bus2_sram_AB[s]),
                // data 
                .DA(bus2_sram_DA[s]),
                .DB(bus2_sram_DB[s]),

                // chip enable (active low, 0 for ON and 1 for OFF)
                // .CENA(1'b1),
                // .CENB(1'b1),
                .CENA(1'b0),
                .CENB(1'b0),

                // write enable (active low, 0 for WRITE and 1 for READ)
                .WENA(bus2_sram_WENA[s]),
                .WENB(bus2_sram_WENB[s]),

                // data output bus
                .QA(bus2_sram_QA[s]),
                .QB(bus2_sram_QB[s]),

                // test mode (active low, 1 for regular operation)
                .TENA(1'b1),
                .TENB(1'b1),

                // bypass
                .BENA(1'b1),
                .BENB(1'b1),

                // useless
                .EMAA(3'd0),
                .EMAB(3'd0),
                .EMAWA(2'd0),
                .EMAWB(2'd0),
                .EMASA(1'b0),
                .EMASB(1'b0),
                .TCENA(1'b1),
                .TWENA(1'b1),
                .TAA(8'd0),
                .TDA(8'd0),
                .TQA(8'd0),
                .TCENB(1'b1),
                .TWENB(1'b1),
                .TAB(8'd0),
                .TDB(8'd0),
                .TQB(8'd0),
                .RET1N(1'b1)
            );
        end
    endgenerate
    
    sram_dp_NMS uut3 (
        // clock signal
        .CLKA(clk),
        .CLKB(clk),

        // sync clock (active high)
        .STOVA(1'b1),
        .STOVB(1'b1),

        // setting
        // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
        // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
        // if the read row address and write row address match.
        .COLLDISN(1'b0),

        // address
        .AA(bus3_sram_AA),
        .AB(bus3_sram_AB),
        // data 
        .DA(bus3_sram_DA),
        .DB(bus3_sram_DB),

        // chip enable (active low, 0 for ON and 1 for OFF)
        // .CENA(1'b1),
        // .CENB(1'b1),
        .CENA(1'b0),
        .CENB(1'b0),

        // write enable (active low, 0 for WRITE and 1 for READ)
        .WENA(bus3_sram_WENA),
        .WENB(bus3_sram_WENB),

        // data output bus
        .QA(bus3_sram_QA),
        .QB(bus3_sram_QB),

        // test mode (active low, 1 for regular operation)
        .TENA(1'b1),
        .TENB(1'b1),

        // bypass
        .BENA(1'b1),
        .BENB(1'b1),

        // useless
        .EMAA(3'd0),
        .EMAB(3'd0),
        .EMAWA(2'd0),
        .EMAWB(2'd0),
        .EMASA(1'b0),
        .EMASB(1'b0),
        .TCENA(1'b1),
        .TWENA(1'b1),
        .TAA(8'd0),
        .TDA(8'd0),
        .TQA(8'd0),
        .TCENB(1'b1),
        .TWENB(1'b1),
        .TAB(8'd0),
        .TDB(8'd0),
        .TQB(8'd0),
        .RET1N(1'b1)
    );

    generate
        for(genvar s = 0; s < 30; s = s+1) begin
            sram_FAST_lb uut4 (
                // clock signal
                .CLKA(clk),
                .CLKB(clk),

                // sync clock (active high)
                .STOVA(1'b1),
                .STOVB(1'b1),

                // setting
                // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
                // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
                // if the read row address and write row address match.
                .COLLDISN(1'b0),

                // address
                .AA(bus4_sram_AA[s]),
                .AB(bus4_sram_AB[s]),
                // data 
                .DA(bus4_sram_DA[s]),
                .DB(bus4_sram_DB[s]),

                // chip enable (active low, 0 for ON and 1 for OFF)
                // .CENA(1'b1),
                // .CENB(1'b1),
                .CENA(1'b0),
                .CENB(1'b0),

                // write enable (active low, 0 for WRITE and 1 for READ)
                .WENA(bus4_sram_WENA[s]),
                .WENB(bus4_sram_WENB[s]),

                // data output bus
                .QA(bus4_sram_QA[s]),
                .QB(bus4_sram_QB[s]),

                // test mode (active low, 1 for regular operation)
                .TENA(1'b1),
                .TENB(1'b1),

                // bypass
                .BENA(1'b1),
                .BENB(1'b1),

                // useless
                .EMAA(3'd0),
                .EMAB(3'd0),
                .EMAWA(2'd0),
                .EMAWB(2'd0),
                .EMASA(1'b0),
                .EMASB(1'b0),
                .TCENA(1'b1),
                .TWENA(1'b1),
                .TAA(8'd0),
                .TDA(8'd0),
                .TQA(8'd0),
                .TCENB(1'b1),
                .TWENB(1'b1),
                .TAB(8'd0),
                .TDB(8'd0),
                .TQB(8'd0),
                .RET1N(1'b1)
            );
        end
    endgenerate

    // `ifdef SDF
    //     initial $sdf_annotate(`SDFFILE, chip0);
    // `endif
    
    initial	begin
        f1 = $fopen("../result/coores.txt","w");
        f2 = $fopen("../result/keypts.txt","w");
        $readmemh ("../testfile/pixel_in.dat", pixel_in);
        $readmemh ("../testfile/pixel_in2.dat", pixel_in2);
        $readmemh ("../testfile/pixel_in3.dat", pixel_in3);
    end


    initial begin
        // f = $fopen("fft_o.txt","w");
        clk         = 1'b1;
        rst_n       = 1'b1;  
        i           = 0;
        j           = 0;
        index       = 0;
        err         = 0;
        valid     = 0;
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
            valid = 1;
            i = i+1;      
        end
        else if(o_ready) begin
            i = 0;
            index = index + 1;
            valid = 0;
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
        //     $fwrite(f2, "%h %h %h %h \n", inspect_coordinate_X, inspect_coordinate_Y, inspect_score, inspect_descriptor);
        // end
        if(o_frame_start) begin
            $display("frame start");
            $fwrite(f1, "frame start\n");
        end
        if(o_frame_end) begin
            $display("frame end");
            $fwrite(f1, "frame end\n");
        end
        if(o_valid) begin
            $display("(%h, %h) <---> (%h, %h)", o_src_coor_x, o_src_coor_y, o_dst_coor_x, o_dst_coor_y);
            $fwrite(f1, "(%h, %h) <---> (%h, %h)\n", o_src_coor_x, o_src_coor_y, o_dst_coor_x, o_dst_coor_y);
        end
    end

endmodule