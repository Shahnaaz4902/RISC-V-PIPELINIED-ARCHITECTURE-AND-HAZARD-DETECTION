module ALU (
    input [3:0] ALUCtl,
    input [31:0] A,B,
    output reg [31:0] ALUOut,
    output reg zero
);
    
    always@(*) begin
	case(ALUCtl)
		4'b0010: begin ALUOut = A + B; zero = (ALUOut == 32'b0) ? 1'b1 : 1'b0; end  
		4'b0110: begin ALUOut = A - B; zero = (ALUOut == 32'b0) ? 1'b1 : 1'b0; end  
		4'b1111: begin ALUOut = A - B; zero = (ALUOut == 32'b0) ? 1'b0 : 1'b1; end  
		4'b0000: begin ALUOut = A & B; zero = (ALUOut == 32'b0) ? 1'b0 : 1'b1; end  
		4'b0001: begin ALUOut = A | B; zero = (ALUOut == 32'b0) ? 1'b0 : 1'b1; end 
		4'b0100: begin ALUOut = A ^ B; zero = (ALUOut == 32'b0) ? 1'b0 : 1'b1; end 
		4'b0011: begin ALUOut = A << B[4:0]; zero = (ALUOut == 32'b0) ? 1'b0 : 1'b1; end
		4'b0101: begin ALUOut = A >> B[4:0]; zero = (ALUOut == 32'b0) ? 1'b0 : 1'b1; end
		4'b1101: begin ALUOut = $signed(A) >>> B[4:0]; zero = (ALUOut == 32'b0) ? 1'b0 : 1'b1; end
		4'b0111: begin ALUOut = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; zero = (ALUOut == 32'b0) ? 1'b0 : 1'b1; end
		4'b1001: begin ALUOut = (A < B) ? 32'b1 : 32'b0; zero = (ALUOut == 32'b0) ? 1'b0 : 1'b1; end
		4'b1010: begin ALUOut = ($signed(A) >= $signed(B)) ? 32'b1 : 32'b0; zero = (ALUOut == 32'b0) ? 1'b0 : 1'b1; end

		default: begin zero = 1'b0; ALUOut = 32'b0; end
	endcase
    end
endmodule

