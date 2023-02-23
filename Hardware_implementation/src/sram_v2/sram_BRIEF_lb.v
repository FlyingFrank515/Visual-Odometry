/* FE Release Version: 3.4.22 */
/* lang compiler Version: 3.0.4 */
//
//       CONFIDENTIAL AND PROPRIETARY SOFTWARE OF ARM PHYSICAL IP, INC.
//      
//       Copyright (c) 1993 - 2022 ARM Physical IP, Inc.  All Rights Reserved.
//      
//       Use of this Software is subject to the terms and conditions of the
//       applicable license agreement with ARM Physical IP, Inc.
//       In addition, this Software is protected by patents, copyright law 
//       and international treaties.
//      
//       The copyright notice(s) in this Software does not indicate actual or
//       intended publication of this Software.
//
//      Verilog model for Synchronous Dual-Port Ram
//
//       Instance Name:              sram_BRIEF_lb
//       Words:                      640
//       Bits:                       8
//       Mux:                        16
//       Drive:                      6
//       Write Mask:                 Off
//       Write Thru:                 Off
//       Extra Margin Adjustment:    On
//       Redundant Rows:             0
//       Redundant Columns:          0
//       Test Muxes                  On
//       Power Gating:               Off
//       Retention:                  On
//       Pipeline:                   Off
//       Weak Bit Test:	        Off
//       Read Disturb Test:	        Off
//       
//       Creation Date:  Wed Oct 12 20:44:50 2022
//       Version: 	r5p0
//
//      Modeling Assumptions: This model supports full gate level simulation
//          including proper x-handling and timing check behavior.  Unit
//          delay timing is included in the model. Back-annotation of SDF
//          (v3.0 or v2.1) is supported.  SDF can be created utilyzing the delay
//          calculation views provided with this generator and supported
//          delay calculators.  All buses are modeled [MSB:LSB].  All 
//          ports are padded with Verilog primitives.
//
//      Modeling Limitations: None.
//
//      Known Bugs: None.
//
//      Known Work Arounds: N/A
//
`timescale 1 ns/1 ps
// If ARM_UD_MODEL is defined at Simulator Command Line, it Selects the BRIEF Functional Model
`ifdef ARM_UD_MODEL
`define ARM_UD_MODEL
// Following parameter Values can be overridden at Simulator Command Line.

// ARM_UD_DP Defines the delay through Data Paths, for Memory Models it represents BIST MUX output delays.
`ifdef ARM_UD_DP
`else
`define ARM_UD_DP #0.001
`endif
// ARM_UD_CP Defines the delay through Clock Path Cells, for Memory Models it is not used.
`ifdef ARM_UD_CP
`else
`define ARM_UD_CP
`endif
// ARM_UD_SEQ Defines the delay through the Memory, for Memory Models it is used for CLK->Q delays.
`ifdef ARM_UD_SEQ
`else
`define ARM_UD_SEQ #0.01
`endif

// `celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module sram_BRIEF_lb (VDDCE, VDDPE, VSSE, CENYA, WENYA, AYA, DYA, CENYB, WENYB, AYB,
    DYB, QA, QB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB, AB, DB, EMAA, EMAWA, EMASA,
    EMAB, EMAWB, EMASB, TENA, BENA, TCENA, TWENA, TAA, TDA, TQA, TENB, BENB, TCENB,
    TWENB, TAB, TDB, TQB, RET1N, STOVA, STOVB, COLLDISN);
