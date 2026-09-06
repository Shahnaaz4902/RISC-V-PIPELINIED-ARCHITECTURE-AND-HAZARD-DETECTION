// =============================================================================
// IF_ID_Reg.v
// -----------------------------------------------------------------------------
// Pipeline register between the IF (Fetch) and ID (Decode) stages.
//
// NEW MODULE - the kit already ships generic flip-flop primitives
// (d_ff/d_ff2/d_ff3/d_ff5/d_ff32), but none of them has an enable/hold
// input, only a (synchronous, active-low) reset. Hazard detection
// fundamentally needs the ability to FREEZE this register in place for one
// cycle (load-use stall) as well as clear it to a bubble (branch
// misprediction flush) - neither is possible with a bare d_ff. This module
// bundles the two IF-stage values that need to travel together (the fetched
// instruction and its own PC) into one register with the `stall`/`flush`
// controls hazard handling requires, following the same synchronous,
// active-low reset convention (`~rst` clears) used throughout the rest of
// this kit (PC.v, Register.v, DataMemory.v, d_ff*.v).
//
// stall=1 : hold current outputs (load-use hazard - the ID-stage
//           instruction isn't ready to advance yet, so IF must not
//           overwrite it with the next-fetched instruction this cycle)
// flush=1 : clear to an all-zero bubble (opcode 7'b0000000, which
//           Control.v's default case decodes as a fully-inert NOP: no
//           regWrite/memWrite/memRead/branch) - used on a taken-branch
//           misprediction to squash the wrong-path instruction already
//           sitting in IF.
// If both are asserted in the same cycle, flush takes priority (matches
// this project's actual usage: the two conditions are proven mutually
// exclusive in PipelinedRiscV.v's header comment, since ID_EX_memRead=1 and
// a taken branch in EX cannot both be true of the same EX-stage
// instruction - this priority is just a safe default besides).
// =============================================================================
module IF_ID_Reg (
    input  wire        clk,
    input  wire        rst,     // synchronous, active-low (matches PC.v/Register.v)
    input  wire        stall,   // hold (freeze) - load-use hazard
    input  wire        flush,   // clear to bubble - branch misprediction

    input  wire [31:0] pc_in,
    input  wire [31:0] instr_in,

    output reg  [31:0] pc_out,
    output reg  [31:0] instr_out
);

    always @(posedge clk) begin
        if (~rst || flush) begin
            pc_out    <= 32'b0;
            instr_out <= 32'b0;   // all-zero = NOP (opcode 0000000)
        end else if (stall) begin
            // hold: intentionally no assignment
        end else begin
            pc_out    <= pc_in;
            instr_out <= instr_in;
        end
    end

endmodule
