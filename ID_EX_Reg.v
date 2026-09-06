// =============================================================================
// ID_EX_Reg.v
// -----------------------------------------------------------------------------
// Pipeline register between the ID (Decode) and EX (Execute) stages.
//
// Carries every control signal Control.v produced (needed by EX/MEM/WB
// downstream), the two register-file read values and sign-extended
// immediate (EX needs these as ALU operands), the source/destination
// register NUMBERS (needed by the Hazard Detection Unit and Forwarding
// Unit to compare against later stages), the raw funct3/funct7 bits
// (ALUCtrl now runs in EX, right before the ALU, rather than in ID - purely
// a placement choice, since ALUCtrl is combinational and has no hazard of
// its own either way), and the instruction's own PC (EX now also computes
// the branch target address, since that's where the branch/zero condition
// becomes available - see PipelinedRiscV.v header comment).
//
// Unlike IF_ID_Reg, this register never needs to "hold" its own value - an
// instruction already in ID always either advances into EX or is replaced
// by a bubble (on a load-use stall OR a branch flush - see `flush` below);
// it never needs to stay parked in ID/EX for multiple cycles. So only
// rst/flush are needed here, no stall/hold input.
// =============================================================================
module ID_EX_Reg (
    input  wire        clk,
    input  wire        rst,     // synchronous, active-low
    input  wire        flush,   // clear to bubble: load-use stall OR branch misprediction

    // control
    input  wire        regWrite_in,
    input  wire        memtoReg_in,
    input  wire        memRead_in,
    input  wire        memWrite_in,
    input  wire        ALUSrc_in,
    input  wire        branch_in,
    input  wire [1:0]  ALUOp_in,

    // data
    input  wire [31:0] pc_in,
    input  wire [31:0] readData1_in,
    input  wire [31:0] readData2_in,
    input  wire [31:0] imm_in,
    input  wire [4:0]  rs1_in,
    input  wire [4:0]  rs2_in,
    input  wire [4:0]  rd_in,
    input  wire [2:0]  funct3_in,
    input  wire        funct7_in,

    output reg         regWrite_out,
    output reg         memtoReg_out,
    output reg         memRead_out,
    output reg         memWrite_out,
    output reg         ALUSrc_out,
    output reg         branch_out,
    output reg  [1:0]  ALUOp_out,

    output reg  [31:0] pc_out,
    output reg  [31:0] readData1_out,
    output reg  [31:0] readData2_out,
    output reg  [31:0] imm_out,
    output reg  [4:0]  rs1_out,
    output reg  [4:0]  rs2_out,
    output reg  [4:0]  rd_out,
    output reg  [2:0]  funct3_out,
    output reg         funct7_out
);

    always @(posedge clk) begin
        if (~rst || flush) begin
            regWrite_out  <= 1'b0;
            memtoReg_out  <= 1'b0;
            memRead_out   <= 1'b0;
            memWrite_out  <= 1'b0;
            ALUSrc_out    <= 1'b0;
            branch_out    <= 1'b0;
            ALUOp_out     <= 2'b0;
            pc_out        <= 32'b0;
            readData1_out <= 32'b0;
            readData2_out <= 32'b0;
            imm_out       <= 32'b0;
            rs1_out       <= 5'b0;
            rs2_out       <= 5'b0;
            rd_out        <= 5'b0;
            funct3_out    <= 3'b0;
            funct7_out    <= 1'b0;
        end else begin
            regWrite_out  <= regWrite_in;
            memtoReg_out  <= memtoReg_in;
            memRead_out   <= memRead_in;
            memWrite_out  <= memWrite_in;
            ALUSrc_out    <= ALUSrc_in;
            branch_out    <= branch_in;
            ALUOp_out     <= ALUOp_in;
            pc_out        <= pc_in;
            readData1_out <= readData1_in;
            readData2_out <= readData2_in;
            imm_out       <= imm_in;
            rs1_out       <= rs1_in;
            rs2_out       <= rs2_in;
            rd_out        <= rd_in;
            funct3_out    <= funct3_in;
            funct7_out    <= funct7_in;
        end
    end

endmodule
