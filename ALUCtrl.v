module ALUCtrl (
    input [1:0] ALUOp,
    input funct7,
    input [2:0] funct3,
    output reg [3:0] ALUCtl
);

    
   always@(*) begin
	case(ALUOp)
		
		2'b10, 2'b11 : begin
			case(funct3) 
				3'b000 : if(ALUOp == 2'b11) begin ALUCtl = 4'b0010; end  
					else begin ALUCtl = (funct7 == 1) ? 4'b0110 : 4'b0010; end 
				3'b111 : ALUCtl = 4'b0000; 
				3'b110 : ALUCtl = 4'b0001; 
				3'b001 : ALUCtl = 4'b0011; 
				3'b010 : ALUCtl = 4'b0111; 
				3'b011 : ALUCtl = 4'b1001; 
				3'b100 : ALUCtl = 4'b0100; 
				3'b101 : ALUCtl = (funct7 == 1) ? 4'b1101 : 4'b0101; 
				default: ALUCtl = 4'b0;
			endcase
		end
		2'b00 : begin ALUCtl = 4'b0010; end 
		2'b01 : begin
			case(funct3)
				3'b000 : ALUCtl = 4'b0110; 
				3'b001 : ALUCtl = 4'b1111; 
				3'b100 : ALUCtl = 4'b0111; 
				3'b101 : ALUCtl = 4'b1010; 
				default: ALUCtl = 4'b0;
			endcase
		end
		default: ALUCtl = 4'b0;	
	endcase
   end

endmodule

