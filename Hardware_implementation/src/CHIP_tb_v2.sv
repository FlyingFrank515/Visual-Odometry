`timescale 1ns/10ps
`define CYCLE    10           	         // Modify your clock period here
`define TIME_OUT 640*1500*10       
// `define TIME_OUT 640*100*10     

`ifdef RTL
    `include "CHIP_all.sv"
    `include "sram_v3/sram_lb_FAST.v"
    `include "sram_v3/sram_FIFO_NMS.v"
    `include "sram_v3/sram_dp_sincos.v"
    `include "sram_v3/sram_BRIEF_lb.v"
    `include "sram_v3/sram_dp_desc.v"
    `include "sram_v3/sram_dp_point.v"
    `include "sram_v3/sram_dp_depth.v"
`endif


// simulation
// RTL: ncverilog CHIP_alltb.sv +incdir+/opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver/ -y /opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver +libext+.v+notimingchecks +define+RTL +access+r 



module CHIP_tb;

    function bit compare(
        input logic [9:0]  golden_src_coor_x,
        input logic [9:0]  golden_src_coor_y,
        input logic [15:0]  golden_src_depth,
        input logic [9:0]  golden_dst_coor_x,
        input logic [9:0]  golden_dst_coor_y,
        input logic [15:0]  golden_dst_depth,
        input logic [9:0]  o_src_coor_x,
        input logic [9:0]  o_src_coor_y,
        input logic [15:0]  o_src_depth,
        input logic [9:0]  o_dst_coor_x,
        input logic [9:0]  o_dst_coor_y,
        input logic [15:0]  o_dst_depth);

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
    
    integer i, j, f1, f2, f3, err, index;
    // genvar s;
    logic clk, rst_n;

    logic [7:0] pixel_in [0:307199];
    logic [7:0] pixel_in2 [0:307199];
    logic [7:0] pixel_in3 [0:307199];
    logic [15:0] depth_in [0:307199];
    logic [15:0] depth_in2 [0:307199];
    logic [15:0] depth_in3 [0:307199];

    logic [79:0] golden_raw [0:199];
    logic [9:0]  golden_src_coor_x[0:199];
    logic [9:0]  golden_src_coor_y[0:199];
    logic [15:0]  golden_src_depth[0:199];
    logic [9:0]  golden_dst_coor_x[0:199];
    logic [9:0]  golden_dst_coor_y[0:199];
    logic [15:0]  golden_dst_depth[0:199];
    
    logic [9:0] golden_pos, start_pos, end_pos;
    logic       check_again, same, reach_end, checking;
    
    // logic [9:0]    inspect_coordinate_X;
    // logic [9:0]    inspect_coordinate_Y;
    // logic [9:0]    inspect_depth;
    // logic [7:0]    inspect_score;
    // logic          inspect_flag;
    // logic [255:0]  inspect_descriptor;
    // logic          inspect_start;
    // logic          inspect_end;

    logic start;
    logic [7:0] pixel;
    logic [15:0] depth;
    logic valid;
    

    logic          o_frame_end, o_frame_start;
    logic          o_valid;
    logic          o_ready;
    logic [9:0]    o_src_coor_x;
    logic [9:0]    o_src_coor_y;
    logic [15:0]    o_src_depth;
    logic [9:0]    o_dst_coor_x;
    logic [9:0]    o_dst_coor_y;
    logic [15:0]    o_dst_depth;

    // SRAM used ports:
    // ---------------------------------------------------------------------------
    //      clkA, clkB <- clk
    //      AA, DA, WENA, QA <- port A (note that wenA 0 for WRITE and 1 for READ)
    //      AB, DB, WENB, QB <- port B (note that wenB 0 for WRITE and 1 for READ)
    // ---------------------------------------------------------------------------
    // other ports-input are given in testbench (in simulation)
    // sram interface
    logic [23:0]     bus1_sram_QA [0:5];
    logic [23:0]     bus1_sram_QB [0:5];
    logic          bus1_sram_WENA [0:5];
    logic          bus1_sram_WENB [0:5];
    logic [23:0]    bus1_sram_DA [0:5]; // pixel + depth
    logic [23:0]    bus1_sram_DB [0:5]; // pixel + depth
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

    logic [25:0]     bus3_sram_QA;
    logic [25:0]     bus3_sram_QB;
    logic          bus3_sram_WENA;
    logic          bus3_sram_WENB;
    logic [25:0]    bus3_sram_DA; // score, flag, reserved + depth
    logic [25:0]    bus3_sram_DB; // score, flag, reserved + depth
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

    logic [31:0]     bus5_sram_QA [0:7];
    logic          bus5_sram_WENA [0:7];
    logic [31:0]    bus5_sram_DA [0:7];
    logic [8:0]    bus5_sram_AA [0:7];

    logic [31:0]     bus6_sram_QA [0:7];
    logic          bus6_sram_WENA [0:7];
    logic [31:0]    bus6_sram_DA [0:7];
    logic [8:0]    bus6_sram_AA [0:7];

    logic [19:0]     bus7_sram_QA;
    logic          bus7_sram_WENA;
    logic [19:0]    bus7_sram_DA;
    logic [8:0]    bus7_sram_AA;

    logic [19:0]     bus8_sram_QA;
    logic          bus8_sram_WENA;
    logic [19:0]    bus8_sram_DA;
    logic [8:0]    bus8_sram_AA;

    logic [15:0]     bus9_sram_QA;
    logic          bus9_sram_WENA;
    logic [15:0]    bus9_sram_DA;
    logic [8:0]    bus9_sram_AA;

    logic [15:0]     bus10_sram_QA;
    logic          bus10_sram_WENA;
    logic [15:0]    bus10_sram_DA;
    logic [8:0]    bus10_sram_AA;

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
        .i_depth(depth),
        .i_frame_start(start),
        .i_valid(valid),

        // .inspect_coordinate_X(inspect_coordinate_X),
        // .inspect_coordinate_Y(inspect_coordinate_Y),
        // .inspect_score(inspect_score),
        // .inspect_depth(inspect_depth),
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
        .o_src_depth(o_src_depth),
        .o_dst_coor_x(o_dst_coor_x),
        .o_dst_coor_y(o_dst_coor_y),
        .o_dst_depth(o_dst_depth),

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
        .BRIEF_lb_sram_AB(bus4_sram_AB),

        .MATCH_mem1_point_QA(bus7_sram_QA),
        .MATCH_mem1_point_WENA(bus7_sram_WENA),
        .MATCH_mem1_point_DA(bus7_sram_DA),
        .MATCH_mem1_point_AA(bus7_sram_AA),

        .MATCH_mem2_point_QA(bus8_sram_QA),
        .MATCH_mem2_point_WENA(bus8_sram_WENA),
        .MATCH_mem2_point_DA(bus8_sram_DA),
        .MATCH_mem2_point_AA(bus8_sram_AA),

        .MATCH_mem1_depth_QA(bus9_sram_QA),
        .MATCH_mem1_depth_WENA(bus9_sram_WENA),
        .MATCH_mem1_depth_DA(bus9_sram_DA),
        .MATCH_mem1_depth_AA(bus9_sram_AA),

        .MATCH_mem2_depth_QA(bus10_sram_QA),
        .MATCH_mem2_depth_WENA(bus10_sram_WENA),
        .MATCH_mem2_depth_DA(bus10_sram_DA),
        .MATCH_mem2_depth_AA(bus10_sram_AA),

        .MATCH_mem1_desc_QA(bus5_sram_QA),
        .MATCH_mem1_desc_WENA(bus5_sram_WENA),
        .MATCH_mem1_desc_DA(bus5_sram_DA),
        .MATCH_mem1_desc_AA(bus5_sram_AA),

        .MATCH_mem2_desc_QA(bus6_sram_QA),
        .MATCH_mem2_desc_WENA(bus6_sram_WENA),
        .MATCH_mem2_desc_DA(bus6_sram_DA),
        .MATCH_mem2_desc_AA(bus6_sram_AA)
    );
    generate
        for(genvar s = 0; s < 6; s = s+1) begin
            sram_lb_FAST uut1 (
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
    
    sram_FIFO_NMS uut3 (
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
            sram_BRIEF_lb uut4 (
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

    generate
        for(genvar s = 0; s < 8; s = s+1) begin
            sram_dp_desc uut5 (
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
                .AA(bus5_sram_AA[s]),
                .AB(8'd0),
                // data 
                .DA(bus5_sram_DA[s]),
                .DB(31'd0),

                // chip enable (active low, 0 for ON and 1 for OFF)
                // .CENA(1'b1),
                // .CENB(1'b1),
                .CENA(1'b0),
                .CENB(1'b1),

                // write enable (active low, 0 for WRITE and 1 for READ)
                .WENA(bus5_sram_WENA[s]),
                .WENB(1'b1),

                // data output bus
                .QA(bus5_sram_QA[s]),
                .QB(),

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
        for(genvar s = 0; s < 8; s = s+1) begin
            sram_dp_desc uut6 (
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
                .AA(bus6_sram_AA[s]),
                .AB(8'd0),
                // data 
                .DA(bus6_sram_DA[s]),
                .DB(31'd0),

                // chip enable (active low, 0 for ON and 1 for OFF)
                // .CENA(1'b1),
                // .CENB(1'b1),
                .CENA(1'b0),
                .CENB(1'b1),

                // write enable (active low, 0 for WRITE and 1 for READ)
                .WENA(bus6_sram_WENA[s]),
                .WENB(1'b1),

                // data output bus
                .QA(bus6_sram_QA[s]),
                .QB(),

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

    sram_dp_point uut7 (
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
        .AA(bus7_sram_AA),
        .AB(8'd0),
        // data 
        .DA(bus7_sram_DA),
        .DB(31'd0),

        // chip enable (active low, 0 for ON and 1 for OFF)
        // .CENA(1'b1),
        // .CENB(1'b1),
        .CENA(1'b0),
        .CENB(1'b1),

        // write enable (active low, 0 for WRITE and 1 for READ)
        .WENA(bus7_sram_WENA),
        .WENB(1'b1),

        // data output bus
        .QA(bus7_sram_QA),
        .QB(),

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

    sram_dp_point uut8 (
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
        .AA(bus8_sram_AA),
        .AB(8'd0),
        // data 
        .DA(bus8_sram_DA),
        .DB(31'd0),

        // chip enable (active low, 0 for ON and 1 for OFF)
        // .CENA(1'b1),
        // .CENB(1'b1),
        .CENA(1'b0),
        .CENB(1'b1),

        // write enable (active low, 0 for WRITE and 1 for READ)
        .WENA(bus8_sram_WENA),
        .WENB(1'b1),

        // data output bus
        .QA(bus8_sram_QA),
        .QB(),

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

    sram_dp_depth uut9 (
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
        .AA(bus9_sram_AA),
        .AB(8'd0),
        // data 
        .DA(bus9_sram_DA),
        .DB(31'd0),

        // chip enable (active low, 0 for ON and 1 for OFF)
        // .CENA(1'b1),
        // .CENB(1'b1),
        .CENA(1'b0),
        .CENB(1'b1),

        // write enable (active low, 0 for WRITE and 1 for READ)
        .WENA(bus9_sram_WENA),
        .WENB(1'b1),

        // data output bus
        .QA(bus9_sram_QA),
        .QB(),

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

    sram_dp_depth uut10 (
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
        .AA(bus10_sram_AA),
        .AB(8'd0),
        // data 
        .DA(bus10_sram_DA),
        .DB(31'd0),

        // chip enable (active low, 0 for ON and 1 for OFF)
        // .CENA(1'b1),
        // .CENB(1'b1),
        .CENA(1'b0),
        .CENB(1'b1),

        // write enable (active low, 0 for WRITE and 1 for READ)
        .WENA(bus10_sram_WENA),
        .WENB(1'b1),

        // data output bus
        .QA(bus10_sram_QA),
        .QB(),

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
    // `ifdef SDF
    //     initial $sdf_annotate(`SDFFILE, chip0);
    // `endif
    

    always_comb begin // golden connection
        for(int i = 0; i < 199; i = i+1) begin
            golden_src_coor_x[i] = golden_raw[i+1][77:68];
            golden_src_coor_y[i] = golden_raw[i+1][65:56];
            golden_src_depth[i] = golden_raw[i+1][55:40];
            golden_dst_coor_x[i] = golden_raw[i+1][37:28];
            golden_dst_coor_y[i] = golden_raw[i+1][25:16];
            golden_dst_depth[i] = golden_raw[i+1][15:0];
        end

        checking = (index == 2);
        end_pos = golden_raw[0];
    end

    // initial begin
    //     $fsdbDumpfile("CHIP_check.fsdb");
    //     $fsdbDumpvars(0, CHIP_tb.chip0.MATCH_unit, "+mda");
    // end

    initial begin
        f1 = $fopen("../result/check_log.txt","w");
        f2 = $fopen("../result/read.txt","w");
        f3 = $fopen("../result/corres.txt","w");
        clk         = 1'b1;
        rst_n       = 1'b1;  
        i           = 0;
        j           = 0;
        index       = 0;
        err         = 0;
        valid       = 0;
        check_again = 0;
        golden_pos  = 0;
        same        = 0;
        $readmemh ("../testfile/pixel_in.txt", pixel_in);
        $readmemh ("../testfile/pixel_in2.txt", pixel_in2);
        $readmemh ("../testfile/pixel_in3.txt", pixel_in3);
        $readmemh ("../testfile/depth_in1.txt", depth_in);
        $readmemh ("../testfile/depth_in2.txt", depth_in2);
        $readmemh ("../testfile/depth_in3.txt", depth_in3);
        $readmemh ("../testfile/golden.txt", golden_raw);
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
        pixel = 0;
        depth = 0;
        if(i < 307200) begin
            if(i == 0) start = 1;
            else start = 0;
            case(index)
                0: pixel = pixel_in[i];
                1: pixel = pixel_in2[i];
                2: pixel = pixel_in3[i];
                default: pixel = 0;
            endcase

            case(index)
                0: depth = depth_in[i];
                1: depth = depth_in2[i];
                2: depth = depth_in3[i];
                default: depth = 0;
            endcase
            valid = 1;
            i = i+1;      
        end
        else if(o_ready) begin
            i = 0;
            index = index + 1;
            valid = 0;
        end

    end

    always@(posedge clk) begin
        if(index == 3) begin
            for(int j = golden_pos; j < end_pos; j = j+1) begin
                $display("Error(lack): (%h, %h, %h) <---> (%h, %h, %h)", golden_src_coor_x[j], golden_src_coor_y[j], golden_src_depth[j], golden_dst_coor_x[j], golden_dst_coor_y[j], golden_dst_depth[j]);
                $fwrite(f1, "Error(lack): (%h, %h, %h) <---> (%h, %h, %h)\n", golden_src_coor_x[j], golden_src_coor_y[j], golden_src_depth[j], golden_dst_coor_x[j], golden_dst_coor_y[j], golden_dst_depth[j]);
            end
            $display("end of checking");
            $fwrite(f1, "end of checking\n");
            $finish;
        end 

        if(o_valid) begin
            while(checking || check_again) begin
                same = compare(golden_src_coor_x[golden_pos], golden_src_coor_y[golden_pos], golden_src_depth[golden_pos], golden_dst_coor_x[golden_pos], golden_dst_coor_y[golden_pos], golden_dst_depth[golden_pos], o_src_coor_x, o_src_coor_y, o_src_depth, o_dst_coor_x, o_dst_coor_y, o_dst_depth);
                if(check_again == 0) begin
                    if(same) begin
                        $display("pass");
                        $fwrite(f1, "pass\n");
                        golden_pos = golden_pos + 1;
                        break;
                    end
                    else begin
                        // check forward, see if the coores would be found 
                        // (if so, means "lack")
                        // (if not, means "extra")                      
                        check_again = 1;
                        start_pos = golden_pos;
                        golden_pos = golden_pos + 1;
                        continue;
                    end
                end
                else begin
                    if(golden_pos == end_pos) begin // extra
                        $display("Error(extra): (%h, %h, %h) <---> (%h, %h, %h)", o_src_coor_x, o_src_coor_y, o_src_depth, o_dst_coor_x, o_dst_coor_y, o_dst_depth);
                        $fwrite(f1, "Error(extra): (%h, %h, %h) <---> (%h, %h, %h)\n", o_src_coor_x, o_src_coor_y, o_src_depth, o_dst_coor_x, o_dst_coor_y, o_dst_depth);
                        golden_pos = start_pos;
                        check_again = 0;
                        break;
                    end
                    else if(same) begin // lack
                        for(int j = start_pos; j < golden_pos; j = j+1) begin
                            $display("Error(lack): (%h, %h, %h) <---> (%h, %h, %h)", golden_src_coor_x[j], golden_src_coor_y[j], golden_src_depth[j], golden_dst_coor_x[j], golden_dst_coor_y[j], golden_dst_depth[j]);
                            $fwrite(f1, "Error(lack): (%h, %h, %h) <---> (%h, %h, %h)\n", golden_src_coor_x[j], golden_src_coor_y[j], golden_src_depth[j], golden_dst_coor_x[j], golden_dst_coor_y[j], golden_dst_depth[j]);
                        end
                        $display("pass");
                        $fwrite(f1, "pass\n");
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

    always@(posedge clk) begin
        // if(inspect_flag) begin
        //     $display("keypoint found: %h %h %h %h %h \n", inspect_coordinate_X, inspect_coordinate_Y, inspect_score, inspect_descriptor, inspect_depth);
        //     // $fwrite(f2, "%h %h %h %h %h \n", inspect_coordinate_X, inspect_coordinate_Y, inspect_score, inspect_descriptor, inspect_depth);
        // end
        if(o_frame_start) begin
            $display("frame start");
            $fwrite(f3, "frame start\n");
        end
        if(o_frame_end) begin
            $display("frame end");
            $fwrite(f3, "frame end\n");
        end
        if(o_valid) begin
            // $display("(%h, %h, %h) <---> (%h, %h, %h)", o_src_coor_x, o_src_coor_y, o_src_depth, o_dst_coor_x, o_dst_coor_y, o_dst_depth);
            $fwrite(f3, "(%h, %h, %h) <---> (%h, %h, %h)\n", o_src_coor_x, o_src_coor_y, o_src_depth, o_dst_coor_x, o_dst_coor_y, o_dst_depth);
        end
    end

endmodule