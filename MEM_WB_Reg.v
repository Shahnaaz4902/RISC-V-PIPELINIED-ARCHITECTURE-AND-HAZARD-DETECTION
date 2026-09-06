// =============================================================================
// MEM_WB_Reg.v
// -----------------------------------------------------------------------------
// Pipeline register between the MEM (Memory) and WB (Write-Back) stages.
//
// Carries the two candidate write-back values (ALU result, memory read
// data - the final WB-stage mux picks between them using memtoReg, exactly
// as the original single-cycle datapath's m_Mux_WriteData did) and the
// destination register number/write-enable the register file needs.
//
// Never stalled or flushed, same reasoning as EX_MEM_Reg.
// =============================================================================
module MEM_WB_Reg (
    input  wire        clk,
    input  wire        rst,    // synchronous, active-low

    input  wire        regWrite_in,
    input  wire        memtoReg_in,

    input  wire [31:0] aluResult_in,
    input  wire [31:0] memReadData_in,
    input  wire [4:0]  rd_in,

    output reg          regWrite_out,
    output reg          memtoReg_out,

    output reg  [31:0] aluResult_out,
    output reg  [31:0] memReadData_out,
    output reg  [4:0]  rd_out
);

    always @(posedge clk) begin
        if (~rst) begin
            regWrite_out    <= 1'b0;
            memtoReg_out    <= 1'b0;
            aluResult_out   <= 32'b0;
            memReadData_out <= 32'b0;
            rd_out          <= 5'b0;
        end else begin
            regWrite_out    <= regWrite_in;
            memtoReg_out    <= memtoReg_in;
            aluResult_out   <= aluResult_in;
            memReadData_out <= memReadData_in;
            rd_out          <= rd_in;
        end
    end

endmodule
