`include "/opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver/DW_div.v"
module DW_div_inst (a, b, quotient, remainder, divide_by_0);

  parameter width    = 8;
  parameter tc_mode  = 0;
  parameter rem_mode = 1; // corresponds to "%" in Verilog

  input  [width-1 : 0] a;
  input  [width-1 : 0] b;
  output [width-1 : 0] quotient;
  output [width-1 : 0] remainder;
  output               divide_by_0;

  // Please add +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator
  // command line (for simulation).
  wire [width-1:0] b_div;
  assign b_div = b == 0 ? 1 : b;
  
  // instance of DW_div
  DW_div #(width, width, tc_mode, rem_mode)
    U1 (.a(a), .b(b_div),
        .quotient(quotient), .remainder(remainder),
        .divide_by_0(divide_by_0));
endmodule
