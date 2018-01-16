module in_port (
	sw7,sw6,sw5,sw4,sw3,sw2,sw1,sw0,out
);

	input sw7,sw6,sw5,sw4,sw3,sw2,sw1,sw0;
	output [31:0] out;

	assign out[7] = sw7;
	assign out[6] = sw6;
	assign out[5] = sw5;
	assign out[4] = sw4;
	assign out[3] = sw3;
	assign out[2] = sw2;
	assign out[1] = sw1;
	assign out[0] = sw0;
	
endmodule