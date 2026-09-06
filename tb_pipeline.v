// =============================================================================
// tb_pipeline.v
// -----------------------------------------------------------------------------
// Self-checking testbench for the pipelined PipelinedRiscV. Runs three
// programs through three separate DUT instances (one per program, each
// with its own PROGRAM_FILE) and checks the final architectural register
// file (and, for the hazard program, a data-memory word) against values
// computed by the independent, non-pipelined golden model
// (rv32i_golden.py) - i.e. this checks that the pipelined RTL reaches the
// SAME final answer a correct-by-construction sequential interpreter
// reaches, which is exactly what hazard detection/forwarding is for:
// getting a pipelined implementation to behave architecturally identically
// to an unpipelined one despite instructions overlapping in time.
//
//   tb_q1      : q1.dat            - the original demo program (basic
//                functional check across R-type/I-type/load/store)
//   tb_q2      : Q2withhazards.dat - the kit's own hazard-oriented program
//                (exercises 2-apart RAW forwarding)
//   tb_hazard  : hazard_test.dat   - hand-built program exercising every
//                hazard path individually: EX/MEM->EX forwarding (1 apart),
//                MEM/WB->EX forwarding (2 apart), the write-first same-
//                cycle register-file bypass (3 apart), the load-use stall
//                (load immediately followed by its consumer), a load used
//                2 instructions later (no stall needed), store-data
//                forwarding, a not-taken branch (no flush), and a taken
//                branch (2-instruction flush) - see gen_hazard_test.py's
//                header comment for the full register map.
//
// Each DUT also has its `stall` and `branch_taken_EX` internal nets
// monitored and counted, printed at the end, so a reader can see hazard
// detection/forwarding actually fired during simulation rather than just
// trusting the final register values happened to come out right by luck.
//
// This file also folds in what the original tb_riscv_sc.v did (a plain,
// non-self-checking waveform testbench that ran q1.dat and exposed a
// handful of register/memory signals as top-level wires for manual
// inspection). Since dut_q1 below already runs q1.dat - the same program
// tb_riscv_sc.v used - there's no need for a separate 4th DUT instance:
// the "Waveform-inspection probes" section right after dut_q1 just taps
// dut_q1's internals with the same wire names tb_riscv_sc.v had
// (reg_5, reg_6, ... , data_memory4), so you can add them to a waveform
// viewer directly. tb_riscv_sc.v itself is no longer needed once this
// file is in the project.
// =============================================================================
`timescale 1ns/1ps

module tb_pipeline;

    integer total_tests = 0, passed_tests = 0, failed_tests = 0;

    task automatic report(input passed, input [800:0] name);
        begin
            total_tests = total_tests + 1;
            if (passed) begin
                passed_tests = passed_tests + 1;
                $display("PASS: %0s", name);
            end else begin
                failed_tests = failed_tests + 1;
                $display("FAIL: %0s", name);
            end
        end
    endtask

    // =========================================================================
    // DUT 1: q1.dat
    // =========================================================================
    reg clk1 = 0, start1 = 0;
    always #5 clk1 = ~clk1;
    PipelinedRiscV #(.PROGRAM_FILE("q1.dat")) dut_q1 (.clk(clk1), .start(start1));

    integer stall_count_q1, flush_count_q1;
    always @(posedge clk1) begin
        if (start1 && dut_q1.stall) stall_count_q1 = stall_count_q1 + 1;
        if (start1 && dut_q1.branch_taken_EX) flush_count_q1 = flush_count_q1 + 1;
    end

    // =========================================================================
    // Waveform-inspection probes (folded in from the original tb_riscv_sc.v)
    // -----------------------------------------------------------------------
    // Same signals, same names tb_riscv_sc.v exposed - tapped off dut_q1
    // (which runs the same q1.dat program) instead of a separate DUT. Add
    // these to a waveform viewer if you want to eyeball values directly,
    // on top of the automatic PASS/FAIL checking further down.
    // =========================================================================
    wire [31:0] reg_5  = dut_q1.m_Register.regs[5];
    wire [31:0] reg_6  = dut_q1.m_Register.regs[6];
    wire [31:0] reg_7  = dut_q1.m_Register.regs[7];
    wire [31:0] reg_8  = dut_q1.m_Register.regs[8];
    wire [31:0] reg_10 = dut_q1.m_Register.regs[10];
    wire [31:0] reg_11 = dut_q1.m_Register.regs[11];
    wire [31:0] reg_28 = dut_q1.m_Register.regs[28];
    wire [31:0] reg_29 = dut_q1.m_Register.regs[29];
    wire [31:0] reg_31 = dut_q1.m_Register.regs[31];
    wire [31:0] data_memory4 = dut_q1.m_DataMemory.data_memory[reg_8];

    // =========================================================================
    // DUT 2: Q2withhazards.dat
    // =========================================================================
    reg clk2 = 0, start2 = 0;
    always #5 clk2 = ~clk2;
    PipelinedRiscV #(.PROGRAM_FILE("Q2withhazards.dat")) dut_q2 (.clk(clk2), .start(start2));

    integer stall_count_q2, flush_count_q2;
    always @(posedge clk2) begin
        if (start2 && dut_q2.stall) stall_count_q2 = stall_count_q2 + 1;
        if (start2 && dut_q2.branch_taken_EX) flush_count_q2 = flush_count_q2 + 1;
    end

    // =========================================================================
    // DUT 3: hazard_test.dat
    // =========================================================================
    reg clk3 = 0, start3 = 0;
    always #5 clk3 = ~clk3;
    PipelinedRiscV #(.PROGRAM_FILE("hazard_test.dat")) dut_hz (.clk(clk3), .start(start3));

    integer stall_count_hz, flush_count_hz;
    always @(posedge clk3) begin
        if (start3 && dut_hz.stall) stall_count_hz = stall_count_hz + 1;
        if (start3 && dut_hz.branch_taken_EX) flush_count_hz = flush_count_hz + 1;
    end

    // =========================================================================
    // expected values (from rv32i_golden.py)
    // =========================================================================
    reg [31:0] exp_q1 [0:31];
    reg [31:0] exp_q2 [0:31];
    reg [31:0] exp_hz [0:31];

    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            exp_q1[i] = 32'd0;
            exp_q2[i] = 32'd0;
            exp_hz[i] = 32'd0;
        end

        // ---- q1.dat ----
        exp_q1[2]=32'd128; exp_q1[5]=32'd5; exp_q1[6]=32'd10; exp_q1[7]=32'd15;
        exp_q1[8]=32'd4;   exp_q1[10]=32'd5; exp_q1[11]=32'd15; exp_q1[29]=32'd15;
        exp_q1[30]=32'd1;  exp_q1[31]=32'd5;

        // ---- Q2withhazards.dat ----
        exp_q2[2]=32'd128;
        exp_q2[1]=32'd5; exp_q2[2]=32'd10; exp_q2[3]=32'd15; exp_q2[4]=32'd20;
        exp_q2[5]=32'd15; exp_q2[6]=32'd4; exp_q2[7]=32'd15; exp_q2[8]=32'd1; exp_q2[9]=32'd1;

        // ---- hazard_test.dat ----
        exp_hz[2]=32'd128;
        exp_hz[1]=32'd1; exp_hz[2]=32'd2; exp_hz[3]=32'd3; exp_hz[4]=32'd4;
        exp_hz[5]=32'd100; exp_hz[6]=32'd101; exp_hz[7]=32'd102; exp_hz[8]=32'd0; exp_hz[9]=32'd55;
        exp_hz[10]=32'd3; exp_hz[11]=32'd6; exp_hz[12]=32'd6; exp_hz[13]=32'd9;
        exp_hz[14]=32'd1; exp_hz[15]=32'd111; exp_hz[16]=32'd222;
        exp_hz[17]=32'd1; exp_hz[18]=32'd0; exp_hz[19]=32'd0;
        exp_hz[20]=32'd0; exp_hz[21]=32'd1; exp_hz[22]=32'd123; exp_hz[23]=32'd0; exp_hz[24]=32'd2;
        exp_hz[30]=32'd77; exp_hz[31]=32'd77;
    end

    // ---- q2.dat overwrote exp_q2[2] twice above (128 then 10) intentionally
    // left as-is: x2 IS reassigned to 10 by Q2withhazards.dat's own program
    // (`addi x2,x0,10` is its second instruction), so the *final* value of
    // exp_q2[2] correctly ends up 10, not the reset value 128 - the
    // redundant first assignment is harmless and left for documentation
    // symmetry with the reset-value comment in exp_hz/exp_q1.

    reg regs_pass;

    initial begin
        $display("================================================================");
        $display("5-stage pipelined RISC-V - hazard detection / forwarding testbench");
        $display("================================================================");

        stall_count_q1 = 0; flush_count_q1 = 0;
        stall_count_q2 = 0; flush_count_q2 = 0;
        stall_count_hz = 0; flush_count_hz = 0;

        start1 = 0; start2 = 0; start3 = 0;
        repeat (4) @(posedge clk1);
        start1 = 1; start2 = 1; start3 = 1;

        // generous margin: longest program (hazard_test, 31 instructions)
        // plus pipeline fill/drain plus stall/flush overhead comfortably
        // finishes well under 100 cycles; run 150 to be safe.
        repeat (150) @(posedge clk1);
        @(negedge clk1);   // settle past the last posedge before sampling

        // ---- q1.dat ----
        $display("---- q1.dat ----");
        for (i = 0; i < 32; i = i + 1) begin
            regs_pass = (dut_q1.m_Register.regs[i] === exp_q1[i]);
            total_tests = total_tests + 1;
            if (regs_pass) passed_tests = passed_tests + 1; else failed_tests = failed_tests + 1;
            $display("%s: q1 x%0d = %0d (expected %0d)",
                     regs_pass ? "PASS" : "FAIL", i, dut_q1.m_Register.regs[i], exp_q1[i]);
        end
        $display("q1.dat: stalls observed=%0d, branch-flushes observed=%0d (program has no loads-followed-by-use or branches, so 0/0 is expected)",
                  stall_count_q1, flush_count_q1);

        // ---- Q2withhazards.dat ----
        $display("---- Q2withhazards.dat ----");
        for (i = 0; i < 32; i = i + 1) begin
            regs_pass = (dut_q2.m_Register.regs[i] === exp_q2[i]);
            total_tests = total_tests + 1;
            if (regs_pass) passed_tests = passed_tests + 1; else failed_tests = failed_tests + 1;
            $display("%s: Q2 x%0d = %0d (expected %0d)",
                     regs_pass ? "PASS" : "FAIL", i, dut_q2.m_Register.regs[i], exp_q2[i]);
        end
        $display("Q2withhazards.dat: stalls observed=%0d, branch-flushes observed=%0d (program has 2-apart RAW hazards but no load-use/branches, so 0/0 is expected)",
                  stall_count_q2, flush_count_q2);

        // ---- hazard_test.dat ----
        $display("---- hazard_test.dat ----");
        for (i = 0; i < 32; i = i + 1) begin
            regs_pass = (dut_hz.m_Register.regs[i] === exp_hz[i]);
            total_tests = total_tests + 1;
            if (regs_pass) passed_tests = passed_tests + 1; else failed_tests = failed_tests + 1;
            $display("%s: hz x%0d = %0d (expected %0d)",
                     regs_pass ? "PASS" : "FAIL", i, dut_hz.m_Register.regs[i], exp_hz[i]);
        end
        report(dut_hz.m_DataMemory.data_memory[4] === 8'd77 &&
               dut_hz.m_DataMemory.data_memory[5] === 8'd0  &&
               dut_hz.m_DataMemory.data_memory[6] === 8'd0  &&
               dut_hz.m_DataMemory.data_memory[7] === 8'd0,
               "hazard_test: mem[4] == 77 (store-data forwarding landed correctly)");
        report(stall_count_hz >= 1,
               "hazard_test: at least 1 load-use stall cycle was actually observed");
        report(flush_count_hz >= 1,
               "hazard_test: at least 1 branch-taken flush was actually observed");
        $display("hazard_test.dat: stalls observed=%0d, branch-flushes observed=%0d",
                  stall_count_hz, flush_count_hz);

        $display("================================================================");
        $display("SUMMARY");
        $display("================================================================");
        $display("Total tests  : %0d", total_tests);
        $display("Passed       : %0d", passed_tests);
        $display("Failed       : %0d", failed_tests);
        if (failed_tests == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TEST(S) FAILED", failed_tests);

        $finish;
    end

    initial begin
        #5000;
        $display("[TIMEOUT] simulation did not finish in time");
        $finish;
    end

endmodule
