module MATCH_mem
(
    input           i_clk,
    input           i_rst_n,

    // to memory controller
    input [10:0]   mem1_addr,
    input [291:0]  mem1_wdata,
    input          mem1_wen,
    output logic [291:0]   mem1_rdata,

    input [10:0]   mem2_addr,
    input [291:0]  mem2_wdata,
    input          mem2_wen,
    output logic [291:0]   mem2_rdata,

    // sram interface
    input [19:0]    MATCH_mem1_point_QA,
    output logic          MATCH_mem1_point_WENA,
    output logic [19:0]   MATCH_mem1_point_DA,
    output logic [8:0]    MATCH_mem1_point_AA,

    input [19:0]    MATCH_mem2_point_QA,
    output logic          MATCH_mem2_point_WENA,
    output logic [19:0]   MATCH_mem2_point_DA,
    output logic [8:0]    MATCH_mem2_point_AA,

    input [15:0]    MATCH_mem1_depth_QA,
    output logic          MATCH_mem1_depth_WENA,
    output logic [15:0]   MATCH_mem1_depth_DA,
    output logic [8:0]    MATCH_mem1_depth_AA,

    input [15:0]    MATCH_mem2_depth_QA,
    output logic          MATCH_mem2_depth_WENA,
    output logic [15:0]   MATCH_mem2_depth_DA,
    output logic [8:0]    MATCH_mem2_depth_AA,

    input [31:0]    MATCH_mem1_desc_QA [8],
    output logic          MATCH_mem1_desc_WENA [8],
    output logic [31:0]   MATCH_mem1_desc_DA [8],
    output logic [8:0]    MATCH_mem1_desc_AA [8],

    input [31:0]    MATCH_mem2_desc_QA [8],
    output logic          MATCH_mem2_desc_WENA [8],
    output logic [31:0]   MATCH_mem2_desc_DA [8],
    output logic [8:0]    MATCH_mem2_desc_AA [8]
); 
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            mem1_rdata <= 0;
            mem2_rdata <= 0;

            MATCH_mem1_point_WENA <= 0;
            MATCH_mem1_point_DA <= 0;
            MATCH_mem1_point_AA <= 0;

            MATCH_mem2_point_WENA <= 0;
            MATCH_mem2_point_DA <= 0;
            MATCH_mem2_point_AA <= 0;

            MATCH_mem1_depth_WENA <= 0;
            MATCH_mem1_depth_DA <= 0;
            MATCH_mem1_depth_AA <= 0;

            MATCH_mem2_depth_WENA <= 0;
            MATCH_mem2_depth_DA <= 0;
            MATCH_mem2_depth_AA <= 0;          

            for(int i = 0; i < 8; i = i+1) begin
                MATCH_mem1_desc_WENA[i] <= 0;
                MATCH_mem1_desc_DA[i] <= 0;
                MATCH_mem1_desc_AA[i] <= 0;
                MATCH_mem2_desc_WENA[i] <= 0;
                MATCH_mem2_desc_DA[i] <= 0;
                MATCH_mem2_desc_AA[i] <= 0;
            end

        end
        else begin
            mem1_rdata[291:272] <= MATCH_mem1_point_QA;
            mem2_rdata[291:272] <= MATCH_mem2_point_QA;

            mem1_rdata[271:256] <= MATCH_mem1_depth_QA;
            mem2_rdata[271:256] <= MATCH_mem2_depth_QA;

            for(int i = 0; i < 8; i = i+1) begin
                mem1_rdata[32*i +: 32] <= MATCH_mem1_desc_QA[i];
                mem2_rdata[32*i +: 32] <= MATCH_mem2_desc_QA[i];
            end

            MATCH_mem1_point_WENA <= !mem1_wen;
            MATCH_mem1_point_DA <= mem1_wdata[291:272];
            MATCH_mem1_point_AA <= mem1_addr;

            MATCH_mem2_point_WENA <= !mem2_wen;
            MATCH_mem2_point_DA <= mem2_wdata[291:272];
            MATCH_mem2_point_AA <= mem2_addr;   

            
            MATCH_mem1_depth_WENA <= !mem1_wen;
            MATCH_mem1_depth_DA <= mem1_wdata[271:256];
            MATCH_mem1_depth_AA <= mem1_addr;

            MATCH_mem2_depth_WENA <= !mem2_wen;
            MATCH_mem2_depth_DA <= mem2_wdata[271:256];
            MATCH_mem2_depth_AA <= mem2_addr;   

            for(int i = 0; i < 8; i = i+1) begin
                MATCH_mem1_desc_WENA[i] <= !mem1_wen;
                MATCH_mem1_desc_DA[i] <= mem1_wdata[32*i +: 32];
                MATCH_mem1_desc_AA[i] <= mem1_addr;
                MATCH_mem2_desc_WENA[i] <= !mem2_wen;
                MATCH_mem2_desc_DA[i] <= mem2_wdata[32*i +: 32];
                MATCH_mem2_desc_AA[i] <= mem2_addr;
            end
            
        end
    end
endmodule