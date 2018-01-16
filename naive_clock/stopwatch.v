module stopwatch(
	CLOCK_50, key_reset, key_start_pause, key_display_stop,
	hex0, hex1, hex2, hex3, hex4, hex5
);

	input CLOCK_50, key_reset, key_start_pause, key_display_stop;
	output [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
	
	//fir clock 40HZ
	parameter COUNT_40HZ = 625999;
	//for clock 100HZ
	parameter COUNT_100HZ = 249999;
	
	reg [3:0] minute_display_high;
	reg [3:0] minute_display_low;
	reg [3:0] second_display_high;
	reg [3:0] second_display_low;
	reg [3:0] msecond_display_high;
	reg [3:0] msecond_display_low;
	
	reg [3:0] minute_counter_high;
	reg [3:0] minute_counter_low;
	reg [3:0] second_counter_high;
	reg [3:0] second_counter_low;
	reg [3:0] msecond_counter_high;
	reg [3:0] msecond_counter_low;
	
	reg counter_stop, display_stop;
	wire counter, display;
	
	//10ms
	reg [31:0] counter_50M;
	
	//50ms
	reg [31:0] counter_250M;
	
	//100HZ clock
	reg CLOCK_100HZ;
	//40HZ clock
	reg CLOCK_40HZ;
	
	reg reset_1_time;
	reg [31:0] counter_reset;
	
	reg start_1_time;
	reg [31:0] counter_start;
	
	reg display_1_time;
	reg [31:0] counter_display;
	
	sevenseg LED8_minute_display_high(minute_display_high, hex5);
	sevenseg LED8_minute_display_low(minute_display_low, hex4);
	
	sevenseg LED8_second_display_high(second_display_high, hex3);
	sevenseg LED8_second_display_low(second_display_low, hex2);
	
	sevenseg LED8_msecond_display_high(msecond_display_high, hex1);
	sevenseg LED8_msecond_display_low(msecond_display_low, hex0);	

	
	eliminate_jitter ej_counter(.CLOCK(CLOCK_40HZ), .RESET(key_reset), .key_in(key_start_pause), .key_out(counter));
	eliminate_jitter ej_display(.CLOCK(CLOCK_40HZ), .RESET(key_reset), .key_in(key_display_stop), .key_out(display));

	//produce 10ms(100HZ) clock
	always @ (posedge CLOCK_50)
		begin 
			if (counter_50M == COUNT_100HZ)
				begin
					counter_50M <= 0;
					CLOCK_100HZ <= ~CLOCK_100HZ;
				end
			
			else
				begin
					counter_50M <= counter_50M + 1;
				end
		end
		
	//produce 25ms(40HZ) clock
	always @ (posedge CLOCK_50)
		begin 
			if (counter_250M == COUNT_40HZ)
				begin
					counter_250M <= 0;
					CLOCK_40HZ <= ~CLOCK_40HZ;
				end
			
			else
				begin
					counter_250M <= counter_250M + 1;
				end
		end
		
	always @ (posedge key_start_pause)
		begin
			if (!counter)
				begin
					counter_stop <= ~counter_stop;
				end
		end
	
	always @ (posedge key_display_stop)
		begin
			if (!display)
				begin
					display_stop <= ~display_stop;
				end
		end
	
	always @ (posedge CLOCK_100HZ)
		begin
			//reset
			if (~key_reset)
				begin
					msecond_counter_low <= 0;
					msecond_counter_high <= 0;
					second_counter_low <= 0;
					second_counter_high <= 0;
					minute_counter_low <= 0;
					minute_counter_high <= 0;
					msecond_display_low <=0;
					msecond_display_high <= 0;
					second_display_low <= 0;
					second_display_high <= 0;
					minute_display_low <= 0;
					minute_display_high <= 0;
				end
				
			//update counter
			if (~counter_stop)
				begin
					if (msecond_counter_low == 4'h9)
						begin
							msecond_counter_low <= 4'h0;
							msecond_counter_high <= msecond_counter_high + 4'h1;
						end
					
					else
						begin
							msecond_counter_low <= msecond_counter_low + 4'h1;
						end
					
					if (msecond_counter_high == 4'ha)
						begin
							msecond_counter_high <= 4'h0;
							second_counter_low <= second_counter_low + 4'h1;
						end
						
					if (second_counter_low == 4'ha)
						begin 
							second_counter_low <= 4'h0;
							second_counter_high <= second_counter_high + 4'h1;
						end
						
					if (second_counter_high == 4'h6)
						begin
							second_counter_high <= 4'h0;
							minute_counter_low <= minute_counter_low + 4'h1;
						end
						
					if (minute_counter_low == 4'ha)
						begin
							minute_counter_low <= 4'h0;
							minute_counter_high <= minute_counter_high + 4'h1;
						end
				end
				
			//update display
			if (~display_stop)
				begin
					msecond_display_low <= msecond_counter_low;
					msecond_display_high <= msecond_counter_high;
					second_display_low <= second_counter_low;
					second_display_high <= second_counter_high;
					minute_display_low <= minute_counter_low;
					minute_display_high <= minute_counter_high;
				end
		end
endmodule
	
	
	
	