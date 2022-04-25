`timescale 1ns/10ps
`define CYCLE    10           	         // Modify your clock period here
`define TIME_OUT 1000000           

`ifdef RTL
    `include "FAST.v"
`endif

// `ifdef SYN
//     `include "FFT_syn.v"
//     // `include "tsmc13.v"
//     `define SDF
//     `define SDFFILE "FFT_syn.sdf"
// `endif

// simulation (you can adjust the T to change the test data)
// RTL: ncverilog FAST_tb.v +define+RTL +access+r



module FAST_tb;
    
    integer i, j, f, err;
    reg clk, rst_n;

    reg [7:0] pixel_in [0:307199];
    
    reg start;
    reg [7:0] pixel;
    
    wire [7:0]    o_pixel;
    wire [9:0]    o_coordinate_X;
    wire [9:0]    o_coordinate_Y;

    wire [9:0]    o_orientation;
    wire [7:0]    o_score;
    wire          o_flag;
    wire          o_start;
    wire          o_end;

    FAST_Detector 
    #(
        .WIDTH(12'd640),
        .HEIGHT(12'd640)
    )
    fast0
    (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_pixel(pixel),
        .i_start(start),
        .o_pixel(o_pixel),
        .o_coordinate_X(o_coordinate_X),
        .o_coordinate_Y(o_coordinate_Y),
        .o_orientation(o_orientation),
        .o_score(o_score),
        .o_flag(o_flag),
        .o_start(o_start),
        .o_end(o_end)

    ); 

    // `ifdef SDF
    //     initial $sdf_annotate(`SDFFILE, chip0);
    // `endif
    
    initial	begin
        $readmemh ("../testfile/pixel_in.txt", pixel_in);
    end


    initial begin
        // f = $fopen("fft_o.txt","w");
        clk         = 1'b1;
        rst_n       = 1'b1;  
        i           = 0;
        j           = 0;
        err         = 0;
        #2.5 rst_n=1'b0;         
        #2.5 rst_n=1'b1;

    end

    always begin #(`CYCLE/2) clk = ~clk; end

    initial begin
        $fsdbDumpfile("FAST.fsdb");
        $fsdbDumpvars(0, FAST_tb, "+mda");
    end

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
        if(i < 307200) begin
            if(i == 0) start = 1;
            else start = 0;
            pixel = pixel_in[i];
            i = i+1;      
        end
        else begin
            pixel = 0;
        end
    end

    // always @(posedge clk) begin
    //     if(finish) begin
    //         $fwrite(f,"%b\n", data_out);
    //         // $display("Output %0d: %b ", j , data_out);
            
    //         // allow some error in last bit
    //         if((after_ff[j] != data_out)) begin
    //             if(j < 32)
    //                 $display("There is an error at NO.%d Real part; expected: %b / golden: %b" , j, data_out, after_ff[j]);
    //             else
    //                 $display("There is an error at NO.%d Imag part; expected: %b / golden: %b" , j-32, data_out, after_ff[j]);
    //             err = err + 1;
    //         end
    //         j = j + 1;
    //     end
    //     if(j > 63) begin
    //         if(!err) begin
    //             $display("Finishing Fast fourier transform!");
    //             $display("⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠉⠱⠀⠀⠀⠀⠀⠀");
    //             $display("⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠁⠀⢀⠁⠀⠀⠀⠀⠀⠀");
    //             $display("⠀⠀⠀⠀⠀⠀⠀⠀⠰⠂⠰⠄⢸⠀⠀⠀⠀⠀⠀⠀");
    //             $display("⡄⠄⡀⠀⠀⠀⢀⠊⣈⢊⠁⡄⢸⠀⠀⠀⠀⠀⢀⢀");
    //             $display("⢁⠀⠈⠢⡀⠀⢘⢀⡹⡈⡠⠁⠈⠀⠀⠀⠔⠈⠀⡘");
    //             $display("⠀⢂⠀⠀⠀⢑⠌⢢⣤⣴⣶⡏⠀⡢⠊⠀⠀⠀⠐⠀");
    //             $display("⠀⠀⠢⠀⢀⠊⠠⣟⣉⡩⠉⠀⠈⠀⠀⠀⢁⠊⠀⠀");
    //             $display("⠀⠀⠀⠱⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡐⠁⠀⠀⠀");
    //             $display("⠀⠀⢠⡁⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢁⠀⠀⠀⠀");
    //             $display("⠀⠀⢸⣷⣄⡀⢂⠀⠀⠀⠀⠀⠀⣀⣤⣾⠀⠀⠀⠀");
    //             $display("⠀⠀⠀⢿⣿⣿⣷⣶⣶⣶⣶⣶⣿⣿⣿⡏⠀⠀⠀");⠀
    //             $display("⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⠀⠀⠀⠀⠀");
    //             $display("⠀⠀⠀⠈⡟⠛⢿⠋⠉⠹⠿⣿⡿⠿⠂⠀⠀⠀⠀");⠀
    //             $display("⠀⠀⠀⠀⠐⠀⠂⠀⠀⠀⠐⢄⡀⠂⠀⠀⠀⠀⠀⠀");
    //         end
    //         else begin
    //             $display("AAAAA, There are total %d errors in your design", err);
    //             $display("⠄⠄⠄⠄⠄⠄⠄⠈⠉⠁⠈⠉⠉⠙⠿⣿⣿⣿⣿⣿");
    //             $display("⠄⠄⠄⠄⠄⠄⠄⠄⣀⣀⣀⠄⠄⠄⠄⠄⠹⣿⣿⣿");
    //             $display("⠄⠄⠄⠄⠄⢐⣲⣿⣿⣯⠭⠉⠙⠲⣄⡀⠄⠈⢿⣿");
    //             $display("⠐⠄⠄⠰⠒⠚⢩⣉⠼⡟⠙⠛⠿⡟⣤⡳⡀⠄⠄⢻");
    //             $display("⠄⠄⢀⣀⣀⣢⣶⣿⣦⣭⣤⣭⣵⣶⣿⣿⣏⠄⠄⣿");
    //             $display("⠄⣼⣿⣿⣿⡉⣿⣀⣽⣸⣿⣿⣿⣿⣿⣿⣿⡆⣀⣿");
    //             $display("⢠⣿⣿⣿⠿⠟⠛⠻⢿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣼");
    //             $display("⠄⣿⣿⣿⡆⠄⠄⠄⠄⠳⡈⣿⣿⣿⣿⣿⣿⣿⣿⣿");
    //             $display("⠄⢹⣿⣿⡇⠄⠄⠄⠄⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
    //             $display("⠄⠄⢿⣿⣷⣨⣽⣭⢁⣡⣿⣿⠟⣩⣿⣿⣿⠿⠿⠟");
    //             $display("⠄⠄⠈⡍⠻⣿⣿⣿⣿⠟⠋⢁⣼⠿⠋⠉⠄⠄⠄⠄");
    //             $display("⠄⠄⠄⠈⠴⢬⣙⣛⡥⠴⠂⠄⠄⠄⠄⠄⠄⠄⠄.");
    //         end

    //         $fclose(f);
    //         $finish;
    //     end
    // end
   
endmodule