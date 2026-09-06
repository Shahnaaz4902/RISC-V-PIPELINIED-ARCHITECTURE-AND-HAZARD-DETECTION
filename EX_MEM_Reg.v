// =============================================================================
// EX_MEM_Reg.v
// -----------------------------------------------------------------------------
// Pipeline register between the EX (Execute) and MEM (Memory) stages.
//
// Carries the ALU result (used as the memory address for loads/stores, and
// as the write-back value for non-load instructions), the already-forwarded
// store-data operand (see PipelinedRiscV.v - the value written to memory on
// a `sw` must itself have gone through the EX-stage forwarding muxes, since
// the source register for store data can itself be hazardous), the
// destination register number, and the control bits MEM/WB still need.
//
// Never stalled or flushed: once an instruction is in EX, in this design it
// always completes (only IF/ID and ID/EX are ever held or squashed - see
// PipelinedRiscV.v header comment for why that is sufcient/correct here).
// =============================================================================
module EX_MEM_Reg (
    input  wire        clk,
    input  wire        rst,    // synchronous, active-low

    input  wire        regWrite_in,
    input  wire        memtoReg_in,
    input  wire        memRead_in,
    input  wire        memWrite_in,

    input  wire [31:0] aluResult_in,
    input  wire [31:0] memWriteData_in,
    input  wire [4:0]  rd_in,

    output reg          regWrite_out,
    output reg          memtoReg_out,
    output reg          memRead_out,
    output reg          memWrite_out,

    output reg  [31:0] aluResult_out,
    output reg  [31:0] memWriteData_out,
    output reg  [4:0]  rd_out
);

    always @(posedge clk) begin
        if (~rst) begin
            regWrite_out     <= 1'b0;
            memtoReg_out     <= 1'b0;
            memRead_out      <= 1'b0;
            memWrite_out     <= 1'b0;
            aluResult_out    <= 32'b0;
            memWriteData_out <= 32'b0;
            rd_out           <= 5'b0;
        end else begin
            regWrite_out     <= regWrite_in;
            memtoReg_out     <= memtoReg_in;
            memRead_out      <= memRead_in;
            memWrite_out     <= memWrite_in;
            aluResult_out    <= aluResult_in;
            memWriteData_out <= memWriteData_in;
            rd_out           <= rd_in;
        end
    end

endmodule