`else
module sram_BRIEF_lb (CENYA, WENYA, AYA, DYA, CENYB, WENYB, AYB, DYB, QA, QB, CLKA, CENA,
    WENA, AA, DA, CLKB, CENB, WENB, AB, DB, EMAA, EMAWA, EMASA, EMAB, EMAWB, EMASB,
    TENA, BENA, TCENA, TWENA, TAA, TDA, TQA, TENB, BENB, TCENB, TWENB, TAB, TDB, TQB,
    RET1N, STOVA, STOVB, COLLDISN);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 8;
  parameter WORDS = 640;
  parameter MUX = 16;
  parameter MEM_WIDTH = 128; // redun block size 4, 64 on left, 64 on right
  parameter MEM_HEIGHT = 40;
  parameter WP_SIZE = 8 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

  output  CENYA;
  output  WENYA;
  output [9:0] AYA;
  output [7:0] DYA;
  output  CENYB;
  output  WENYB;
  output [9:0] AYB;
  output [7:0] DYB;
  output [7:0] QA;
  output [7:0] QB;
  input  CLKA;
  input  CENA;
  input  WENA;
  input [9:0] AA;
  input [7:0] DA;
  input  CLKB;
  input  CENB;
  input  WENB;
  input [9:0] AB;
  input [7:0] DB;
  input [2:0] EMAA;
  input [1:0] EMAWA;
  input  EMASA;
  input [2:0] EMAB;
  input [1:0] EMAWB;
  input  EMASB;
  input  TENA;
  input  BENA;
  input  TCENA;
  input  TWENA;
  input [9:0] TAA;
  input [7:0] TDA;
  input [7:0] TQA;
  input  TENB;
  input  BENB;
  input  TCENB;
  input  TWENB;
  input [9:0] TAB;
  input [7:0] TDB;
  input [7:0] TQB;
  input  RET1N;
  input  STOVA;
  input  STOVB;
  input  COLLDISN;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif

  integer row_address;
  integer mux_address;
  reg [127:0] mem [0:39];
  reg [127:0] row;
  reg LAST_CLKA;
  reg [127:0] row_mask;
  reg [127:0] new_data;
  reg [127:0] data_out;
  reg [31:0] readLatch0;
  reg [31:0] shifted_readLatch0;
  reg [1:0] read_mux_sel0;
  reg [31:0] readLatch1;
  reg [31:0] shifted_readLatch1;
  reg [1:0] read_mux_sel1;
  reg LAST_CLKB;
  reg [7:0] QA_int;
  reg [7:0] QA_int_delayed;
  reg [7:0] QB_int;
  reg [7:0] QB_int_delayed;
  reg [7:0] writeEnable;
  real previous_CLKA;
  real previous_CLKB;
  initial previous_CLKA = 0;
  initial previous_CLKB = 0;
  reg READ_WRITE, WRITE_WRITE, READ_READ, ROW_CC, COL_CC;
  reg READ_WRITE_1, WRITE_WRITE_1, READ_READ_1;
  reg  cont_flag0_int;
  reg  cont_flag1_int;
  initial cont_flag0_int = 1'b0;
  initial cont_flag1_int = 1'b0;

  reg NOT_CENA, NOT_WENA, NOT_AA9, NOT_AA8, NOT_AA7, NOT_AA6, NOT_AA5, NOT_AA4, NOT_AA3;
  reg NOT_AA2, NOT_AA1, NOT_AA0, NOT_DA7, NOT_DA6, NOT_DA5, NOT_DA4, NOT_DA3, NOT_DA2;
  reg NOT_DA1, NOT_DA0, NOT_CENB, NOT_WENB, NOT_AB9, NOT_AB8, NOT_AB7, NOT_AB6, NOT_AB5;
  reg NOT_AB4, NOT_AB3, NOT_AB2, NOT_AB1, NOT_AB0, NOT_DB7, NOT_DB6, NOT_DB5, NOT_DB4;
  reg NOT_DB3, NOT_DB2, NOT_DB1, NOT_DB0, NOT_EMAA2, NOT_EMAA1, NOT_EMAA0, NOT_EMAWA1;
  reg NOT_EMAWA0, NOT_EMASA, NOT_EMAB2, NOT_EMAB1, NOT_EMAB0, NOT_EMAWB1, NOT_EMAWB0;
  reg NOT_EMASB, NOT_TENA, NOT_TCENA, NOT_TWENA, NOT_TAA9, NOT_TAA8, NOT_TAA7, NOT_TAA6;
  reg NOT_TAA5, NOT_TAA4, NOT_TAA3, NOT_TAA2, NOT_TAA1, NOT_TAA0, NOT_TDA7, NOT_TDA6;
  reg NOT_TDA5, NOT_TDA4, NOT_TDA3, NOT_TDA2, NOT_TDA1, NOT_TDA0, NOT_TENB, NOT_TCENB;
  reg NOT_TWENB, NOT_TAB9, NOT_TAB8, NOT_TAB7, NOT_TAB6, NOT_TAB5, NOT_TAB4, NOT_TAB3;
  reg NOT_TAB2, NOT_TAB1, NOT_TAB0, NOT_TDB7, NOT_TDB6, NOT_TDB5, NOT_TDB4, NOT_TDB3;
  reg NOT_TDB2, NOT_TDB1, NOT_TDB0, NOT_RET1N, NOT_STOVA, NOT_STOVB, NOT_COLLDISN;
  reg NOT_CONTA, NOT_CLKA_PER, NOT_CLKA_MINH, NOT_CLKA_MINL, NOT_CONTB, NOT_CLKB_PER;
  reg NOT_CLKB_MINH, NOT_CLKB_MINL;
  reg clk0_int;
  reg clk1_int;

  wire  CENYA_;
  wire  WENYA_;
  wire [9:0] AYA_;
  wire [7:0] DYA_;
  wire  CENYB_;
  wire  WENYB_;
  wire [9:0] AYB_;
  wire [7:0] DYB_;
  wire [7:0] QA_;
  wire [7:0] QB_;
 wire  CLKA_;
  wire  CENA_;
  reg  CENA_int;
  reg  CENA_p2;
  wire  WENA_;
  reg  WENA_int;
  wire [9:0] AA_;
  reg [9:0] AA_int;
  wire [7:0] DA_;
  reg [7:0] DA_int;
 wire  CLKB_;
  wire  CENB_;
  reg  CENB_int;
  reg  CENB_p2;
  wire  WENB_;
  reg  WENB_int;
  wire [9:0] AB_;
  reg [9:0] AB_int;
  wire [7:0] DB_;
  reg [7:0] DB_int;
  wire [2:0] EMAA_;
  reg [2:0] EMAA_int;
  wire [1:0] EMAWA_;
  reg [1:0] EMAWA_int;
  wire  EMASA_;
  reg  EMASA_int;
  wire [2:0] EMAB_;
  reg [2:0] EMAB_int;
  wire [1:0] EMAWB_;
  reg [1:0] EMAWB_int;
  wire  EMASB_;
  reg  EMASB_int;
  wire  TENA_;
  reg  TENA_int;
  wire  BENA_;
  reg  BENA_int;
  wire  TCENA_;
  reg  TCENA_int;
  reg  TCENA_p2;
  wire  TWENA_;
  reg  TWENA_int;
  wire [9:0] TAA_;
  reg [9:0] TAA_int;
  wire [7:0] TDA_;
  reg [7:0] TDA_int;
  wire [7:0] TQA_;
  reg [7:0] TQA_int;
  wire  TENB_;
  reg  TENB_int;
  wire  BENB_;
  reg  BENB_int;
  wire  TCENB_;
  reg  TCENB_int;
  reg  TCENB_p2;
  wire  TWENB_;
  reg  TWENB_int;
  wire [9:0] TAB_;
  reg [9:0] TAB_int;
  wire [7:0] TDB_;
  reg [7:0] TDB_int;
  wire [7:0] TQB_;
  reg [7:0] TQB_int;
  wire  RET1N_;
  reg  RET1N_int;
  wire  STOVA_;
  reg  STOVA_int;
  wire  STOVB_;
  reg  STOVB_int;
  wire  COLLDISN_;
  reg  COLLDISN_int;

  assign CENYA = CENYA_; 
  assign WENYA = WENYA_; 
  assign AYA[0] = AYA_[0]; 
  assign AYA[1] = AYA_[1]; 
  assign AYA[2] = AYA_[2]; 
  assign AYA[3] = AYA_[3]; 
  assign AYA[4] = AYA_[4]; 
  assign AYA[5] = AYA_[5]; 
  assign AYA[6] = AYA_[6]; 
  assign AYA[7] = AYA_[7]; 
  assign AYA[8] = AYA_[8]; 
  assign AYA[9] = AYA_[9]; 
  assign DYA[0] = DYA_[0]; 
  assign DYA[1] = DYA_[1]; 
  assign DYA[2] = DYA_[2]; 
  assign DYA[3] = DYA_[3]; 
  assign DYA[4] = DYA_[4]; 
  assign DYA[5] = DYA_[5]; 
  assign DYA[6] = DYA_[6]; 
  assign DYA[7] = DYA_[7]; 
  assign CENYB = CENYB_; 
  assign WENYB = WENYB_; 
  assign AYB[0] = AYB_[0]; 
  assign AYB[1] = AYB_[1]; 
  assign AYB[2] = AYB_[2]; 
  assign AYB[3] = AYB_[3]; 
  assign AYB[4] = AYB_[4]; 
  assign AYB[5] = AYB_[5]; 
  assign AYB[6] = AYB_[6]; 
  assign AYB[7] = AYB_[7]; 
  assign AYB[8] = AYB_[8]; 
  assign AYB[9] = AYB_[9]; 
  assign DYB[0] = DYB_[0]; 
  assign DYB[1] = DYB_[1]; 
  assign DYB[2] = DYB_[2]; 
  assign DYB[3] = DYB_[3]; 
  assign DYB[4] = DYB_[4]; 
  assign DYB[5] = DYB_[5]; 
  assign DYB[6] = DYB_[6]; 
  assign DYB[7] = DYB_[7]; 
  assign QA[0] = QA_[0]; 
  assign QA[1] = QA_[1]; 
  assign QA[2] = QA_[2]; 
  assign QA[3] = QA_[3]; 
  assign QA[4] = QA_[4]; 
  assign QA[5] = QA_[5]; 
  assign QA[6] = QA_[6]; 
  assign QA[7] = QA_[7]; 
  assign QB[0] = QB_[0]; 
  assign QB[1] = QB_[1]; 
  assign QB[2] = QB_[2]; 
  assign QB[3] = QB_[3]; 
  assign QB[4] = QB_[4]; 
  assign QB[5] = QB_[5]; 
  assign QB[6] = QB_[6]; 
  assign QB[7] = QB_[7]; 
  assign CLKA_ = CLKA;
  assign CENA_ = CENA;
  assign WENA_ = WENA;
  assign AA_[0] = AA[0];
  assign AA_[1] = AA[1];
  assign AA_[2] = AA[2];
  assign AA_[3] = AA[3];
  assign AA_[4] = AA[4];
  assign AA_[5] = AA[5];
  assign AA_[6] = AA[6];
  assign AA_[7] = AA[7];
  assign AA_[8] = AA[8];
  assign AA_[9] = AA[9];
  assign DA_[0] = DA[0];
  assign DA_[1] = DA[1];
  assign DA_[2] = DA[2];
  assign DA_[3] = DA[3];
  assign DA_[4] = DA[4];
  assign DA_[5] = DA[5];
  assign DA_[6] = DA[6];
  assign DA_[7] = DA[7];
  assign CLKB_ = CLKB;
  assign CENB_ = CENB;
  assign WENB_ = WENB;
  assign AB_[0] = AB[0];
  assign AB_[1] = AB[1];
  assign AB_[2] = AB[2];
  assign AB_[3] = AB[3];
  assign AB_[4] = AB[4];
  assign AB_[5] = AB[5];
  assign AB_[6] = AB[6];
  assign AB_[7] = AB[7];
  assign AB_[8] = AB[8];
  assign AB_[9] = AB[9];
  assign DB_[0] = DB[0];
  assign DB_[1] = DB[1];
  assign DB_[2] = DB[2];
  assign DB_[3] = DB[3];
  assign DB_[4] = DB[4];
  assign DB_[5] = DB[5];
  assign DB_[6] = DB[6];
  assign DB_[7] = DB[7];
  assign EMAA_[0] = EMAA[0];
  assign EMAA_[1] = EMAA[1];
  assign EMAA_[2] = EMAA[2];
  assign EMAWA_[0] = EMAWA[0];
  assign EMAWA_[1] = EMAWA[1];
  assign EMASA_ = EMASA;
  assign EMAB_[0] = EMAB[0];
  assign EMAB_[1] = EMAB[1];
  assign EMAB_[2] = EMAB[2];
  assign EMAWB_[0] = EMAWB[0];
  assign EMAWB_[1] = EMAWB[1];
  assign EMASB_ = EMASB;
  assign TENA_ = TENA;
  assign BENA_ = BENA;
  assign TCENA_ = TCENA;
  assign TWENA_ = TWENA;
  assign TAA_[0] = TAA[0];
  assign TAA_[1] = TAA[1];
  assign TAA_[2] = TAA[2];
  assign TAA_[3] = TAA[3];
  assign TAA_[4] = TAA[4];
  assign TAA_[5] = TAA[5];
  assign TAA_[6] = TAA[6];
  assign TAA_[7] = TAA[7];
  assign TAA_[8] = TAA[8];
  assign TAA_[9] = TAA[9];
  assign TDA_[0] = TDA[0];
  assign TDA_[1] = TDA[1];
  assign TDA_[2] = TDA[2];
  assign TDA_[3] = TDA[3];
  assign TDA_[4] = TDA[4];
  assign TDA_[5] = TDA[5];
  assign TDA_[6] = TDA[6];
  assign TDA_[7] = TDA[7];
  assign TQA_[0] = TQA[0];
  assign TQA_[1] = TQA[1];
  assign TQA_[2] = TQA[2];
  assign TQA_[3] = TQA[3];
  assign TQA_[4] = TQA[4];
  assign TQA_[5] = TQA[5];
  assign TQA_[6] = TQA[6];
  assign TQA_[7] = TQA[7];
  assign TENB_ = TENB;
  assign BENB_ = BENB;
  assign TCENB_ = TCENB;
  assign TWENB_ = TWENB;
  assign TAB_[0] = TAB[0];
  assign TAB_[1] = TAB[1];
  assign TAB_[2] = TAB[2];
  assign TAB_[3] = TAB[3];
  assign TAB_[4] = TAB[4];
  assign TAB_[5] = TAB[5];
  assign TAB_[6] = TAB[6];
  assign TAB_[7] = TAB[7];
  assign TAB_[8] = TAB[8];
  assign TAB_[9] = TAB[9];
  assign TDB_[0] = TDB[0];
  assign TDB_[1] = TDB[1];
  assign TDB_[2] = TDB[2];
  assign TDB_[3] = TDB[3];
  assign TDB_[4] = TDB[4];
  assign TDB_[5] = TDB[5];
  assign TDB_[6] = TDB[6];
  assign TDB_[7] = TDB[7];
  assign TQB_[0] = TQB[0];
  assign TQB_[1] = TQB[1];
  assign TQB_[2] = TQB[2];
  assign TQB_[3] = TQB[3];
  assign TQB_[4] = TQB[4];
  assign TQB_[5] = TQB[5];
  assign TQB_[6] = TQB[6];
  assign TQB_[7] = TQB[7];
  assign RET1N_ = RET1N;
  assign STOVA_ = STOVA;
  assign STOVB_ = STOVB;
  assign COLLDISN_ = COLLDISN;

  assign `ARM_UD_DP CENYA_ = RET1N_ ? (TENA_ ? CENA_ : TCENA_) : 1'bx;
  assign `ARM_UD_DP WENYA_ = RET1N_ ? (TENA_ ? WENA_ : TWENA_) : 1'bx;
  assign `ARM_UD_DP AYA_ = RET1N_ ? (TENA_ ? AA_ : TAA_) : {10{1'bx}};
  assign `ARM_UD_DP DYA_ = RET1N_ ? (TENA_ ? DA_ : TDA_) : {8{1'bx}};
  assign `ARM_UD_DP CENYB_ = RET1N_ ? (TENB_ ? CENB_ : TCENB_) : 1'bx;
  assign `ARM_UD_DP WENYB_ = RET1N_ ? (TENB_ ? WENB_ : TWENB_) : 1'bx;
  assign `ARM_UD_DP AYB_ = RET1N_ ? (TENB_ ? AB_ : TAB_) : {10{1'bx}};
  assign `ARM_UD_DP DYB_ = RET1N_ ? (TENB_ ? DB_ : TDB_) : {8{1'bx}};
  assign `ARM_UD_SEQ QA_ = RET1N_ ? (BENA_ ? ((STOVA_ ? (QA_int_delayed) : (QA_int))) : TQA_) : {8{1'bx}};
  assign `ARM_UD_SEQ QB_ = RET1N_ ? (BENB_ ? ((STOVB_ ? (QB_int_delayed) : (QB_int))) : TQB_) : {8{1'bx}};

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
`endif

  task failedWrite;
  input port_f;
  integer i;
  begin
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'bx}};
  end
  endtask

  function isBitX;
    input bitval;
    begin
      isBitX = ( bitval===1'bx || bitval==1'bz ) ? 1'b1 : 1'b0;
    end
  endfunction


task loadmem;
	input [1000*8-1:0] filename;
	reg [BITS-1:0] memld [0:WORDS-1];
	integer i;
	reg [BITS-1:0] wordtemp;
	reg [9:0] Atemp;
  begin
	$readmemb(filename, memld);
     if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 4'b1111);
      row_address = (Atemp >> 4);
      row = mem[row_address];
        writeEnable = {8{1'b1}};
        row_mask =  ( {15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, wordtemp[7], 15'b000000000000000, wordtemp[6],
          15'b000000000000000, wordtemp[5], 15'b000000000000000, wordtemp[4], 15'b000000000000000, wordtemp[3],
          15'b000000000000000, wordtemp[2], 15'b000000000000000, wordtemp[1], 15'b000000000000000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
  	end
  end
  end
  endtask

task dumpmem;
	input [1000*8-1:0] filename_dump;
	integer i, dump_file_desc;
	reg [BITS-1:0] wordtemp;
	reg [9:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
     if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 4'b1111);
      row_address = (Atemp >> 4);
      row = mem[row_address];
        writeEnable = {8{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[124], data_out[120], data_out[116], data_out[112], data_out[108],
          data_out[104], data_out[100], data_out[96], data_out[92], data_out[88], data_out[84],
          data_out[80], data_out[76], data_out[72], data_out[68], data_out[64], data_out[60],
          data_out[56], data_out[52], data_out[48], data_out[44], data_out[40], data_out[36],
          data_out[32], data_out[28], data_out[24], data_out[20], data_out[16], data_out[12],
          data_out[8], data_out[4], data_out[0]};
      shifted_readLatch0 = readLatch0;
      QA_int = {shifted_readLatch0[28], shifted_readLatch0[24], shifted_readLatch0[20],
        shifted_readLatch0[16], shifted_readLatch0[12], shifted_readLatch0[8], shifted_readLatch0[4],
        shifted_readLatch0[0]};
   	$fdisplay(dump_file_desc, "%b", QA_int);
  end
  	end
//    $fclose(filename_dump);
  end
  endtask


  task readWriteA;
  begin
    if (RET1N_int === 1'bx || RET1N_int === 1'bz) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end else if (RET1N_int === 1'b0 && CENA_int === 1'b0) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end else if (RET1N_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{CENA_int, EMAA_int, EMAWA_int, EMASA_int, RET1N_int, (STOVA_int 
     && !CENA_int)} === 1'bx) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end else if ((AA_int >= WORDS) && (CENA_int === 1'b0)) begin
      QA_int = WENA_int !== 1'b1 ? QA_int : {8{1'bx}};
      QA_int_delayed = WENA_int !== 1'b1 ? QA_int_delayed : {8{1'bx}};
    end else if (CENA_int === 1'b0 && (^AA_int) === 1'bx) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end else if (CENA_int === 1'b0) begin
      mux_address = (AA_int & 4'b1111);
      row_address = (AA_int >> 4);
      if (row_address > 39)
        row = {128{1'bx}};
      else
        row = mem[row_address];
      writeEnable = ~{8{WENA_int}};
      if (WENA_int !== 1'b1) begin
        row_mask =  ( {15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, DA_int[7], 15'b000000000000000, DA_int[6],
          15'b000000000000000, DA_int[5], 15'b000000000000000, DA_int[4], 15'b000000000000000, DA_int[3],
          15'b000000000000000, DA_int[2], 15'b000000000000000, DA_int[1], 15'b000000000000000, DA_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch0 = {data_out[124], data_out[120], data_out[116], data_out[112], data_out[108],
          data_out[104], data_out[100], data_out[96], data_out[92], data_out[88], data_out[84],
          data_out[80], data_out[76], data_out[72], data_out[68], data_out[64], data_out[60],
          data_out[56], data_out[52], data_out[48], data_out[44], data_out[40], data_out[36],
          data_out[32], data_out[28], data_out[24], data_out[20], data_out[16], data_out[12],
          data_out[8], data_out[4], data_out[0]};
      shifted_readLatch0 = (readLatch0 >> AA_int[3:2]);
      QA_int = {shifted_readLatch0[28], shifted_readLatch0[24], shifted_readLatch0[20],
        shifted_readLatch0[16], shifted_readLatch0[12], shifted_readLatch0[8], shifted_readLatch0[4],
        shifted_readLatch0[0]};
      end
    end
  end
  endtask
  always @ (CENA_ or TCENA_ or TENA_ or CLKA_) begin
  	if(CLKA_ == 1'b0) begin
  		CENA_p2 = CENA_;
  		TCENA_p2 = TCENA_;
  	end
  end

  always @ RET1N_ begin
    if (CLKA_ == 1'b1) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end
    if (RET1N_ === 1'bx || RET1N_ === 1'bz) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end else if (RET1N_ === 1'b0 && RET1N_int === 1'b1 && (CENA_p2 === 1'b0 || TCENA_p2 === 1'b0) ) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end else if (RET1N_ === 1'b1 && RET1N_int === 1'b0 && (CENA_p2 === 1'b0 || TCENA_p2 === 1'b0) ) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end
    if (RET1N_ == 1'b0) begin
      QA_int = {8{1'bx}};
      QA_int_delayed = {8{1'bx}};
      CENA_int = 1'bx;
      WENA_int = 1'bx;
      AA_int = {10{1'bx}};
      DA_int = {8{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      BENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = 1'bx;
      TAA_int = {10{1'bx}};
      TDA_int = {8{1'bx}};
      TQA_int = {8{1'bx}};
      RET1N_int = 1'bx;
      STOVA_int = 1'bx;
      COLLDISN_int = 1'bx;
    end else begin
      QA_int = {8{1'bx}};
      QA_int_delayed = {8{1'bx}};
      CENA_int = 1'bx;
      WENA_int = 1'bx;
      AA_int = {10{1'bx}};
      DA_int = {8{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      BENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = 1'bx;
      TAA_int = {10{1'bx}};
      TDA_int = {8{1'bx}};
      TQA_int = {8{1'bx}};
      RET1N_int = 1'bx;
      STOVA_int = 1'bx;
      COLLDISN_int = 1'bx;
    end
    RET1N_int = RET1N_;
  end


  always @ CLKA_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("ERROR: Illegal value for VDDCE %b", VDDCE);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("ERROR: Illegal value for VDDPE %b", VDDPE);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("ERROR: Illegal value for VSSE %b", VSSE);
`endif
  if (RET1N_ == 1'b0) begin
      // no cycle in retention mode
  end else begin
    if ((CLKA_ === 1'bx || CLKA_ === 1'bz) && RET1N_ !== 1'b0) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end else if (CLKA_ === 1'b1 && LAST_CLKA === 1'b0) begin
      CENA_int = TENA_ ? CENA_ : TCENA_;
      EMAA_int = EMAA_;
      EMAWA_int = EMAWA_;
      EMASA_int = EMASA_;
      TENA_int = TENA_;
      BENA_int = BENA_;
      TWENA_int = TWENA_;
      TQA_int = TQA_;
      RET1N_int = RET1N_;
      STOVA_int = STOVA_;
      COLLDISN_int = COLLDISN_;
      if (CENA_int != 1'b1) begin
        WENA_int = TENA_ ? WENA_ : TWENA_;
        AA_int = TENA_ ? AA_ : TAA_;
        DA_int = TENA_ ? DA_ : TDA_;
        TCENA_int = TCENA_;
        TAA_int = TAA_;
        TDA_int = TDA_;
        if (WENA_int === 1'b1)
          read_mux_sel0 = (TENA_ ? AA_[3:2] : TAA_[3:2] );
      end
      clk0_int = 1'b0;
      if (CENA_int === 1'b0 && WENA_int === 1'b1) 
         QA_int_delayed = {8{1'bx}};
      if (CENA_int === 1'b0) previous_CLKA = $realtime;
    readWriteA;
    #0;
      if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && COLLDISN_int === 1'b1 && row_contention(AA_int, AB_int,  WENA_int, WENB_int)) 
       begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          DA_int = {8{1'bx}};
          readWriteA;
          DB_int = {8{1'bx}};
          readWriteB;
	      end
        end else if (WENA_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QB_int = {8{1'bx}};
		end
        end else if (WENB_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QA_int = {8{1'bx}};
		end
        end else begin
          readWriteB;
          readWriteA;
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_READ = 1;
        end
		if (!is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          readWriteB;
          readWriteA;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE = 1;
        end else if (!(WENA_int !== 1'b1) && (WENB_int !== 1'b1)) begin
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else if ((WENA_int !== 1'b1) && !(WENB_int !== 1'b1)) begin
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else begin
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
        end
        end
      end else if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && (COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx)  && row_contention(AA_int,
        AB_int,  WENA_int, WENB_int)) begin
          $display("%s row contention: in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (WENB_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DB_int = {8{1'bx}};
          readWriteB;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
          QB_int = {8{1'bx}};
        end else begin
          readWriteB;
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE_1 = 1;
          READ_READ_1 = 1;
        end
        if (WENA_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DA_int = {8{1'bx}};
          readWriteA;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          QA_int = {8{1'bx}};
        end else begin
          readWriteA;
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (CLKA_ === 1'b0 && LAST_CLKA === 1'b1) begin
      QA_int_delayed = QA_int;
    end
    LAST_CLKA = CLKA_;
  end
  end

  task readWriteB;
  begin
    if (RET1N_int === 1'bx || RET1N_int === 1'bz) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end else if (RET1N_int === 1'b0 && CENB_int === 1'b0) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end else if (RET1N_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{CENB_int, EMAB_int, EMAWB_int, EMASB_int, RET1N_int, (STOVB_int 
     && !CENB_int)} === 1'bx) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end else if ((AB_int >= WORDS) && (CENB_int === 1'b0)) begin
      QB_int = WENB_int !== 1'b1 ? QB_int : {8{1'bx}};
      QB_int_delayed = WENB_int !== 1'b1 ? QB_int_delayed : {8{1'bx}};
    end else if (CENB_int === 1'b0 && (^AB_int) === 1'bx) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end else if (CENB_int === 1'b0) begin
      mux_address = (AB_int & 4'b1111);
      row_address = (AB_int >> 4);
      if (row_address > 39)
        row = {128{1'bx}};
      else
        row = mem[row_address];
      writeEnable = ~{8{WENB_int}};
      if (WENB_int !== 1'b1) begin
        row_mask =  ( {15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, DB_int[7], 15'b000000000000000, DB_int[6],
          15'b000000000000000, DB_int[5], 15'b000000000000000, DB_int[4], 15'b000000000000000, DB_int[3],
          15'b000000000000000, DB_int[2], 15'b000000000000000, DB_int[1], 15'b000000000000000, DB_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch1 = {data_out[124], data_out[120], data_out[116], data_out[112], data_out[108],
          data_out[104], data_out[100], data_out[96], data_out[92], data_out[88], data_out[84],
          data_out[80], data_out[76], data_out[72], data_out[68], data_out[64], data_out[60],
          data_out[56], data_out[52], data_out[48], data_out[44], data_out[40], data_out[36],
          data_out[32], data_out[28], data_out[24], data_out[20], data_out[16], data_out[12],
          data_out[8], data_out[4], data_out[0]};
      shifted_readLatch1 = (readLatch1 >> AB_int[3:2]);
      QB_int = {shifted_readLatch1[28], shifted_readLatch1[24], shifted_readLatch1[20],
        shifted_readLatch1[16], shifted_readLatch1[12], shifted_readLatch1[8], shifted_readLatch1[4],
        shifted_readLatch1[0]};
      end
    end
  end
  endtask
  always @ (CENB_ or TCENB_ or TENB_ or CLKB_) begin
  	if(CLKB_ == 1'b0) begin
  		CENB_p2 = CENB_;
  		TCENB_p2 = TCENB_;
  	end
  end

  always @ RET1N_ begin
    if (CLKB_ == 1'b1) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end
    if (RET1N_ === 1'bx || RET1N_ === 1'bz) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end else if (RET1N_ === 1'b0 && RET1N_int === 1'b1 && (CENB_p2 === 1'b0 || TCENB_p2 === 1'b0) ) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end else if (RET1N_ === 1'b1 && RET1N_int === 1'b0 && (CENB_p2 === 1'b0 || TCENB_p2 === 1'b0) ) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end
    if (RET1N_ == 1'b0) begin
      QB_int = {8{1'bx}};
      QB_int_delayed = {8{1'bx}};
      CENB_int = 1'bx;
      WENB_int = 1'bx;
      AB_int = {10{1'bx}};
      DB_int = {8{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      BENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = 1'bx;
      TAB_int = {10{1'bx}};
      TDB_int = {8{1'bx}};
      TQB_int = {8{1'bx}};
      RET1N_int = 1'bx;
      STOVB_int = 1'bx;
      COLLDISN_int = 1'bx;
    end else begin
      QB_int = {8{1'bx}};
      QB_int_delayed = {8{1'bx}};
      CENB_int = 1'bx;
      WENB_int = 1'bx;
      AB_int = {10{1'bx}};
      DB_int = {8{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      BENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = 1'bx;
      TAB_int = {10{1'bx}};
      TDB_int = {8{1'bx}};
      TQB_int = {8{1'bx}};
      RET1N_int = 1'bx;
      STOVB_int = 1'bx;
      COLLDISN_int = 1'bx;
    end
    RET1N_int = RET1N_;
  end


  always @ CLKB_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("ERROR: Illegal value for VDDCE %b", VDDCE);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("ERROR: Illegal value for VDDPE %b", VDDPE);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("ERROR: Illegal value for VSSE %b", VSSE);
`endif
  if (RET1N_ == 1'b0) begin
      // no cycle in retention mode
  end else begin
    if ((CLKB_ === 1'bx || CLKB_ === 1'bz) && RET1N_ !== 1'b0) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end else if (CLKB_ === 1'b1 && LAST_CLKB === 1'b0) begin
      CENB_int = TENB_ ? CENB_ : TCENB_;
      EMAB_int = EMAB_;
      EMAWB_int = EMAWB_;
      EMASB_int = EMASB_;
      TENB_int = TENB_;
      BENB_int = BENB_;
      TWENB_int = TWENB_;
      TQB_int = TQB_;
      RET1N_int = RET1N_;
      STOVB_int = STOVB_;
      COLLDISN_int = COLLDISN_;
      if (CENB_int != 1'b1) begin
        WENB_int = TENB_ ? WENB_ : TWENB_;
        AB_int = TENB_ ? AB_ : TAB_;
        DB_int = TENB_ ? DB_ : TDB_;
        TCENB_int = TCENB_;
        TAB_int = TAB_;
        TDB_int = TDB_;
        if (WENB_int === 1'b1)
          read_mux_sel1 = (TENB_ ? AB_[3:2] : TAB_[3:2] );
      end
      clk1_int = 1'b0;
      if (CENB_int === 1'b0 && WENB_int === 1'b1) 
         QB_int_delayed = {8{1'bx}};
      if (CENB_int === 1'b0) previous_CLKB = $realtime;
    readWriteB;
    #0;
      if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && COLLDISN_int === 1'b1 && row_contention(AA_int, AB_int,  WENA_int, WENB_int)) 
       begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          DA_int = {8{1'bx}};
          readWriteA;
          DB_int = {8{1'bx}};
          readWriteB;
	      end
        end else if (WENA_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QB_int = {8{1'bx}};
		end
        end else if (WENB_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QA_int = {8{1'bx}};
		end
        end else begin
          readWriteA;
          readWriteB;
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_READ = 1;
        end
		if (!is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          readWriteA;
          readWriteB;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE = 1;
        end else if (!(WENA_int !== 1'b1) && (WENB_int !== 1'b1)) begin
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else if ((WENA_int !== 1'b1) && !(WENB_int !== 1'b1)) begin
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else begin
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
        end
        end
      end else if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && (COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx)  && row_contention(AA_int,
        AB_int,  WENA_int, WENB_int)) begin
          $display("%s row contention: in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (WENA_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DA_int = {8{1'bx}};
          readWriteA;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
          QA_int = {8{1'bx}};
        end else begin
          readWriteA;
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_READ_1 = 1;
          READ_WRITE_1 = 1;
        end
        if (WENB_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DB_int = {8{1'bx}};
          readWriteB;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          QB_int = {8{1'bx}};
        end else begin
          readWriteB;
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (CLKB_ === 1'b0 && LAST_CLKB === 1'b1) begin
      QB_int_delayed = QB_int;
    end
    LAST_CLKB = CLKB_;
  end
  end

  function row_contention;
    input [9:0] aa;
    input [9:0] ab;
    input  wena;
    input  wenb;
    reg result;
    reg sameRow;
    reg sameMux;
    reg anyWrite;
  begin
    anyWrite = ((& wena) === 1'b1 && (& wenb) === 1'b1) ? 1'b0 : 1'b1;
    sameMux = (aa[3:0] == ab[3:0]) ? 1'b1 : 1'b0;
    if (aa[9:4] == ab[9:4]) begin
      sameRow = 1'b1;
    end else begin
      sameRow = 1'b0;
    end
    if (sameRow == 1'b1 && anyWrite == 1'b1)
      row_contention = 1'b1;
    else if (sameRow == 1'b1 && sameMux == 1'b1)
      row_contention = 1'b1;
    else
      row_contention = 1'b0;
  end
  endfunction

  function col_contention;
    input [9:0] aa;
    input [9:0] ab;
  begin
    if (aa[3:0] == ab[3:0])
      col_contention = 1'b1;
    else
      col_contention = 1'b0;
  end
  endfunction

  function is_contention;
    input [9:0] aa;
    input [9:0] ab;
    input  wena;
    input  wenb;
    reg result;
  begin
    if ((& wena) === 1'b1 && (& wenb) === 1'b1) begin
      result = 1'b0;
    end else if (aa == ab) begin
      result = 1'b1;
    end else begin
      result = 1'b0;
    end
    is_contention = result;
  end
  endfunction


endmodule
`endcelldefine
`else
`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module sram_BRIEF_lb (VDDCE, VDDPE, VSSE, CENYA, WENYA, AYA, DYA, CENYB, WENYB, AYB,
    DYB, QA, QB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB, AB, DB, EMAA, EMAWA, EMASA,
    EMAB, EMAWB, EMASB, TENA, BENA, TCENA, TWENA, TAA, TDA, TQA, TENB, BENB, TCENB,
    TWENB, TAB, TDB, TQB, RET1N, STOVA, STOVB, COLLDISN);
`else
module sram_BRIEF_lb (CENYA, WENYA, AYA, DYA, CENYB, WENYB, AYB, DYB, QA, QB, CLKA, CENA,
    WENA, AA, DA, CLKB, CENB, WENB, AB, DB, EMAA, EMAWA, EMASA, EMAB, EMAWB, EMASB,
    TENA, BENA, TCENA, TWENA, TAA, TDA, TQA, TENB, BENB, TCENB, TWENB, TAB, TDB, TQB,
    RET1N, STOVA, STOVB, COLLDISN);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 8;
  parameter WORDS = 640;
  parameter MUX = 16;
  parameter MEM_WIDTH = 128; // redun block size 4, 64 on left, 64 on right
  parameter MEM_HEIGHT = 40;
  parameter WP_SIZE = 8 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

  output  CENYA;
  output  WENYA;
  output [9:0] AYA;
  output [7:0] DYA;
  output  CENYB;
  output  WENYB;
  output [9:0] AYB;
  output [7:0] DYB;
  output [7:0] QA;
  output [7:0] QB;
  input  CLKA;
  input  CENA;
  input  WENA;
  input [9:0] AA;
  input [7:0] DA;
  input  CLKB;
  input  CENB;
  input  WENB;
  input [9:0] AB;
  input [7:0] DB;
  input [2:0] EMAA;
  input [1:0] EMAWA;
  input  EMASA;
  input [2:0] EMAB;
  input [1:0] EMAWB;
  input  EMASB;
  input  TENA;
  input  BENA;
  input  TCENA;
  input  TWENA;
  input [9:0] TAA;
  input [7:0] TDA;
  input [7:0] TQA;
  input  TENB;
  input  BENB;
  input  TCENB;
  input  TWENB;
  input [9:0] TAB;
  input [7:0] TDB;
  input [7:0] TQB;
  input  RET1N;
  input  STOVA;
  input  STOVB;
  input  COLLDISN;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif

  integer row_address;
  integer mux_address;
  reg [127:0] mem [0:39];
  reg [127:0] row;
  reg LAST_CLKA;
  reg [127:0] row_mask;
  reg [127:0] new_data;
  reg [127:0] data_out;
  reg [31:0] readLatch0;
  reg [31:0] shifted_readLatch0;
  reg [1:0] read_mux_sel0;
  reg [31:0] readLatch1;
  reg [31:0] shifted_readLatch1;
  reg [1:0] read_mux_sel1;
  reg LAST_CLKB;
  reg [7:0] QA_int;
  reg [7:0] QA_int_delayed;
  reg [7:0] QB_int;
  reg [7:0] QB_int_delayed;
  reg [7:0] writeEnable;
  real previous_CLKA;
  real previous_CLKB;
  initial previous_CLKA = 0;
  initial previous_CLKB = 0;
  reg READ_WRITE, WRITE_WRITE, READ_READ, ROW_CC, COL_CC;
  reg READ_WRITE_1, WRITE_WRITE_1, READ_READ_1;
  reg  cont_flag0_int;
  reg  cont_flag1_int;
  initial cont_flag0_int = 1'b0;
  initial cont_flag1_int = 1'b0;

  reg NOT_CENA, NOT_WENA, NOT_AA9, NOT_AA8, NOT_AA7, NOT_AA6, NOT_AA5, NOT_AA4, NOT_AA3;
  reg NOT_AA2, NOT_AA1, NOT_AA0, NOT_DA7, NOT_DA6, NOT_DA5, NOT_DA4, NOT_DA3, NOT_DA2;
  reg NOT_DA1, NOT_DA0, NOT_CENB, NOT_WENB, NOT_AB9, NOT_AB8, NOT_AB7, NOT_AB6, NOT_AB5;
  reg NOT_AB4, NOT_AB3, NOT_AB2, NOT_AB1, NOT_AB0, NOT_DB7, NOT_DB6, NOT_DB5, NOT_DB4;
  reg NOT_DB3, NOT_DB2, NOT_DB1, NOT_DB0, NOT_EMAA2, NOT_EMAA1, NOT_EMAA0, NOT_EMAWA1;
  reg NOT_EMAWA0, NOT_EMASA, NOT_EMAB2, NOT_EMAB1, NOT_EMAB0, NOT_EMAWB1, NOT_EMAWB0;
  reg NOT_EMASB, NOT_TENA, NOT_TCENA, NOT_TWENA, NOT_TAA9, NOT_TAA8, NOT_TAA7, NOT_TAA6;
  reg NOT_TAA5, NOT_TAA4, NOT_TAA3, NOT_TAA2, NOT_TAA1, NOT_TAA0, NOT_TDA7, NOT_TDA6;
  reg NOT_TDA5, NOT_TDA4, NOT_TDA3, NOT_TDA2, NOT_TDA1, NOT_TDA0, NOT_TENB, NOT_TCENB;
  reg NOT_TWENB, NOT_TAB9, NOT_TAB8, NOT_TAB7, NOT_TAB6, NOT_TAB5, NOT_TAB4, NOT_TAB3;
  reg NOT_TAB2, NOT_TAB1, NOT_TAB0, NOT_TDB7, NOT_TDB6, NOT_TDB5, NOT_TDB4, NOT_TDB3;
  reg NOT_TDB2, NOT_TDB1, NOT_TDB0, NOT_RET1N, NOT_STOVA, NOT_STOVB, NOT_COLLDISN;
  reg NOT_CONTA, NOT_CLKA_PER, NOT_CLKA_MINH, NOT_CLKA_MINL, NOT_CONTB, NOT_CLKB_PER;
  reg NOT_CLKB_MINH, NOT_CLKB_MINL;
  reg clk0_int;
  reg clk1_int;

  wire  CENYA_;
  wire  WENYA_;
  wire [9:0] AYA_;
  wire [7:0] DYA_;
  wire  CENYB_;
  wire  WENYB_;
  wire [9:0] AYB_;
  wire [7:0] DYB_;
  wire [7:0] QA_;
  wire [7:0] QB_;
 wire  CLKA_;
  wire  CENA_;
  reg  CENA_int;
  reg  CENA_p2;
  wire  WENA_;
  reg  WENA_int;
  wire [9:0] AA_;
  reg [9:0] AA_int;
  wire [7:0] DA_;
  reg [7:0] DA_int;
 wire  CLKB_;
  wire  CENB_;
  reg  CENB_int;
  reg  CENB_p2;
  wire  WENB_;
  reg  WENB_int;
  wire [9:0] AB_;
  reg [9:0] AB_int;
  wire [7:0] DB_;
  reg [7:0] DB_int;
  wire [2:0] EMAA_;
  reg [2:0] EMAA_int;
  wire [1:0] EMAWA_;
  reg [1:0] EMAWA_int;
  wire  EMASA_;
  reg  EMASA_int;
  wire [2:0] EMAB_;
  reg [2:0] EMAB_int;
  wire [1:0] EMAWB_;
  reg [1:0] EMAWB_int;
  wire  EMASB_;
  reg  EMASB_int;
  wire  TENA_;
  reg  TENA_int;
  wire  BENA_;
  reg  BENA_int;
  wire  TCENA_;
  reg  TCENA_int;
  reg  TCENA_p2;
  wire  TWENA_;
  reg  TWENA_int;
  wire [9:0] TAA_;
  reg [9:0] TAA_int;
  wire [7:0] TDA_;
  reg [7:0] TDA_int;
  wire [7:0] TQA_;
  reg [7:0] TQA_int;
  wire  TENB_;
  reg  TENB_int;
  wire  BENB_;
  reg  BENB_int;
  wire  TCENB_;
  reg  TCENB_int;
  reg  TCENB_p2;
  wire  TWENB_;
  reg  TWENB_int;
  wire [9:0] TAB_;
  reg [9:0] TAB_int;
  wire [7:0] TDB_;
  reg [7:0] TDB_int;
  wire [7:0] TQB_;
  reg [7:0] TQB_int;
  wire  RET1N_;
  reg  RET1N_int;
  wire  STOVA_;
  reg  STOVA_int;
  wire  STOVB_;
  reg  STOVB_int;
  wire  COLLDISN_;
  reg  COLLDISN_int;

  buf B0(CENYA, CENYA_);
  buf B1(WENYA, WENYA_);
  buf B2(AYA[0], AYA_[0]);
  buf B3(AYA[1], AYA_[1]);
  buf B4(AYA[2], AYA_[2]);
  buf B5(AYA[3], AYA_[3]);
  buf B6(AYA[4], AYA_[4]);
  buf B7(AYA[5], AYA_[5]);
  buf B8(AYA[6], AYA_[6]);
  buf B9(AYA[7], AYA_[7]);
  buf B10(AYA[8], AYA_[8]);
  buf B11(AYA[9], AYA_[9]);
  buf B12(DYA[0], DYA_[0]);
  buf B13(DYA[1], DYA_[1]);
  buf B14(DYA[2], DYA_[2]);
  buf B15(DYA[3], DYA_[3]);
  buf B16(DYA[4], DYA_[4]);
  buf B17(DYA[5], DYA_[5]);
  buf B18(DYA[6], DYA_[6]);
  buf B19(DYA[7], DYA_[7]);
  buf B20(CENYB, CENYB_);
  buf B21(WENYB, WENYB_);
  buf B22(AYB[0], AYB_[0]);
  buf B23(AYB[1], AYB_[1]);
  buf B24(AYB[2], AYB_[2]);
  buf B25(AYB[3], AYB_[3]);
  buf B26(AYB[4], AYB_[4]);
  buf B27(AYB[5], AYB_[5]);
  buf B28(AYB[6], AYB_[6]);
  buf B29(AYB[7], AYB_[7]);
  buf B30(AYB[8], AYB_[8]);
  buf B31(AYB[9], AYB_[9]);
  buf B32(DYB[0], DYB_[0]);
  buf B33(DYB[1], DYB_[1]);
  buf B34(DYB[2], DYB_[2]);
  buf B35(DYB[3], DYB_[3]);
  buf B36(DYB[4], DYB_[4]);
  buf B37(DYB[5], DYB_[5]);
  buf B38(DYB[6], DYB_[6]);
  buf B39(DYB[7], DYB_[7]);
  buf B40(QA[0], QA_[0]);
  buf B41(QA[1], QA_[1]);
  buf B42(QA[2], QA_[2]);
  buf B43(QA[3], QA_[3]);
  buf B44(QA[4], QA_[4]);
  buf B45(QA[5], QA_[5]);
  buf B46(QA[6], QA_[6]);
  buf B47(QA[7], QA_[7]);
  buf B48(QB[0], QB_[0]);
  buf B49(QB[1], QB_[1]);
  buf B50(QB[2], QB_[2]);
  buf B51(QB[3], QB_[3]);
  buf B52(QB[4], QB_[4]);
  buf B53(QB[5], QB_[5]);
  buf B54(QB[6], QB_[6]);
  buf B55(QB[7], QB_[7]);
  buf B56(CLKA_, CLKA);
  buf B57(CENA_, CENA);
  buf B58(WENA_, WENA);
  buf B59(AA_[0], AA[0]);
  buf B60(AA_[1], AA[1]);
  buf B61(AA_[2], AA[2]);
  buf B62(AA_[3], AA[3]);
  buf B63(AA_[4], AA[4]);
  buf B64(AA_[5], AA[5]);
  buf B65(AA_[6], AA[6]);
  buf B66(AA_[7], AA[7]);
  buf B67(AA_[8], AA[8]);
  buf B68(AA_[9], AA[9]);
  buf B69(DA_[0], DA[0]);
  buf B70(DA_[1], DA[1]);
  buf B71(DA_[2], DA[2]);
  buf B72(DA_[3], DA[3]);
  buf B73(DA_[4], DA[4]);
  buf B74(DA_[5], DA[5]);
  buf B75(DA_[6], DA[6]);
  buf B76(DA_[7], DA[7]);
  buf B77(CLKB_, CLKB);
  buf B78(CENB_, CENB);
  buf B79(WENB_, WENB);
  buf B80(AB_[0], AB[0]);
  buf B81(AB_[1], AB[1]);
  buf B82(AB_[2], AB[2]);
  buf B83(AB_[3], AB[3]);
  buf B84(AB_[4], AB[4]);
  buf B85(AB_[5], AB[5]);
  buf B86(AB_[6], AB[6]);
  buf B87(AB_[7], AB[7]);
  buf B88(AB_[8], AB[8]);
  buf B89(AB_[9], AB[9]);
  buf B90(DB_[0], DB[0]);
  buf B91(DB_[1], DB[1]);
  buf B92(DB_[2], DB[2]);
  buf B93(DB_[3], DB[3]);
  buf B94(DB_[4], DB[4]);
  buf B95(DB_[5], DB[5]);
  buf B96(DB_[6], DB[6]);
  buf B97(DB_[7], DB[7]);
  buf B98(EMAA_[0], EMAA[0]);
  buf B99(EMAA_[1], EMAA[1]);
  buf B100(EMAA_[2], EMAA[2]);
  buf B101(EMAWA_[0], EMAWA[0]);
  buf B102(EMAWA_[1], EMAWA[1]);
  buf B103(EMASA_, EMASA);
  buf B104(EMAB_[0], EMAB[0]);
  buf B105(EMAB_[1], EMAB[1]);
  buf B106(EMAB_[2], EMAB[2]);
  buf B107(EMAWB_[0], EMAWB[0]);
  buf B108(EMAWB_[1], EMAWB[1]);
  buf B109(EMASB_, EMASB);
  buf B110(TENA_, TENA);
  buf B111(BENA_, BENA);
  buf B112(TCENA_, TCENA);
  buf B113(TWENA_, TWENA);
  buf B114(TAA_[0], TAA[0]);
  buf B115(TAA_[1], TAA[1]);
  buf B116(TAA_[2], TAA[2]);
  buf B117(TAA_[3], TAA[3]);
  buf B118(TAA_[4], TAA[4]);
  buf B119(TAA_[5], TAA[5]);
  buf B120(TAA_[6], TAA[6]);
  buf B121(TAA_[7], TAA[7]);
  buf B122(TAA_[8], TAA[8]);
  buf B123(TAA_[9], TAA[9]);
  buf B124(TDA_[0], TDA[0]);
  buf B125(TDA_[1], TDA[1]);
  buf B126(TDA_[2], TDA[2]);
  buf B127(TDA_[3], TDA[3]);
  buf B128(TDA_[4], TDA[4]);
  buf B129(TDA_[5], TDA[5]);
  buf B130(TDA_[6], TDA[6]);
  buf B131(TDA_[7], TDA[7]);
  buf B132(TQA_[0], TQA[0]);
  buf B133(TQA_[1], TQA[1]);
  buf B134(TQA_[2], TQA[2]);
  buf B135(TQA_[3], TQA[3]);
  buf B136(TQA_[4], TQA[4]);
  buf B137(TQA_[5], TQA[5]);
  buf B138(TQA_[6], TQA[6]);
  buf B139(TQA_[7], TQA[7]);
  buf B140(TENB_, TENB);
  buf B141(BENB_, BENB);
  buf B142(TCENB_, TCENB);
  buf B143(TWENB_, TWENB);
  buf B144(TAB_[0], TAB[0]);
  buf B145(TAB_[1], TAB[1]);
  buf B146(TAB_[2], TAB[2]);
  buf B147(TAB_[3], TAB[3]);
  buf B148(TAB_[4], TAB[4]);
  buf B149(TAB_[5], TAB[5]);
  buf B150(TAB_[6], TAB[6]);
  buf B151(TAB_[7], TAB[7]);
  buf B152(TAB_[8], TAB[8]);
  buf B153(TAB_[9], TAB[9]);
  buf B154(TDB_[0], TDB[0]);
  buf B155(TDB_[1], TDB[1]);
  buf B156(TDB_[2], TDB[2]);
  buf B157(TDB_[3], TDB[3]);
  buf B158(TDB_[4], TDB[4]);
  buf B159(TDB_[5], TDB[5]);
  buf B160(TDB_[6], TDB[6]);
  buf B161(TDB_[7], TDB[7]);
  buf B162(TQB_[0], TQB[0]);
  buf B163(TQB_[1], TQB[1]);
  buf B164(TQB_[2], TQB[2]);
  buf B165(TQB_[3], TQB[3]);
  buf B166(TQB_[4], TQB[4]);
  buf B167(TQB_[5], TQB[5]);
  buf B168(TQB_[6], TQB[6]);
  buf B169(TQB_[7], TQB[7]);
  buf B170(RET1N_, RET1N);
  buf B171(STOVA_, STOVA);
  buf B172(STOVB_, STOVB);
  buf B173(COLLDISN_, COLLDISN);

  assign CENYA_ = RET1N_ ? (TENA_ ? CENA_ : TCENA_) : 1'bx;
  assign WENYA_ = RET1N_ ? (TENA_ ? WENA_ : TWENA_) : 1'bx;
  assign AYA_ = RET1N_ ? (TENA_ ? AA_ : TAA_) : {10{1'bx}};
  assign DYA_ = RET1N_ ? (TENA_ ? DA_ : TDA_) : {8{1'bx}};
  assign CENYB_ = RET1N_ ? (TENB_ ? CENB_ : TCENB_) : 1'bx;
  assign WENYB_ = RET1N_ ? (TENB_ ? WENB_ : TWENB_) : 1'bx;
  assign AYB_ = RET1N_ ? (TENB_ ? AB_ : TAB_) : {10{1'bx}};
  assign DYB_ = RET1N_ ? (TENB_ ? DB_ : TDB_) : {8{1'bx}};
   `ifdef ARM_FAULT_MODELING
     sram_BRIEF_lb_error_injection u1(.CLK(CLKA_), .Q_out(QA_), .A(AA_int), .CEN(CENA_int), .TQ(TQA_), .BEN(BENA_), .WEN(WENA_int), .Q_in(QA_int));
  `else
  assign QA_ = RET1N_ ? (BENA_ ? ((STOVA_ ? (QA_int_delayed) : (QA_int))) : TQA_) : {8{1'bx}};
  `endif
  assign QB_ = RET1N_ ? (BENB_ ? ((STOVB_ ? (QB_int_delayed) : (QB_int))) : TQB_) : {8{1'bx}};

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
`endif

  task failedWrite;
  input port_f;
  integer i;
  begin
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'bx}};
  end
  endtask

  function isBitX;
    input bitval;
    begin
      isBitX = ( bitval===1'bx || bitval==1'bz ) ? 1'b1 : 1'b0;
    end
  endfunction


task loadmem;
	input [1000*8-1:0] filename;
	reg [BITS-1:0] memld [0:WORDS-1];
	integer i;
	reg [BITS-1:0] wordtemp;
	reg [9:0] Atemp;
  begin
	$readmemb(filename, memld);
     if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 4'b1111);
      row_address = (Atemp >> 4);
      row = mem[row_address];
        writeEnable = {8{1'b1}};
        row_mask =  ( {15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, wordtemp[7], 15'b000000000000000, wordtemp[6],
          15'b000000000000000, wordtemp[5], 15'b000000000000000, wordtemp[4], 15'b000000000000000, wordtemp[3],
          15'b000000000000000, wordtemp[2], 15'b000000000000000, wordtemp[1], 15'b000000000000000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
  	end
  end
  end
  endtask

task dumpmem;
	input [1000*8-1:0] filename_dump;
	integer i, dump_file_desc;
	reg [BITS-1:0] wordtemp;
	reg [9:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
     if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 4'b1111);
      row_address = (Atemp >> 4);
      row = mem[row_address];
        writeEnable = {8{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[124], data_out[120], data_out[116], data_out[112], data_out[108],
          data_out[104], data_out[100], data_out[96], data_out[92], data_out[88], data_out[84],
          data_out[80], data_out[76], data_out[72], data_out[68], data_out[64], data_out[60],
          data_out[56], data_out[52], data_out[48], data_out[44], data_out[40], data_out[36],
          data_out[32], data_out[28], data_out[24], data_out[20], data_out[16], data_out[12],
          data_out[8], data_out[4], data_out[0]};
      shifted_readLatch0 = readLatch0;
      QA_int = {shifted_readLatch0[28], shifted_readLatch0[24], shifted_readLatch0[20],
        shifted_readLatch0[16], shifted_readLatch0[12], shifted_readLatch0[8], shifted_readLatch0[4],
        shifted_readLatch0[0]};
   	$fdisplay(dump_file_desc, "%b", QA_int);
  end
  	end
//    $fclose(filename_dump);
  end
  endtask


  task readWriteA;
  begin
    if (RET1N_int === 1'bx || RET1N_int === 1'bz) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end else if (RET1N_int === 1'b0 && CENA_int === 1'b0) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end else if (RET1N_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{CENA_int, EMAA_int, EMAWA_int, EMASA_int, RET1N_int, (STOVA_int 
     && !CENA_int)} === 1'bx) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end else if ((AA_int >= WORDS) && (CENA_int === 1'b0)) begin
      QA_int = WENA_int !== 1'b1 ? QA_int : {8{1'bx}};
      QA_int_delayed = WENA_int !== 1'b1 ? QA_int_delayed : {8{1'bx}};
    end else if (CENA_int === 1'b0 && (^AA_int) === 1'bx) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end else if (CENA_int === 1'b0) begin
      mux_address = (AA_int & 4'b1111);
      row_address = (AA_int >> 4);
      if (row_address > 39)
        row = {128{1'bx}};
      else
        row = mem[row_address];
      writeEnable = ~{8{WENA_int}};
      if (WENA_int !== 1'b1) begin
        row_mask =  ( {15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, DA_int[7], 15'b000000000000000, DA_int[6],
          15'b000000000000000, DA_int[5], 15'b000000000000000, DA_int[4], 15'b000000000000000, DA_int[3],
          15'b000000000000000, DA_int[2], 15'b000000000000000, DA_int[1], 15'b000000000000000, DA_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch0 = {data_out[124], data_out[120], data_out[116], data_out[112], data_out[108],
          data_out[104], data_out[100], data_out[96], data_out[92], data_out[88], data_out[84],
          data_out[80], data_out[76], data_out[72], data_out[68], data_out[64], data_out[60],
          data_out[56], data_out[52], data_out[48], data_out[44], data_out[40], data_out[36],
          data_out[32], data_out[28], data_out[24], data_out[20], data_out[16], data_out[12],
          data_out[8], data_out[4], data_out[0]};
      shifted_readLatch0 = (readLatch0 >> AA_int[3:2]);
      QA_int = {shifted_readLatch0[28], shifted_readLatch0[24], shifted_readLatch0[20],
        shifted_readLatch0[16], shifted_readLatch0[12], shifted_readLatch0[8], shifted_readLatch0[4],
        shifted_readLatch0[0]};
      end
    end
  end
  endtask
  always @ (CENA_ or TCENA_ or TENA_ or CLKA_) begin
  	if(CLKA_ == 1'b0) begin
  		CENA_p2 = CENA_;
  		TCENA_p2 = TCENA_;
  	end
  end

  always @ RET1N_ begin
    if (CLKA_ == 1'b1) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end
    if (RET1N_ === 1'bx || RET1N_ === 1'bz) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end else if (RET1N_ === 1'b0 && RET1N_int === 1'b1 && (CENA_p2 === 1'b0 || TCENA_p2 === 1'b0) ) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end else if (RET1N_ === 1'b1 && RET1N_int === 1'b0 && (CENA_p2 === 1'b0 || TCENA_p2 === 1'b0) ) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end
    if (RET1N_ == 1'b0) begin
      QA_int = {8{1'bx}};
      QA_int_delayed = {8{1'bx}};
      CENA_int = 1'bx;
      WENA_int = 1'bx;
      AA_int = {10{1'bx}};
      DA_int = {8{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      BENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = 1'bx;
      TAA_int = {10{1'bx}};
      TDA_int = {8{1'bx}};
      TQA_int = {8{1'bx}};
      RET1N_int = 1'bx;
      STOVA_int = 1'bx;
      COLLDISN_int = 1'bx;
    end else begin
      QA_int = {8{1'bx}};
      QA_int_delayed = {8{1'bx}};
      CENA_int = 1'bx;
      WENA_int = 1'bx;
      AA_int = {10{1'bx}};
      DA_int = {8{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      BENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = 1'bx;
      TAA_int = {10{1'bx}};
      TDA_int = {8{1'bx}};
      TQA_int = {8{1'bx}};
      RET1N_int = 1'bx;
      STOVA_int = 1'bx;
      COLLDISN_int = 1'bx;
    end
    RET1N_int = RET1N_;
  end


  always @ CLKA_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("ERROR: Illegal value for VDDCE %b", VDDCE);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("ERROR: Illegal value for VDDPE %b", VDDPE);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("ERROR: Illegal value for VSSE %b", VSSE);
`endif
  if (RET1N_ == 1'b0) begin
      // no cycle in retention mode
  end else begin
    if ((CLKA_ === 1'bx || CLKA_ === 1'bz) && RET1N_ !== 1'b0) begin
      failedWrite(0);
      QA_int = {8{1'bx}};
    end else if (CLKA_ === 1'b1 && LAST_CLKA === 1'b0) begin
      CENA_int = TENA_ ? CENA_ : TCENA_;
      EMAA_int = EMAA_;
      EMAWA_int = EMAWA_;
      EMASA_int = EMASA_;
      TENA_int = TENA_;
      BENA_int = BENA_;
      TWENA_int = TWENA_;
      TQA_int = TQA_;
      RET1N_int = RET1N_;
      STOVA_int = STOVA_;
      COLLDISN_int = COLLDISN_;
      if (CENA_int != 1'b1) begin
        WENA_int = TENA_ ? WENA_ : TWENA_;
        AA_int = TENA_ ? AA_ : TAA_;
        DA_int = TENA_ ? DA_ : TDA_;
        TCENA_int = TCENA_;
        TAA_int = TAA_;
        TDA_int = TDA_;
        if (WENA_int === 1'b1)
          read_mux_sel0 = (TENA_ ? AA_[3:2] : TAA_[3:2] );
      end
      clk0_int = 1'b0;
      if (CENA_int === 1'b0 && WENA_int === 1'b1) 
         QA_int_delayed = {8{1'bx}};
      if (CENA_int === 1'b0) previous_CLKA = $realtime;
    readWriteA;
    #0;
      if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && COLLDISN_int === 1'b1 && row_contention(AA_int, AB_int,  WENA_int, WENB_int)) 
       begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          DA_int = {8{1'bx}};
          readWriteA;
          DB_int = {8{1'bx}};
          readWriteB;
	      end
        end else if (WENA_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QB_int = {8{1'bx}};
		end
        end else if (WENB_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QA_int = {8{1'bx}};
		end
        end else begin
          readWriteB;
          readWriteA;
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_READ = 1;
        end
		if (!is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          readWriteB;
          readWriteA;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE = 1;
        end else if (!(WENA_int !== 1'b1) && (WENB_int !== 1'b1)) begin
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else if ((WENA_int !== 1'b1) && !(WENB_int !== 1'b1)) begin
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else begin
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
        end
        end
      end else if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && (COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx)  && row_contention(AA_int,
        AB_int,  WENA_int, WENB_int)) begin
          $display("%s row contention: in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (WENB_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DB_int = {8{1'bx}};
          readWriteB;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
          QB_int = {8{1'bx}};
        end else begin
          readWriteB;
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE_1 = 1;
          READ_READ_1 = 1;
        end
        if (WENA_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DA_int = {8{1'bx}};
          readWriteA;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          QA_int = {8{1'bx}};
        end else begin
          readWriteA;
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (CLKA_ === 1'b0 && LAST_CLKA === 1'b1) begin
      QA_int_delayed = QA_int;
    end
    LAST_CLKA = CLKA_;
  end
  end

  reg globalNotifier0;
  initial globalNotifier0 = 1'b0;

  always @ globalNotifier0 begin
    if ($realtime == 0) begin
    end else if (CENA_int === 1'bx || EMAA_int[0] === 1'bx || EMAA_int[1] === 1'bx || 
      EMAA_int[2] === 1'bx || EMASA_int === 1'bx || EMAWA_int[0] === 1'bx || EMAWA_int[1] === 1'bx || 
      RET1N_int === 1'bx || (STOVA_int && !CENA_int) === 1'bx || TENA_int === 1'bx || 
      clk0_int === 1'bx) begin
      QA_int = {8{1'bx}};
      failedWrite(0);
    end else if  (cont_flag0_int === 1'bx && COLLDISN_int === 1'b1 &&  (CENA_int !== 
     1'b1 && ((TENB_ ? CENB_ : TCENB_) !== 1'b1)) && row_contention(TENB_ ? AB_ : 
     TAB_, AA_int,  WENA_int, TENB_ ? WENB_ : TWENB_)) begin
      cont_flag0_int = 1'b0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          DA_int = {8{1'bx}};
          readWriteA;
          DB_int = {8{1'bx}};
          readWriteB;
	      end
        end else if (WENA_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QB_int = {8{1'bx}};
		end
        end else if (WENB_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QA_int = {8{1'bx}};
		end
        end else begin
          readWriteB;
          readWriteA;
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_READ = 1;
        end
		if (!is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          readWriteB;
          readWriteA;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE = 1;
        end else if (!(WENA_int !== 1'b1) && (WENB_int !== 1'b1)) begin
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else if ((WENA_int !== 1'b1) && !(WENB_int !== 1'b1)) begin
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else begin
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
        end
        end
    end else if  ((CENA_int !== 1'b1 && ((TENB_ ? CENB_ : TCENB_) !== 1'b1)) && cont_flag0_int 
     === 1'bx && (COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx) && row_contention(TENB_ 
     ? AB_ : TAB_, AA_int,  WENA_int, TENB_ ? WENB_ : TWENB_)) begin
      cont_flag0_int = 1'b0;
          $display("%s row contention: in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (WENB_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DB_int = {8{1'bx}};
          readWriteB;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
          QB_int = {8{1'bx}};
        end else begin
          readWriteB;
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE_1 = 1;
          READ_READ_1 = 1;
        end
        if (WENA_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DA_int = {8{1'bx}};
          readWriteA;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          QA_int = {8{1'bx}};
        end else begin
          readWriteA;
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
    end else begin
      readWriteA;
   end
    globalNotifier0 = 1'b0;
  end

  task readWriteB;
  begin
    if (RET1N_int === 1'bx || RET1N_int === 1'bz) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end else if (RET1N_int === 1'b0 && CENB_int === 1'b0) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end else if (RET1N_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{CENB_int, EMAB_int, EMAWB_int, EMASB_int, RET1N_int, (STOVB_int 
     && !CENB_int)} === 1'bx) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end else if ((AB_int >= WORDS) && (CENB_int === 1'b0)) begin
      QB_int = WENB_int !== 1'b1 ? QB_int : {8{1'bx}};
      QB_int_delayed = WENB_int !== 1'b1 ? QB_int_delayed : {8{1'bx}};
    end else if (CENB_int === 1'b0 && (^AB_int) === 1'bx) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end else if (CENB_int === 1'b0) begin
      mux_address = (AB_int & 4'b1111);
      row_address = (AB_int >> 4);
      if (row_address > 39)
        row = {128{1'bx}};
      else
        row = mem[row_address];
      writeEnable = ~{8{WENB_int}};
      if (WENB_int !== 1'b1) begin
        row_mask =  ( {15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, DB_int[7], 15'b000000000000000, DB_int[6],
          15'b000000000000000, DB_int[5], 15'b000000000000000, DB_int[4], 15'b000000000000000, DB_int[3],
          15'b000000000000000, DB_int[2], 15'b000000000000000, DB_int[1], 15'b000000000000000, DB_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch1 = {data_out[124], data_out[120], data_out[116], data_out[112], data_out[108],
          data_out[104], data_out[100], data_out[96], data_out[92], data_out[88], data_out[84],
          data_out[80], data_out[76], data_out[72], data_out[68], data_out[64], data_out[60],
          data_out[56], data_out[52], data_out[48], data_out[44], data_out[40], data_out[36],
          data_out[32], data_out[28], data_out[24], data_out[20], data_out[16], data_out[12],
          data_out[8], data_out[4], data_out[0]};
      shifted_readLatch1 = (readLatch1 >> AB_int[3:2]);
      QB_int = {shifted_readLatch1[28], shifted_readLatch1[24], shifted_readLatch1[20],
        shifted_readLatch1[16], shifted_readLatch1[12], shifted_readLatch1[8], shifted_readLatch1[4],
        shifted_readLatch1[0]};
      end
    end
  end
  endtask
  always @ (CENB_ or TCENB_ or TENB_ or CLKB_) begin
  	if(CLKB_ == 1'b0) begin
  		CENB_p2 = CENB_;
  		TCENB_p2 = TCENB_;
  	end
  end

  always @ RET1N_ begin
    if (CLKB_ == 1'b1) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end
    if (RET1N_ === 1'bx || RET1N_ === 1'bz) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end else if (RET1N_ === 1'b0 && RET1N_int === 1'b1 && (CENB_p2 === 1'b0 || TCENB_p2 === 1'b0) ) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end else if (RET1N_ === 1'b1 && RET1N_int === 1'b0 && (CENB_p2 === 1'b0 || TCENB_p2 === 1'b0) ) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end
    if (RET1N_ == 1'b0) begin
      QB_int = {8{1'bx}};
      QB_int_delayed = {8{1'bx}};
      CENB_int = 1'bx;
      WENB_int = 1'bx;
      AB_int = {10{1'bx}};
      DB_int = {8{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      BENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = 1'bx;
      TAB_int = {10{1'bx}};
      TDB_int = {8{1'bx}};
      TQB_int = {8{1'bx}};
      RET1N_int = 1'bx;
      STOVB_int = 1'bx;
      COLLDISN_int = 1'bx;
    end else begin
      QB_int = {8{1'bx}};
      QB_int_delayed = {8{1'bx}};
      CENB_int = 1'bx;
      WENB_int = 1'bx;
      AB_int = {10{1'bx}};
      DB_int = {8{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      BENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = 1'bx;
      TAB_int = {10{1'bx}};
      TDB_int = {8{1'bx}};
      TQB_int = {8{1'bx}};
      RET1N_int = 1'bx;
      STOVB_int = 1'bx;
      COLLDISN_int = 1'bx;
    end
    RET1N_int = RET1N_;
  end


  always @ CLKB_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("ERROR: Illegal value for VDDCE %b", VDDCE);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("ERROR: Illegal value for VDDPE %b", VDDPE);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("ERROR: Illegal value for VSSE %b", VSSE);
`endif
  if (RET1N_ == 1'b0) begin
      // no cycle in retention mode
  end else begin
    if ((CLKB_ === 1'bx || CLKB_ === 1'bz) && RET1N_ !== 1'b0) begin
      failedWrite(1);
      QB_int = {8{1'bx}};
    end else if (CLKB_ === 1'b1 && LAST_CLKB === 1'b0) begin
      CENB_int = TENB_ ? CENB_ : TCENB_;
      EMAB_int = EMAB_;
      EMAWB_int = EMAWB_;
      EMASB_int = EMASB_;
      TENB_int = TENB_;
      BENB_int = BENB_;
      TWENB_int = TWENB_;
      TQB_int = TQB_;
      RET1N_int = RET1N_;
      STOVB_int = STOVB_;
      COLLDISN_int = COLLDISN_;
      if (CENB_int != 1'b1) begin
        WENB_int = TENB_ ? WENB_ : TWENB_;
        AB_int = TENB_ ? AB_ : TAB_;
        DB_int = TENB_ ? DB_ : TDB_;
        TCENB_int = TCENB_;
        TAB_int = TAB_;
        TDB_int = TDB_;
        if (WENB_int === 1'b1)
          read_mux_sel1 = (TENB_ ? AB_[3:2] : TAB_[3:2] );
      end
      clk1_int = 1'b0;
      if (CENB_int === 1'b0 && WENB_int === 1'b1) 
         QB_int_delayed = {8{1'bx}};
      if (CENB_int === 1'b0) previous_CLKB = $realtime;
    readWriteB;
    #0;
      if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && COLLDISN_int === 1'b1 && row_contention(AA_int, AB_int,  WENA_int, WENB_int)) 
       begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          DA_int = {8{1'bx}};
          readWriteA;
          DB_int = {8{1'bx}};
          readWriteB;
	      end
        end else if (WENA_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QB_int = {8{1'bx}};
		end
        end else if (WENB_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QA_int = {8{1'bx}};
		end
        end else begin
          readWriteA;
          readWriteB;
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_READ = 1;
        end
		if (!is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          readWriteA;
          readWriteB;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE = 1;
        end else if (!(WENA_int !== 1'b1) && (WENB_int !== 1'b1)) begin
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else if ((WENA_int !== 1'b1) && !(WENB_int !== 1'b1)) begin
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else begin
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
        end
        end
      end else if (((previous_CLKA == previous_CLKB) || ((STOVA_int==1'b1 || STOVB_int==1'b1) 
       && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1) 
       && (COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx)  && row_contention(AA_int,
        AB_int,  WENA_int, WENB_int)) begin
          $display("%s row contention: in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (WENA_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DA_int = {8{1'bx}};
          readWriteA;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
          QA_int = {8{1'bx}};
        end else begin
          readWriteA;
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_READ_1 = 1;
          READ_WRITE_1 = 1;
        end
        if (WENB_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DB_int = {8{1'bx}};
          readWriteB;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          QB_int = {8{1'bx}};
        end else begin
          readWriteB;
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (CLKB_ === 1'b0 && LAST_CLKB === 1'b1) begin
      QB_int_delayed = QB_int;
    end
    LAST_CLKB = CLKB_;
  end
  end

  reg globalNotifier1;
  initial globalNotifier1 = 1'b0;

  always @ globalNotifier1 begin
    if ($realtime == 0) begin
    end else if (CENB_int === 1'bx || EMAB_int[0] === 1'bx || EMAB_int[1] === 1'bx || 
      EMAB_int[2] === 1'bx || EMASB_int === 1'bx || EMAWB_int[0] === 1'bx || EMAWB_int[1] === 1'bx || 
      RET1N_int === 1'bx || (STOVB_int && !CENB_int) === 1'bx || TENB_int === 1'bx || 
      clk1_int === 1'bx) begin
      QB_int = {8{1'bx}};
      failedWrite(1);
    end else if  (cont_flag1_int === 1'bx && COLLDISN_int === 1'b1 &&  (CENB_int !== 
     1'b1 && ((TENA_ ? CENA_ : TCENA_) !== 1'b1)) && row_contention(TENA_ ? AA_ : 
     TAA_, AB_int,  WENB_int, TENA_ ? WENA_ : TWENA_)) begin
      cont_flag1_int = 1'b0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          DA_int = {8{1'bx}};
          readWriteA;
          DB_int = {8{1'bx}};
          readWriteB;
	      end
        end else if (WENA_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QB_int = {8{1'bx}};
		end
        end else if (WENB_int !== 1'b1) begin
		if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
          QA_int = {8{1'bx}};
		end
        end else begin
          readWriteA;
          readWriteB;
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_READ = 1;
        end
		if (!is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          readWriteA;
          readWriteB;
        if (WENA_int !== 1'b1 && WENB_int !== 1'b1) begin
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE = 1;
        end else if (!(WENA_int !== 1'b1) && (WENB_int !== 1'b1)) begin
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else if ((WENA_int !== 1'b1) && !(WENB_int !== 1'b1)) begin
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_WRITE = 1;
        end else begin
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
        end
        end
    end else if  ((CENB_int !== 1'b1 && ((TENA_ ? CENA_ : TCENA_) !== 1'b1)) && cont_flag1_int 
     === 1'bx && (COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx) && row_contention(TENA_ 
     ? AA_ : TAA_, AB_int,  WENB_int, TENA_ ? WENA_ : TWENA_)) begin
      cont_flag1_int = 1'b0;
          $display("%s row contention: in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (WENA_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DA_int = {8{1'bx}};
          readWriteA;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
          QA_int = {8{1'bx}};
        end else begin
          readWriteA;
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
          READ_READ_1 = 1;
          READ_WRITE_1 = 1;
        end
        if (WENB_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DB_int = {8{1'bx}};
          readWriteB;
        end else if (is_contention(AA_int, AB_int,  WENA_int, WENB_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          QB_int = {8{1'bx}};
        end else begin
          readWriteB;
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
    end else begin
      readWriteB;
   end
    globalNotifier1 = 1'b0;
  end

  function row_contention;
    input [9:0] aa;
    input [9:0] ab;
    input  wena;
    input  wenb;
    reg result;
    reg sameRow;
    reg sameMux;
    reg anyWrite;
  begin
    anyWrite = ((& wena) === 1'b1 && (& wenb) === 1'b1) ? 1'b0 : 1'b1;
    sameMux = (aa[3:0] == ab[3:0]) ? 1'b1 : 1'b0;
    if (aa[9:4] == ab[9:4]) begin
      sameRow = 1'b1;
    end else begin
      sameRow = 1'b0;
    end
    if (sameRow == 1'b1 && anyWrite == 1'b1)
      row_contention = 1'b1;
    else if (sameRow == 1'b1 && sameMux == 1'b1)
      row_contention = 1'b1;
    else
      row_contention = 1'b0;
  end
  endfunction

  function col_contention;
    input [9:0] aa;
    input [9:0] ab;
  begin
    if (aa[3:0] == ab[3:0])
      col_contention = 1'b1;
    else
      col_contention = 1'b0;
  end
  endfunction

  function is_contention;
    input [9:0] aa;
    input [9:0] ab;
    input  wena;
    input  wenb;
    reg result;
  begin
    if ((& wena) === 1'b1 && (& wenb) === 1'b1) begin
      result = 1'b0;
    end else if (aa == ab) begin
      result = 1'b1;
    end else begin
      result = 1'b0;
    end
    is_contention = result;
  end
  endfunction

   wire contA_flag = (CENA_int !== 1'b1 && ((TENB_ ? CENB_ : TCENB_) !== 1'b1)) && ((COLLDISN_int === 1'b1 && is_contention(TENB_ ? AB_ : TAB_, AA_int,  TENB_ ? WENB_ : TWENB_, WENA_int)) ||
              ((COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx) && row_contention(TENB_ ? AB_ : TAB_, AA_int,  TENB_ ? WENB_ : TWENB_, WENA_int)));
   wire contB_flag = (CENB_int !== 1'b1 && ((TENA_ ? CENA_ : TCENA_) !== 1'b1)) && ((COLLDISN_int === 1'b1 && is_contention(TENA_ ? AA_ : TAA_, AB_int,  TENA_ ? WENA_ : TWENA_, WENB_int)) ||
              ((COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx) && row_contention(TENA_ ? AA_ : TAA_, AB_int,  TENA_ ? WENA_ : TWENA_, WENB_int)));

  always @ NOT_CENA begin
    CENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA begin
    WENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA9 begin
    AA_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA8 begin
    AA_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA7 begin
    AA_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA6 begin
    AA_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA5 begin
    AA_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA4 begin
    AA_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA3 begin
    AA_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA2 begin
    AA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA1 begin
    AA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA0 begin
    AA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA7 begin
    DA_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA6 begin
    DA_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA5 begin
    DA_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA4 begin
    DA_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA3 begin
    DA_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA2 begin
    DA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA1 begin
    DA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA0 begin
    DA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CENB begin
    CENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB begin
    WENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB9 begin
    AB_int[9] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB8 begin
    AB_int[8] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB7 begin
    AB_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB6 begin
    AB_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB5 begin
    AB_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB4 begin
    AB_int[4] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB3 begin
    AB_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB2 begin
    AB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB1 begin
    AB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB0 begin
    AB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB7 begin
    DB_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB6 begin
    DB_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB5 begin
    DB_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB4 begin
    DB_int[4] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB3 begin
    DB_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB2 begin
    DB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB1 begin
    DB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB0 begin
    DB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAA2 begin
    EMAA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAA1 begin
    EMAA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAA0 begin
    EMAA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAWA1 begin
    EMAWA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAWA0 begin
    EMAWA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMASA begin
    EMASA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAB2 begin
    EMAB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAB1 begin
    EMAB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAB0 begin
    EMAB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAWB1 begin
    EMAWB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAWB0 begin
    EMAWB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMASB begin
    EMASB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TENA begin
    TENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TCENA begin
    CENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA begin
    WENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA9 begin
    AA_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA8 begin
    AA_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA7 begin
    AA_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA6 begin
    AA_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA5 begin
    AA_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA4 begin
    AA_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA3 begin
    AA_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA2 begin
    AA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA1 begin
    AA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA0 begin
    AA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA7 begin
    DA_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA6 begin
    DA_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA5 begin
    DA_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA4 begin
    DA_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA3 begin
    DA_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA2 begin
    DA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA1 begin
    DA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA0 begin
    DA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TENB begin
    TENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TCENB begin
    CENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB begin
    WENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB9 begin
    AB_int[9] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB8 begin
    AB_int[8] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB7 begin
    AB_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB6 begin
    AB_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB5 begin
    AB_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB4 begin
    AB_int[4] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB3 begin
    AB_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB2 begin
    AB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB1 begin
    AB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB0 begin
    AB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB7 begin
    DB_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB6 begin
    DB_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB5 begin
    DB_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB4 begin
    DB_int[4] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB3 begin
    DB_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB2 begin
    DB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB1 begin
    DB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB0 begin
    DB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_RET1N begin
    RET1N_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_STOVA begin
    STOVA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_STOVB begin
    STOVB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_COLLDISN begin
    COLLDISN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end

  always @ NOT_CONTA begin
    cont_flag0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKA_PER begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKA_MINH begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKA_MINL begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CONTB begin
    cont_flag1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CLKB_PER begin
    clk1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CLKB_MINH begin
    clk1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CLKB_MINL begin
    clk1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end


  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contA_STOVAeq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire STOVAeq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire contB_STOVBeq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire STOVBeq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp;
  wire opopTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cpcpandopopTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cpcp;
  wire opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp;
  wire opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp;

  wire STOVAeq0, STOVAeq1andEMASAeq0, STOVAeq1andEMASAeq1, TENAeq1, TENAeq1andCENAeq0;
  wire TENAeq1andCENAeq0andWENAeq0, STOVBeq0, STOVBeq1andEMASBeq0, STOVBeq1andEMASBeq1;
  wire TENBeq1, TENBeq1andCENBeq0, TENBeq1andCENBeq0andWENBeq0, TENAeq0, TENAeq0andTCENAeq0;
  wire TENAeq0andTCENAeq0andTWENAeq0, TENBeq0, TENBeq0andTCENBeq0, TENBeq0andTCENBeq0andTWENBeq0;

  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (STOVA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign contA_STOVAeq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (STOVA) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA) && contA_flag;
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (STOVA) && (!EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp = 
         (STOVA) && (EMASA) && ((TENA && WENA) || (!TENA && TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (!EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (!EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (!EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (!EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (!EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (!STOVA) && (EMAA[2]) && (EMAA[1]) && (EMAA[0]) && (EMAWA[1]) && (EMAWA[0]) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp = 
         (STOVA) && ((TENA && !WENA) || (!TENA && !TWENA)) && !(TENA ? CENA : TCENA);
  assign STOVAeq1andEMASAeq0 = 
         (STOVA) && (!EMASA) && !(TENA ? CENA : TCENA);
  assign STOVAeq1andEMASAeq1 = 
         (STOVA) && (EMASA) && !(TENA ? CENA : TCENA);
  assign TENAeq1andCENAeq0 = 
         !(!TENA || CENA);
  assign TENAeq1andCENAeq0andWENAeq0 = 
         !(!TENA ||  CENA || WENA);
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (STOVB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign contB_STOVBeq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (STOVB) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB) && contB_flag;
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (STOVB) && (!EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp = 
         (STOVB) && (EMASB) && ((TENB && WENB) || (!TENB && TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (!EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (!EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (!EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (!EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (!EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (!STOVB) && (EMAB[2]) && (EMAB[1]) && (EMAB[0]) && (EMAWB[1]) && (EMAWB[0]) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp = 
         (STOVB) && ((TENB && !WENB) || (!TENB && !TWENB)) && !(TENB ? CENB : TCENB);
  assign STOVBeq1andEMASBeq0 = 
         (STOVB) && (!EMASB) && !(TENB ? CENB : TCENB);
  assign STOVBeq1andEMASBeq1 = 
         (STOVB) && (EMASB) && !(TENB ? CENB : TCENB);
  assign TENBeq1andCENBeq0 = 
         !(!TENB || CENB);
  assign TENBeq1andCENBeq0andWENBeq0 = 
         !(!TENB ||  CENB || WENB);
  assign TENAeq0andTCENAeq0 = 
         !(TENA || TCENA);
  assign TENAeq0andTCENAeq0andTWENAeq0 = 
         !(TENA ||  TCENA || TWENA);
  assign TENBeq0andTCENBeq0 = 
         !(TENB || TCENB);
  assign TENBeq0andTCENBeq0andTWENBeq0 = 
         !(TENB ||  TCENB || TWENB);
  assign opopTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cpcpandopopTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cpcp = 
         ((TENA ? CENA : TCENA) && (TENB ? CENB : TCENB));
  assign opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp = 
         !(TENA ? CENA : TCENA);
  assign opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp = 
         !(TENB ? CENB : TCENB);

  assign STOVAeq0 = (!STOVA) && !(TENA ? CENA : TCENA);
  assign TENAeq1 = TENA;
  assign STOVBeq0 = (!STOVB) && !(TENB ? CENB : TCENB);
  assign TENBeq1 = TENB;
  assign TENAeq0 = !TENA;
  assign TENBeq0 = !TENB;

  specify
    if (CENA == 1'b0 && TCENA == 1'b1)
       (TENA => CENYA) = (1.000, 1.000);
    if (CENA == 1'b1 && TCENA == 1'b0)
       (TENA => CENYA) = (1.000, 1.000);
    if (TENA == 1'b1)
       (CENA => CENYA) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TCENA => CENYA) = (1.000, 1.000);
    if (WENA == 1'b0 && TWENA == 1'b1)
       (TENA => WENYA) = (1.000, 1.000);
    if (WENA == 1'b1 && TWENA == 1'b0)
       (TENA => WENYA) = (1.000, 1.000);
    if (TENA == 1'b1)
       (WENA => WENYA) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TWENA => WENYA) = (1.000, 1.000);
    if (AA[9] == 1'b0 && TAA[9] == 1'b1)
       (TENA => AYA[9]) = (1.000, 1.000);
    if (AA[9] == 1'b1 && TAA[9] == 1'b0)
       (TENA => AYA[9]) = (1.000, 1.000);
    if (AA[8] == 1'b0 && TAA[8] == 1'b1)
       (TENA => AYA[8]) = (1.000, 1.000);
    if (AA[8] == 1'b1 && TAA[8] == 1'b0)
       (TENA => AYA[8]) = (1.000, 1.000);
    if (AA[7] == 1'b0 && TAA[7] == 1'b1)
       (TENA => AYA[7]) = (1.000, 1.000);
    if (AA[7] == 1'b1 && TAA[7] == 1'b0)
       (TENA => AYA[7]) = (1.000, 1.000);
    if (AA[6] == 1'b0 && TAA[6] == 1'b1)
       (TENA => AYA[6]) = (1.000, 1.000);
    if (AA[6] == 1'b1 && TAA[6] == 1'b0)
       (TENA => AYA[6]) = (1.000, 1.000);
    if (AA[5] == 1'b0 && TAA[5] == 1'b1)
       (TENA => AYA[5]) = (1.000, 1.000);
    if (AA[5] == 1'b1 && TAA[5] == 1'b0)
       (TENA => AYA[5]) = (1.000, 1.000);
    if (AA[4] == 1'b0 && TAA[4] == 1'b1)
       (TENA => AYA[4]) = (1.000, 1.000);
    if (AA[4] == 1'b1 && TAA[4] == 1'b0)
       (TENA => AYA[4]) = (1.000, 1.000);
    if (AA[3] == 1'b0 && TAA[3] == 1'b1)
       (TENA => AYA[3]) = (1.000, 1.000);
    if (AA[3] == 1'b1 && TAA[3] == 1'b0)
       (TENA => AYA[3]) = (1.000, 1.000);
    if (AA[2] == 1'b0 && TAA[2] == 1'b1)
       (TENA => AYA[2]) = (1.000, 1.000);
    if (AA[2] == 1'b1 && TAA[2] == 1'b0)
       (TENA => AYA[2]) = (1.000, 1.000);
    if (AA[1] == 1'b0 && TAA[1] == 1'b1)
       (TENA => AYA[1]) = (1.000, 1.000);
    if (AA[1] == 1'b1 && TAA[1] == 1'b0)
       (TENA => AYA[1]) = (1.000, 1.000);
    if (AA[0] == 1'b0 && TAA[0] == 1'b1)
       (TENA => AYA[0]) = (1.000, 1.000);
    if (AA[0] == 1'b1 && TAA[0] == 1'b0)
       (TENA => AYA[0]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[9] => AYA[9]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[8] => AYA[8]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[7] => AYA[7]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[6] => AYA[6]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[5] => AYA[5]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[4] => AYA[4]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[3] => AYA[3]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[2] => AYA[2]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[1] => AYA[1]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (AA[0] => AYA[0]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[9] => AYA[9]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[8] => AYA[8]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[7] => AYA[7]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[6] => AYA[6]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[5] => AYA[5]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[4] => AYA[4]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[3] => AYA[3]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[2] => AYA[2]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[1] => AYA[1]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TAA[0] => AYA[0]) = (1.000, 1.000);
    if (DA[7] == 1'b0 && TDA[7] == 1'b1)
       (TENA => DYA[7]) = (1.000, 1.000);
    if (DA[7] == 1'b1 && TDA[7] == 1'b0)
       (TENA => DYA[7]) = (1.000, 1.000);
    if (DA[6] == 1'b0 && TDA[6] == 1'b1)
       (TENA => DYA[6]) = (1.000, 1.000);
    if (DA[6] == 1'b1 && TDA[6] == 1'b0)
       (TENA => DYA[6]) = (1.000, 1.000);
    if (DA[5] == 1'b0 && TDA[5] == 1'b1)
       (TENA => DYA[5]) = (1.000, 1.000);
    if (DA[5] == 1'b1 && TDA[5] == 1'b0)
       (TENA => DYA[5]) = (1.000, 1.000);
    if (DA[4] == 1'b0 && TDA[4] == 1'b1)
       (TENA => DYA[4]) = (1.000, 1.000);
    if (DA[4] == 1'b1 && TDA[4] == 1'b0)
       (TENA => DYA[4]) = (1.000, 1.000);
    if (DA[3] == 1'b0 && TDA[3] == 1'b1)
       (TENA => DYA[3]) = (1.000, 1.000);
    if (DA[3] == 1'b1 && TDA[3] == 1'b0)
       (TENA => DYA[3]) = (1.000, 1.000);
    if (DA[2] == 1'b0 && TDA[2] == 1'b1)
       (TENA => DYA[2]) = (1.000, 1.000);
    if (DA[2] == 1'b1 && TDA[2] == 1'b0)
       (TENA => DYA[2]) = (1.000, 1.000);
    if (DA[1] == 1'b0 && TDA[1] == 1'b1)
       (TENA => DYA[1]) = (1.000, 1.000);
    if (DA[1] == 1'b1 && TDA[1] == 1'b0)
       (TENA => DYA[1]) = (1.000, 1.000);
    if (DA[0] == 1'b0 && TDA[0] == 1'b1)
       (TENA => DYA[0]) = (1.000, 1.000);
    if (DA[0] == 1'b1 && TDA[0] == 1'b0)
       (TENA => DYA[0]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[7] => DYA[7]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[6] => DYA[6]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[5] => DYA[5]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[4] => DYA[4]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[3] => DYA[3]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[2] => DYA[2]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[1] => DYA[1]) = (1.000, 1.000);
    if (TENA == 1'b1)
       (DA[0] => DYA[0]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[7] => DYA[7]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[6] => DYA[6]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[5] => DYA[5]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[4] => DYA[4]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[3] => DYA[3]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[2] => DYA[2]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[1] => DYA[1]) = (1.000, 1.000);
    if (TENA == 1'b0)
       (TDA[0] => DYA[0]) = (1.000, 1.000);
    if (CENB == 1'b0 && TCENB == 1'b1)
       (TENB => CENYB) = (1.000, 1.000);
    if (CENB == 1'b1 && TCENB == 1'b0)
       (TENB => CENYB) = (1.000, 1.000);
    if (TENB == 1'b1)
       (CENB => CENYB) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TCENB => CENYB) = (1.000, 1.000);
    if (WENB == 1'b0 && TWENB == 1'b1)
       (TENB => WENYB) = (1.000, 1.000);
    if (WENB == 1'b1 && TWENB == 1'b0)
       (TENB => WENYB) = (1.000, 1.000);
    if (TENB == 1'b1)
       (WENB => WENYB) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TWENB => WENYB) = (1.000, 1.000);
    if (AB[9] == 1'b0 && TAB[9] == 1'b1)
       (TENB => AYB[9]) = (1.000, 1.000);
    if (AB[9] == 1'b1 && TAB[9] == 1'b0)
       (TENB => AYB[9]) = (1.000, 1.000);
    if (AB[8] == 1'b0 && TAB[8] == 1'b1)
       (TENB => AYB[8]) = (1.000, 1.000);
    if (AB[8] == 1'b1 && TAB[8] == 1'b0)
       (TENB => AYB[8]) = (1.000, 1.000);
    if (AB[7] == 1'b0 && TAB[7] == 1'b1)
       (TENB => AYB[7]) = (1.000, 1.000);
    if (AB[7] == 1'b1 && TAB[7] == 1'b0)
       (TENB => AYB[7]) = (1.000, 1.000);
    if (AB[6] == 1'b0 && TAB[6] == 1'b1)
       (TENB => AYB[6]) = (1.000, 1.000);
    if (AB[6] == 1'b1 && TAB[6] == 1'b0)
       (TENB => AYB[6]) = (1.000, 1.000);
    if (AB[5] == 1'b0 && TAB[5] == 1'b1)
       (TENB => AYB[5]) = (1.000, 1.000);
    if (AB[5] == 1'b1 && TAB[5] == 1'b0)
       (TENB => AYB[5]) = (1.000, 1.000);
    if (AB[4] == 1'b0 && TAB[4] == 1'b1)
       (TENB => AYB[4]) = (1.000, 1.000);
    if (AB[4] == 1'b1 && TAB[4] == 1'b0)
       (TENB => AYB[4]) = (1.000, 1.000);
    if (AB[3] == 1'b0 && TAB[3] == 1'b1)
       (TENB => AYB[3]) = (1.000, 1.000);
    if (AB[3] == 1'b1 && TAB[3] == 1'b0)
       (TENB => AYB[3]) = (1.000, 1.000);
    if (AB[2] == 1'b0 && TAB[2] == 1'b1)
       (TENB => AYB[2]) = (1.000, 1.000);
    if (AB[2] == 1'b1 && TAB[2] == 1'b0)
       (TENB => AYB[2]) = (1.000, 1.000);
    if (AB[1] == 1'b0 && TAB[1] == 1'b1)
       (TENB => AYB[1]) = (1.000, 1.000);
    if (AB[1] == 1'b1 && TAB[1] == 1'b0)
       (TENB => AYB[1]) = (1.000, 1.000);
    if (AB[0] == 1'b0 && TAB[0] == 1'b1)
       (TENB => AYB[0]) = (1.000, 1.000);
    if (AB[0] == 1'b1 && TAB[0] == 1'b0)
       (TENB => AYB[0]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[9] => AYB[9]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[8] => AYB[8]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[7] => AYB[7]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[6] => AYB[6]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[5] => AYB[5]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[4] => AYB[4]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[3] => AYB[3]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[2] => AYB[2]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[1] => AYB[1]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (AB[0] => AYB[0]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[9] => AYB[9]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[8] => AYB[8]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[7] => AYB[7]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[6] => AYB[6]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[5] => AYB[5]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[4] => AYB[4]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[3] => AYB[3]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[2] => AYB[2]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[1] => AYB[1]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TAB[0] => AYB[0]) = (1.000, 1.000);
    if (DB[7] == 1'b0 && TDB[7] == 1'b1)
       (TENB => DYB[7]) = (1.000, 1.000);
    if (DB[7] == 1'b1 && TDB[7] == 1'b0)
       (TENB => DYB[7]) = (1.000, 1.000);
    if (DB[6] == 1'b0 && TDB[6] == 1'b1)
       (TENB => DYB[6]) = (1.000, 1.000);
    if (DB[6] == 1'b1 && TDB[6] == 1'b0)
       (TENB => DYB[6]) = (1.000, 1.000);
    if (DB[5] == 1'b0 && TDB[5] == 1'b1)
       (TENB => DYB[5]) = (1.000, 1.000);
    if (DB[5] == 1'b1 && TDB[5] == 1'b0)
       (TENB => DYB[5]) = (1.000, 1.000);
    if (DB[4] == 1'b0 && TDB[4] == 1'b1)
       (TENB => DYB[4]) = (1.000, 1.000);
    if (DB[4] == 1'b1 && TDB[4] == 1'b0)
       (TENB => DYB[4]) = (1.000, 1.000);
    if (DB[3] == 1'b0 && TDB[3] == 1'b1)
       (TENB => DYB[3]) = (1.000, 1.000);
    if (DB[3] == 1'b1 && TDB[3] == 1'b0)
       (TENB => DYB[3]) = (1.000, 1.000);
    if (DB[2] == 1'b0 && TDB[2] == 1'b1)
       (TENB => DYB[2]) = (1.000, 1.000);
    if (DB[2] == 1'b1 && TDB[2] == 1'b0)
       (TENB => DYB[2]) = (1.000, 1.000);
    if (DB[1] == 1'b0 && TDB[1] == 1'b1)
       (TENB => DYB[1]) = (1.000, 1.000);
    if (DB[1] == 1'b1 && TDB[1] == 1'b0)
       (TENB => DYB[1]) = (1.000, 1.000);
    if (DB[0] == 1'b0 && TDB[0] == 1'b1)
       (TENB => DYB[0]) = (1.000, 1.000);
    if (DB[0] == 1'b1 && TDB[0] == 1'b0)
       (TENB => DYB[0]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[7] => DYB[7]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[6] => DYB[6]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[5] => DYB[5]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[4] => DYB[4]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[3] => DYB[3]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[2] => DYB[2]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[1] => DYB[1]) = (1.000, 1.000);
    if (TENB == 1'b1)
       (DB[0] => DYB[0]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[7] => DYB[7]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[6] => DYB[6]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[5] => DYB[5]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[4] => DYB[4]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[3] => DYB[3]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[2] => DYB[2]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[1] => DYB[1]) = (1.000, 1.000);
    if (TENB == 1'b0)
       (TDB[0] => DYB[0]) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (posedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENA == 1'b1 && STOVA == 1'b1 && ((TENA == 1'b1 && WENA == 1'b1) || (TENA == 1'b0 && TWENA == 1'b1)))
       (negedge CLKA => (QA[0] : 1'b0)) = (1.000, 1.000);
    if (TQA[7] == 1'b1)
       (BENA => QA[7]) = (1.000, 1.000);
    if (TQA[7] == 1'b0)
       (BENA => QA[7]) = (1.000, 1.000);
    if (TQA[6] == 1'b1)
       (BENA => QA[6]) = (1.000, 1.000);
    if (TQA[6] == 1'b0)
       (BENA => QA[6]) = (1.000, 1.000);
    if (TQA[5] == 1'b1)
       (BENA => QA[5]) = (1.000, 1.000);
    if (TQA[5] == 1'b0)
       (BENA => QA[5]) = (1.000, 1.000);
    if (TQA[4] == 1'b1)
       (BENA => QA[4]) = (1.000, 1.000);
    if (TQA[4] == 1'b0)
       (BENA => QA[4]) = (1.000, 1.000);
    if (TQA[3] == 1'b1)
       (BENA => QA[3]) = (1.000, 1.000);
    if (TQA[3] == 1'b0)
       (BENA => QA[3]) = (1.000, 1.000);
    if (TQA[2] == 1'b1)
       (BENA => QA[2]) = (1.000, 1.000);
    if (TQA[2] == 1'b0)
       (BENA => QA[2]) = (1.000, 1.000);
    if (TQA[1] == 1'b1)
       (BENA => QA[1]) = (1.000, 1.000);
    if (TQA[1] == 1'b0)
       (BENA => QA[1]) = (1.000, 1.000);
    if (TQA[0] == 1'b1)
       (BENA => QA[0]) = (1.000, 1.000);
    if (TQA[0] == 1'b0)
       (BENA => QA[0]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[7] => QA[7]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[6] => QA[6]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[5] => QA[5]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[4] => QA[4]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[3] => QA[3]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[2] => QA[2]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[1] => QA[1]) = (1.000, 1.000);
    if (BENA == 1'b0)
       (TQA[0] => QA[0]) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b0 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b0 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b0 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b0 && EMAB[2] == 1'b1 && EMAB[1] == 1'b1 && EMAB[0] == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (posedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[7] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[6] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[5] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[4] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[3] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[2] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[1] : 1'b0)) = (1.000, 1.000);
    if (RET1N == 1'b1 && BENB == 1'b1 && STOVB == 1'b1 && ((TENB == 1'b1 && WENB == 1'b1) || (TENB == 1'b0 && TWENB == 1'b1)))
       (negedge CLKB => (QB[0] : 1'b0)) = (1.000, 1.000);
    if (TQB[7] == 1'b1)
       (BENB => QB[7]) = (1.000, 1.000);
    if (TQB[7] == 1'b0)
       (BENB => QB[7]) = (1.000, 1.000);
    if (TQB[6] == 1'b1)
       (BENB => QB[6]) = (1.000, 1.000);
    if (TQB[6] == 1'b0)
       (BENB => QB[6]) = (1.000, 1.000);
    if (TQB[5] == 1'b1)
       (BENB => QB[5]) = (1.000, 1.000);
    if (TQB[5] == 1'b0)
       (BENB => QB[5]) = (1.000, 1.000);
    if (TQB[4] == 1'b1)
       (BENB => QB[4]) = (1.000, 1.000);
    if (TQB[4] == 1'b0)
       (BENB => QB[4]) = (1.000, 1.000);
    if (TQB[3] == 1'b1)
       (BENB => QB[3]) = (1.000, 1.000);
    if (TQB[3] == 1'b0)
       (BENB => QB[3]) = (1.000, 1.000);
    if (TQB[2] == 1'b1)
       (BENB => QB[2]) = (1.000, 1.000);
    if (TQB[2] == 1'b0)
       (BENB => QB[2]) = (1.000, 1.000);
    if (TQB[1] == 1'b1)
       (BENB => QB[1]) = (1.000, 1.000);
    if (TQB[1] == 1'b0)
       (BENB => QB[1]) = (1.000, 1.000);
    if (TQB[0] == 1'b1)
       (BENB => QB[0]) = (1.000, 1.000);
    if (TQB[0] == 1'b0)
       (BENB => QB[0]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[7] => QB[7]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[6] => QB[6]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[5] => QB[5]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[4] => QB[4]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[3] => QB[3]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[2] => QB[2]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[1] => QB[1]) = (1.000, 1.000);
    if (BENB == 1'b0)
       (TQB[0] => QB[0]) = (1.000, 1.000);

    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_STOVAeq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, posedge CLKA, 3.000, 0.000, NOT_CONTA);

// Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge CLKA, 3.000, NOT_CLKA_PER);
   `else
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(negedge CLKA &&& STOVAeq1andEMASAeq0andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(negedge CLKA &&& STOVAeq1andEMASAeq1andopopTENAeq1andWENAeq1cporopTENAeq0andTWENAeq1cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq0andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq0andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq0andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq0andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq0andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq0andEMAA2eq1andEMAA1eq1andEMAA0eq1andEMAWA1eq1andEMAWA0eq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVAeq1andopopTENAeq1andWENAeq0cporopTENAeq0andTWENAeq0cpcp, 3.000, NOT_CLKA_PER);
   `endif

// Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge CLKA, 1.000, 0, NOT_CLKA_MINH);
       $width(negedge CLKA, 1.000, 0, NOT_CLKA_MINL);
   `else
       $width(posedge CLKA &&& STOVAeq0, 1.000, 0, NOT_CLKA_MINH);
       $width(negedge CLKA &&& STOVAeq0, 1.000, 0, NOT_CLKA_MINL);
       $width(posedge CLKA &&& STOVAeq1andEMASAeq0, 1.000, 0, NOT_CLKA_MINH);
       $width(negedge CLKA &&& STOVAeq1andEMASAeq0, 1.000, 0, NOT_CLKA_MINL);
       $width(posedge CLKA &&& STOVAeq1andEMASAeq1, 1.000, 0, NOT_CLKA_MINH);
       $width(negedge CLKA &&& STOVAeq1andEMASAeq1, 1.000, 0, NOT_CLKA_MINL);
   `endif

    $setuphold(posedge CLKA &&& TENAeq1, posedge CENA, 1.000, 0.500, NOT_CENA);
    $setuphold(posedge CLKA &&& TENAeq1, negedge CENA, 1.000, 0.500, NOT_CENA);
    $setuphold(posedge RET1N &&& TENAeq1, negedge CENA, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge WENA, 1.000, 0.500, NOT_WENA);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge WENA, 1.000, 0.500, NOT_WENA);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[9], 1.000, 0.500, NOT_AA9);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[8], 1.000, 0.500, NOT_AA8);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[7], 1.000, 0.500, NOT_AA7);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[6], 1.000, 0.500, NOT_AA6);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[5], 1.000, 0.500, NOT_AA5);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[4], 1.000, 0.500, NOT_AA4);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[3], 1.000, 0.500, NOT_AA3);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[2], 1.000, 0.500, NOT_AA2);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[1], 1.000, 0.500, NOT_AA1);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, posedge AA[0], 1.000, 0.500, NOT_AA0);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[9], 1.000, 0.500, NOT_AA9);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[8], 1.000, 0.500, NOT_AA8);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[7], 1.000, 0.500, NOT_AA7);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[6], 1.000, 0.500, NOT_AA6);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[5], 1.000, 0.500, NOT_AA5);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[4], 1.000, 0.500, NOT_AA4);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[3], 1.000, 0.500, NOT_AA3);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[2], 1.000, 0.500, NOT_AA2);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[1], 1.000, 0.500, NOT_AA1);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0, negedge AA[0], 1.000, 0.500, NOT_AA0);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[7], 1.000, 0.500, NOT_DA7);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[6], 1.000, 0.500, NOT_DA6);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[5], 1.000, 0.500, NOT_DA5);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[4], 1.000, 0.500, NOT_DA4);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[3], 1.000, 0.500, NOT_DA3);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[2], 1.000, 0.500, NOT_DA2);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[1], 1.000, 0.500, NOT_DA1);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, posedge DA[0], 1.000, 0.500, NOT_DA0);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[7], 1.000, 0.500, NOT_DA7);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[6], 1.000, 0.500, NOT_DA6);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[5], 1.000, 0.500, NOT_DA5);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[4], 1.000, 0.500, NOT_DA4);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[3], 1.000, 0.500, NOT_DA3);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[2], 1.000, 0.500, NOT_DA2);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[1], 1.000, 0.500, NOT_DA1);
    $setuphold(posedge CLKA &&& TENAeq1andCENAeq0andWENAeq0, negedge DA[0], 1.000, 0.500, NOT_DA0);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_STOVBeq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, posedge CLKB, 3.000, 0.000, NOT_CONTB);

// Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge CLKB, 3.000, NOT_CLKB_PER);
   `else
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(negedge CLKB &&& STOVBeq1andEMASBeq0andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(negedge CLKB &&& STOVBeq1andEMASBeq1andopopTENBeq1andWENBeq1cporopTENBeq0andTWENBeq1cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq0andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq0andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq0andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq0andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq0andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq0andEMAB2eq1andEMAB1eq1andEMAB0eq1andEMAWB1eq1andEMAWB0eq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVBeq1andopopTENBeq1andWENBeq0cporopTENBeq0andTWENBeq0cpcp, 3.000, NOT_CLKB_PER);
   `endif

// Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge CLKB, 1.000, 0, NOT_CLKB_MINH);
       $width(negedge CLKB, 1.000, 0, NOT_CLKB_MINL);
   `else
       $width(posedge CLKB &&& STOVBeq0, 1.000, 0, NOT_CLKB_MINH);
       $width(negedge CLKB &&& STOVBeq0, 1.000, 0, NOT_CLKB_MINL);
       $width(posedge CLKB &&& STOVBeq1andEMASBeq0, 1.000, 0, NOT_CLKB_MINH);
       $width(negedge CLKB &&& STOVBeq1andEMASBeq0, 1.000, 0, NOT_CLKB_MINL);
       $width(posedge CLKB &&& STOVBeq1andEMASBeq1, 1.000, 0, NOT_CLKB_MINH);
       $width(negedge CLKB &&& STOVBeq1andEMASBeq1, 1.000, 0, NOT_CLKB_MINL);
   `endif

    $setuphold(posedge CLKB &&& TENBeq1, posedge CENB, 1.000, 0.500, NOT_CENB);
    $setuphold(posedge CLKB &&& TENBeq1, negedge CENB, 1.000, 0.500, NOT_CENB);
    $setuphold(posedge RET1N &&& TENBeq1, negedge CENB, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge WENB, 1.000, 0.500, NOT_WENB);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge WENB, 1.000, 0.500, NOT_WENB);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[9], 1.000, 0.500, NOT_AB9);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[8], 1.000, 0.500, NOT_AB8);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[7], 1.000, 0.500, NOT_AB7);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[6], 1.000, 0.500, NOT_AB6);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[5], 1.000, 0.500, NOT_AB5);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[4], 1.000, 0.500, NOT_AB4);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[3], 1.000, 0.500, NOT_AB3);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[2], 1.000, 0.500, NOT_AB2);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[1], 1.000, 0.500, NOT_AB1);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, posedge AB[0], 1.000, 0.500, NOT_AB0);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[9], 1.000, 0.500, NOT_AB9);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[8], 1.000, 0.500, NOT_AB8);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[7], 1.000, 0.500, NOT_AB7);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[6], 1.000, 0.500, NOT_AB6);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[5], 1.000, 0.500, NOT_AB5);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[4], 1.000, 0.500, NOT_AB4);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[3], 1.000, 0.500, NOT_AB3);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[2], 1.000, 0.500, NOT_AB2);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[1], 1.000, 0.500, NOT_AB1);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0, negedge AB[0], 1.000, 0.500, NOT_AB0);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[7], 1.000, 0.500, NOT_DB7);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[6], 1.000, 0.500, NOT_DB6);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[5], 1.000, 0.500, NOT_DB5);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[4], 1.000, 0.500, NOT_DB4);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[3], 1.000, 0.500, NOT_DB3);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[2], 1.000, 0.500, NOT_DB2);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[1], 1.000, 0.500, NOT_DB1);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, posedge DB[0], 1.000, 0.500, NOT_DB0);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[7], 1.000, 0.500, NOT_DB7);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[6], 1.000, 0.500, NOT_DB6);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[5], 1.000, 0.500, NOT_DB5);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[4], 1.000, 0.500, NOT_DB4);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[3], 1.000, 0.500, NOT_DB3);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[2], 1.000, 0.500, NOT_DB2);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[1], 1.000, 0.500, NOT_DB1);
    $setuphold(posedge CLKB &&& TENBeq1andCENBeq0andWENBeq0, negedge DB[0], 1.000, 0.500, NOT_DB0);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge EMAA[2], 1.000, 0.500, NOT_EMAA2);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge EMAA[1], 1.000, 0.500, NOT_EMAA1);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge EMAA[0], 1.000, 0.500, NOT_EMAA0);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge EMAA[2], 1.000, 0.500, NOT_EMAA2);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge EMAA[1], 1.000, 0.500, NOT_EMAA1);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge EMAA[0], 1.000, 0.500, NOT_EMAA0);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge EMAWA[1], 1.000, 0.500, NOT_EMAWA1);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge EMAWA[0], 1.000, 0.500, NOT_EMAWA0);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge EMAWA[1], 1.000, 0.500, NOT_EMAWA1);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge EMAWA[0], 1.000, 0.500, NOT_EMAWA0);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge EMASA, 1.000, 0.500, NOT_EMASA);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge EMASA, 1.000, 0.500, NOT_EMASA);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge EMAB[2], 1.000, 0.500, NOT_EMAB2);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge EMAB[1], 1.000, 0.500, NOT_EMAB1);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge EMAB[0], 1.000, 0.500, NOT_EMAB0);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge EMAB[2], 1.000, 0.500, NOT_EMAB2);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge EMAB[1], 1.000, 0.500, NOT_EMAB1);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge EMAB[0], 1.000, 0.500, NOT_EMAB0);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge EMAWB[1], 1.000, 0.500, NOT_EMAWB1);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge EMAWB[0], 1.000, 0.500, NOT_EMAWB0);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge EMAWB[1], 1.000, 0.500, NOT_EMAWB1);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge EMAWB[0], 1.000, 0.500, NOT_EMAWB0);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge EMASB, 1.000, 0.500, NOT_EMASB);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge EMASB, 1.000, 0.500, NOT_EMASB);
    $setuphold(posedge CLKA, posedge TENA, 1.000, 0.500, NOT_TENA);
    $setuphold(posedge CLKA, negedge TENA, 1.000, 0.500, NOT_TENA);
    $setuphold(posedge CLKA &&& TENAeq0, posedge TCENA, 1.000, 0.500, NOT_TCENA);
    $setuphold(posedge CLKA &&& TENAeq0, negedge TCENA, 1.000, 0.500, NOT_TCENA);
    $setuphold(posedge RET1N &&& TENAeq0, negedge TCENA, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TWENA, 1.000, 0.500, NOT_TWENA);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TWENA, 1.000, 0.500, NOT_TWENA);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[9], 1.000, 0.500, NOT_TAA9);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[8], 1.000, 0.500, NOT_TAA8);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[7], 1.000, 0.500, NOT_TAA7);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[6], 1.000, 0.500, NOT_TAA6);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[5], 1.000, 0.500, NOT_TAA5);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[4], 1.000, 0.500, NOT_TAA4);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[3], 1.000, 0.500, NOT_TAA3);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[2], 1.000, 0.500, NOT_TAA2);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[1], 1.000, 0.500, NOT_TAA1);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, posedge TAA[0], 1.000, 0.500, NOT_TAA0);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[9], 1.000, 0.500, NOT_TAA9);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[8], 1.000, 0.500, NOT_TAA8);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[7], 1.000, 0.500, NOT_TAA7);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[6], 1.000, 0.500, NOT_TAA6);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[5], 1.000, 0.500, NOT_TAA5);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[4], 1.000, 0.500, NOT_TAA4);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[3], 1.000, 0.500, NOT_TAA3);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[2], 1.000, 0.500, NOT_TAA2);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[1], 1.000, 0.500, NOT_TAA1);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0, negedge TAA[0], 1.000, 0.500, NOT_TAA0);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[7], 1.000, 0.500, NOT_TDA7);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[6], 1.000, 0.500, NOT_TDA6);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[5], 1.000, 0.500, NOT_TDA5);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[4], 1.000, 0.500, NOT_TDA4);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[3], 1.000, 0.500, NOT_TDA3);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[2], 1.000, 0.500, NOT_TDA2);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[1], 1.000, 0.500, NOT_TDA1);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, posedge TDA[0], 1.000, 0.500, NOT_TDA0);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[7], 1.000, 0.500, NOT_TDA7);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[6], 1.000, 0.500, NOT_TDA6);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[5], 1.000, 0.500, NOT_TDA5);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[4], 1.000, 0.500, NOT_TDA4);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[3], 1.000, 0.500, NOT_TDA3);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[2], 1.000, 0.500, NOT_TDA2);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[1], 1.000, 0.500, NOT_TDA1);
    $setuphold(posedge CLKA &&& TENAeq0andTCENAeq0andTWENAeq0, negedge TDA[0], 1.000, 0.500, NOT_TDA0);
    $setuphold(posedge CLKB, posedge TENB, 1.000, 0.500, NOT_TENB);
    $setuphold(posedge CLKB, negedge TENB, 1.000, 0.500, NOT_TENB);
    $setuphold(posedge CLKB &&& TENBeq0, posedge TCENB, 1.000, 0.500, NOT_TCENB);
    $setuphold(posedge CLKB &&& TENBeq0, negedge TCENB, 1.000, 0.500, NOT_TCENB);
    $setuphold(posedge RET1N &&& TENBeq0, negedge TCENB, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TWENB, 1.000, 0.500, NOT_TWENB);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TWENB, 1.000, 0.500, NOT_TWENB);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[9], 1.000, 0.500, NOT_TAB9);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[8], 1.000, 0.500, NOT_TAB8);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[7], 1.000, 0.500, NOT_TAB7);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[6], 1.000, 0.500, NOT_TAB6);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[5], 1.000, 0.500, NOT_TAB5);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[4], 1.000, 0.500, NOT_TAB4);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[3], 1.000, 0.500, NOT_TAB3);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[2], 1.000, 0.500, NOT_TAB2);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[1], 1.000, 0.500, NOT_TAB1);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, posedge TAB[0], 1.000, 0.500, NOT_TAB0);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[9], 1.000, 0.500, NOT_TAB9);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[8], 1.000, 0.500, NOT_TAB8);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[7], 1.000, 0.500, NOT_TAB7);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[6], 1.000, 0.500, NOT_TAB6);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[5], 1.000, 0.500, NOT_TAB5);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[4], 1.000, 0.500, NOT_TAB4);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[3], 1.000, 0.500, NOT_TAB3);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[2], 1.000, 0.500, NOT_TAB2);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[1], 1.000, 0.500, NOT_TAB1);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0, negedge TAB[0], 1.000, 0.500, NOT_TAB0);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[7], 1.000, 0.500, NOT_TDB7);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[6], 1.000, 0.500, NOT_TDB6);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[5], 1.000, 0.500, NOT_TDB5);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[4], 1.000, 0.500, NOT_TDB4);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[3], 1.000, 0.500, NOT_TDB3);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[2], 1.000, 0.500, NOT_TDB2);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[1], 1.000, 0.500, NOT_TDB1);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, posedge TDB[0], 1.000, 0.500, NOT_TDB0);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[7], 1.000, 0.500, NOT_TDB7);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[6], 1.000, 0.500, NOT_TDB6);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[5], 1.000, 0.500, NOT_TDB5);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[4], 1.000, 0.500, NOT_TDB4);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[3], 1.000, 0.500, NOT_TDB3);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[2], 1.000, 0.500, NOT_TDB2);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[1], 1.000, 0.500, NOT_TDB1);
    $setuphold(posedge CLKB &&& TENBeq0andTCENBeq0andTWENBeq0, negedge TDB[0], 1.000, 0.500, NOT_TDB0);
    $setuphold(posedge CLKA &&& opopTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cpcpandopopTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cpcp, posedge RET1N, 1.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKA &&& opopTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cpcpandopopTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cpcp, negedge RET1N, 1.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKB &&& opopTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cpcpandopopTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cpcp, posedge RET1N, 1.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKB &&& opopTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cpcpandopopTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cpcp, negedge RET1N, 1.000, 0.500, NOT_RET1N);
    $setuphold(posedge CENA, negedge RET1N, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CENB, negedge RET1N, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge TCENA, negedge RET1N, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge TCENB, negedge RET1N, 0.000, 0.500, NOT_RET1N);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge STOVA, 1.000, 0.500, NOT_STOVA);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge STOVA, 1.000, 0.500, NOT_STOVA);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge STOVB, 1.000, 0.500, NOT_STOVB);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge STOVB, 1.000, 0.500, NOT_STOVB);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, posedge COLLDISN, 1.000, 0.500, NOT_COLLDISN);
    $setuphold(posedge CLKA &&& opTENAeq1andCENAeq0cporopTENAeq0andTCENAeq0cp, negedge COLLDISN, 1.000, 0.500, NOT_COLLDISN);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, posedge COLLDISN, 1.000, 0.500, NOT_COLLDISN);
    $setuphold(posedge CLKB &&& opTENBeq1andCENBeq0cporopTENBeq0andTCENBeq0cp, negedge COLLDISN, 1.000, 0.500, NOT_COLLDISN);
  endspecify


endmodule
`endcelldefine
`endif
`timescale 1ns/1ps
module sram_BRIEF_lb_error_injection (Q_out, Q_in, CLK, A, CEN, WEN, BEN, TQ);
   output [7:0] Q_out;
   input [7:0] Q_in;
   input CLK;
   input [9:0] A;
   input CEN;
   input WEN;
   input BEN;
   input [7:0] TQ;
   parameter LEFT_RED_COLUMN_FAULT = 2'd1;
   parameter RIGHT_RED_COLUMN_FAULT = 2'd2;
   parameter NO_RED_FAULT = 2'd0;
   reg [7:0] Q_out;
   reg entry_found;
   reg list_complete;
   reg [17:0] fault_table [39:0];
   reg [17:0] fault_entry;
initial
begin
   `ifdef DUT
      `define pre_pend_path TB.DUT_inst.CHIP
   `else
       `define pre_pend_path TB.CHIP
   `endif
   `ifdef ARM_NONREPAIRABLE_FAULT
      `pre_pend_path.SMARCHCHKBVCD_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST.u1.add_fault(10'd37,3'd6,2'd1,2'd0);
   `endif
end
   task add_fault;
   //This task injects fault in memory
   //In order to inject fault in redundant column for Bit 0 to 3, column address
   //should have value in range of 12 to 15
   //In order to inject fault in redundant column for Bit 4 to 7, column address
   //should have value in range of 0 to 3
      input [9:0] address;
      input [2:0] bitPlace;
      input [1:0] fault_type;
      input [1:0] red_fault;
 
      integer i;
      reg done;
   begin
      done = 1'b0;
      i = 0;
      while ((!done) && i < 39)
      begin
         fault_entry = fault_table[i];
         if (fault_entry[0] === 1'b0 || fault_entry[0] === 1'bx)
         begin
            fault_entry[0] = 1'b1;
            fault_entry[2:1] = red_fault;
            fault_entry[4:3] = fault_type;
            fault_entry[7:5] = bitPlace;
            fault_entry[17:8] = address;
            fault_table[i] = fault_entry;
            done = 1'b1;
         end
         i = i+1;
      end
   end
   endtask
//This task removes all fault entries injected by user
task remove_all_faults;
   integer i;
begin
   for (i = 0; i < 40; i=i+1)
   begin
      fault_entry = fault_table[i];
      fault_entry[0] = 1'b0;
      fault_table[i] = fault_entry;
   end
end
endtask
task bit_error;
// This task is used to inject error in memory and should be called
// only from current module.
//
// This task injects error depending upon fault type to particular bit
// of the output
   inout [7:0] q_int;
   input [1:0] fault_type;
   input [2:0] bitLoc;
begin
   if (fault_type === 2'd0)
      q_int[bitLoc] = 1'b0;
   else if (fault_type === 2'd1)
      q_int[bitLoc] = 1'b1;
   else
      q_int[bitLoc] = ~q_int[bitLoc];
end
endtask
task error_injection_on_output;
// This function goes through error injection table for every
// read cycle and corrupts Q output if fault for the particular
// address is present in fault table
//
// If fault is redundant column is detected, this task corrupts
// Q output in read cycle
//
// If fault is repaired using repair bus, this task does not
// courrpt Q output in read cycle
//
   output [7:0] Q_output;
   reg list_complete;
   integer i;
   reg [5:0] row_address;
   reg [3:0] column_address;
   reg [2:0] bitPlace;
   reg [1:0] fault_type;
   reg [1:0] red_fault;
   reg valid;
begin
   entry_found = 1'b0;
   list_complete = 1'b0;
   i = 0;
   Q_output = Q_in;
   while(!list_complete)
   begin
      fault_entry = fault_table[i];
      {row_address, column_address, bitPlace, fault_type, red_fault, valid} = fault_entry;
      i = i + 1;
      if (valid == 1'b1)
      begin
         if (red_fault === NO_RED_FAULT)
         begin
            if (row_address == A[9:4] && column_address == A[3:0])
            begin
               if (bitPlace < 4)
                  bit_error(Q_output,fault_type, bitPlace);
               else if (bitPlace >= 4 )
                  bit_error(Q_output,fault_type, bitPlace);
            end
         end
      end
      else
         list_complete = 1'b1;
      end
   end
   endtask
   always @ (Q_in or CLK or A or CEN or WEN or BEN or TQ)
   begin
   if (CEN === 1'b0 && &WEN === 1'b1 && BEN === 1'b1)
      error_injection_on_output(Q_out);
   else if (BEN === 1'b0)
      Q_out = TQ;
   else
      Q_out = Q_in;
   end
endmodule
