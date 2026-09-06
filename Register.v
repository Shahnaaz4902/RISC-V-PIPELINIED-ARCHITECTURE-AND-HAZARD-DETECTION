module Register (
    input clk,
    input rst,
    input regWrite,
    input [4:0] readReg1,
    input [4:0] readReg2,
    input [4:0] writeReg,
    input [31:0] writeData,
    output [31:0] readData1,
    output [31:0] readData2
);
    reg [31:0] regs [0:31];

    // ------------------------------------------------------------------
    // PIPELINING ADDITION - write-first (same-cycle write-then-read) bypass.
    //
    // In the pipelined datapath, this module is read by the instruction
    // sitting in ID *and* written by the instruction sitting in WB in the
    // very same clock edge. Without this bypass, `regs[readRegX]` would
    // return the pre-write value for one extra cycle (nonblocking-assignment
    // scheduling makes a bare `regs[readReg]` read racy/one-cycle-stale
    // against a same-edge write to the same address), silently breaking any
    // instruction that depends on a result exactly 3 instructions behind it
    // (the one case none of the EX-stage forwarding paths can reach, since
    // they only forward into EX, not into ID). This mirrors standard
    // register-file "write-first" behavior and is required for pipeline
    // correctness, not just an optimization.
    assign readData1 = (readReg1 == 0) ? 32'b0 :
                        (regWrite && writeReg == readReg1) ? writeData : regs[readReg1];
    assign readData2 = (readReg2 == 0) ? 32'b0 :
                        (regWrite && writeReg == readReg2) ? writeData : regs[readReg2];

    always @(posedge clk) begin
        if(~rst) begin
            regs[0] <= 0; regs[1] <= 0; regs[2] <= 32'd128; regs[3] <= 0; 
            regs[4] <= 0; regs[5] <= 0; regs[6] <= 0; regs[7] <= 0; 
            regs[8] <= 0; regs[9] <= 0; regs[10] <= 0; regs[11] <= 0; 
            regs[12] <= 0; regs[13] <= 0; regs[14] <= 0; regs[15] <= 0; 
            regs[16] <= 0; regs[17] <= 0; regs[18] <= 0; regs[19] <= 0; 
            regs[20] <= 0; regs[21] <= 0; regs[22] <= 0; regs[23] <= 0; 
            regs[24] <= 0; regs[25] <= 0; regs[26] <= 0; regs[27] <= 0; 
            regs[28] <= 0; regs[29] <= 0; regs[30] <= 0; regs[31] <= 0;        
        end
        else if(regWrite)
            regs[writeReg] <= (writeReg == 0) ? 0 : writeData;
    end

endmodule

