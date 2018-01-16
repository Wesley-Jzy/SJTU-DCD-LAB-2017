module eliminate_jitter(
	CLOCK, RESET, key_in, 
	key_out
);

	input CLOCK, RESET, key_in;
	output key_out;

	reg key_now, key_pre, key_prepre;

	always @ (posedge CLOCK)
		begin
			if (~RESET)
				begin
					key_now <= 1;
					key_pre <= 1;
					key_prepre <= 1;
				end
			
			else
				begin
					key_prepre <= key_pre;
					key_pre <= key_now;
					key_now <= key_in;
				end
		end
	wire key_out = key_pre | key_prepre;
endmodule