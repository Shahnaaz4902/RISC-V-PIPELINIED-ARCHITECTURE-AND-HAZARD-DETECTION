module InstructionMemory #(
 
    parameter INIT_FILE = "q1.dat"
) (
    input [31:0] readAddr,
    output [31:0] inst
);
    
   

    reg [7:0] insts [127:0];
    
    assign inst = (readAddr >= 128) ? 32'b0 : {insts[readAddr], insts[readAddr + 1], insts[readAddr + 2], insts[readAddr + 3]};

    initial begin
		 insts[0] = 8'b0;   insts[1] = 8'b0;   insts[2] = 8'd127;   insts[3] = 8'b0;
		 insts[4] = 8'b0;   insts[5] = 8'b0;   insts[6] = 8'b0;   insts[7] = 8'b0;
		 insts[8] = 8'b0;   insts[9] = 8'b0;   insts[10] = 8'b0;  insts[11] = 8'b0;
		 insts[12] = 8'b0;  insts[13] = 8'b0;  insts[14] = 8'b0;  insts[15] = 8'b0;
		 insts[16] = 8'b0;  insts[17] = 8'b0;  insts[18] = 8'b0;  insts[19] = 8'b0;
		 insts[20] = 8'b0;  insts[21] = 8'b0;  insts[22] = 8'b0;  insts[23] = 8'b0;
		 insts[24] = 8'b0;  insts[25] = 8'b0;  insts[26] = 8'b0;  insts[27] = 8'b0;
		 insts[28] = 8'b0;  insts[29] = 8'b0;  insts[30] = 8'b0;  insts[31] = 8'b0;
		 insts[32] = 8'b0;  insts[33] = 8'b0;  insts[34] = 8'b0;  insts[35] = 8'b0;
		 insts[36] = 8'b0;  insts[37] = 8'b0;  insts[38] = 8'b0;  insts[39] = 8'b0;
		 insts[40] = 8'b0;  insts[41] = 8'b0;  insts[42] = 8'b0;  insts[43] = 8'b0;
		 insts[44] = 8'b0;  insts[45] = 8'b0;  insts[46] = 8'b0;  insts[47] = 8'b0;
		 insts[48] = 8'b0;  insts[49] = 8'b0;  insts[50] = 8'b0;  insts[51] = 8'b0;
		 insts[52] = 8'b0;  insts[53] = 8'b0;  insts[54] = 8'b0;  insts[55] = 8'b0;
		 insts[56] = 8'b0;  insts[57] = 8'b0;  insts[58] = 8'b0;  insts[59] = 8'b0;
		 insts[60] = 8'b0;  insts[61] = 8'b0;  insts[62] = 8'b0;  insts[63] = 8'b0;
		 insts[64] = 8'b0;  insts[65] = 8'b0;  insts[66] = 8'b0;  insts[67] = 8'b0;
		 insts[68] = 8'b0;  insts[69] = 8'b0;  insts[70] = 8'b0;  insts[71] = 8'b0;
		 insts[72] = 8'b0;  insts[73] = 8'b0;  insts[74] = 8'b0;  insts[75] = 8'b0;
		 insts[76] = 8'b0;  insts[77] = 8'b0;  insts[78] = 8'b0;  insts[79] = 8'b0;
		 insts[80] = 8'b0;  insts[81] = 8'b0;  insts[82] = 8'b0;  insts[83] = 8'b0;
		 insts[84] = 8'b0;  insts[85] = 8'b0;  insts[86] = 8'b0;  insts[87] = 8'b0;
		 insts[88] = 8'b0;  insts[89] = 8'b0;  insts[90] = 8'b0;  insts[91] = 8'b0;
		 insts[92] = 8'b0;  insts[93] = 8'b0;  insts[94] = 8'b0;  insts[95] = 8'b0;
		 insts[96] = 8'b0;  insts[97] = 8'b0;  insts[98] = 8'b0;  insts[99] = 8'b0;
		 insts[100] = 8'b0; insts[101] = 8'b0; insts[102] = 8'b0; insts[103] = 8'b0;
		 insts[104] = 8'b0; insts[105] = 8'b0; insts[106] = 8'b0; insts[107] = 8'b0;
		 insts[108] = 8'b0; insts[109] = 8'b0; insts[110] = 8'b0; insts[111] = 8'b0;
		 insts[112] = 8'b0; insts[113] = 8'b0; insts[114] = 8'b0; insts[115] = 8'b0;
		 insts[116] = 8'b0; insts[117] = 8'b0; insts[118] = 8'b0; insts[119] = 8'b0;
		 insts[120] = 8'b0; insts[121] = 8'b0; insts[122] = 8'b0; insts[123] = 8'b0;
		 insts[124] = 8'b0; insts[125] = 8'b0; insts[126] = 8'b0; insts[127] = 8'b0;
        $readmemb(INIT_FILE, insts);
    end

endmodule

