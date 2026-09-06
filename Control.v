module Control (
    input [6:0] opcode,
    output reg branch,
    output reg memRead,
    output reg memtoReg,
    output reg [1:0] ALUOp,
    output reg memWrite,
    output reg ALUSrc,
    output reg regWrite,
	 output reg jal,
	 output reg jalr
    );

   
    always@(*) begin
		case(opcode) 
			7'b0110011 : {ALUSrc, memtoReg, regWrite, memRead, memWrite, branch, ALUOp, jal, jalr} = 10'b001000_10_00; //R-type
			7'b0010011 : {ALUSrc, memtoReg, regWrite, memRead, memWrite, branch, ALUOp, jal, jalr} = 10'b101000_11_00;//I-type
			7'b0100011 : {ALUSrc, memtoReg, regWrite, memRead, memWrite, branch, ALUOp, jal, jalr} = 10'b100010_00_00; //sw-type
			7'b0000011 : {ALUSrc, memtoReg, regWrite, memRead, memWrite, branch, ALUOp, jal, jalr} = 10'b111100_00_00; //lw-type
			7'b1100011 : {ALUSrc, memtoReg, regWrite, memRead, memWrite, branch, ALUOp, jal, jalr} = 10'b000001_01_00; //B-type
			7'b1101111 : {ALUSrc, memtoReg, regWrite, memRead, memWrite, branch, ALUOp, jal, jalr} = 10'b001000_11_10; //jal-type
			7'b1100111 : {ALUSrc, memtoReg, regWrite, memRead, memWrite, branch, ALUOp, jal, jalr} = 10'b101000_11_01; //jalr-type
			default : {ALUSrc, memtoReg, regWrite, memRead, memWrite, branch, ALUOp, jal, jalr} = 10'b000000_00_00;
		endcase
   end

endmodule




