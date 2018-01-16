module simple_vga_game (
	input up,
	input reset,
	input clk,
	input sw9,
	input sw8,
	output HS,
	output VS,
	output reg[7:0] VGA_R,
	output reg[7:0] VGA_G,
	output reg[7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [6:0] hex0,
	output [6:0] hex1,
	output [6:0] hex4,
	output [6:0] hex5
);
	//Hcnt, Vcnt for vga
	wire[9:0] Hcnt;
	wire[9:0] Vcnt;
	
	//bird(left, top, right, bottom)
	reg[9:0] birdhead_left_init, birdhead_right_init, birdhead_top_init, birdhead_bottom_init;
	reg[9:0] birdbody_left_init, birdbody_right_init, birdbody_top_init, birdbody_bottom_init;
	reg[9:0] birdleg_left_init, birdleg_right_init, birdleg_top_init, birdleg_bottom_init;
	
	reg[9:0] birdhead_left, birdhead_right, birdhead_top, birdhead_bottom;
	reg[9:0] birdbody_left, birdbody_right, birdbody_top, birdbody_bottom;
	reg[9:0] birdleg_left, birdleg_right, birdleg_top, birdleg_bottom;
	
	//obstacle
	parameter obstacle_num = 6;
	reg[9:0] obstacle_left [5:0], obstacle_width [5:0], obstacle_blank_top [5:0], obstacle_blank_height [5:0];
	
	initial
	begin
		//head
		birdhead_left_init <= 10'd70;
		birdhead_right_init <= 10'd80;
		birdhead_top_init <= 10'd220;
		birdhead_bottom_init <= 10'd230;
		//body
		birdbody_left_init <= 10'd60;
		birdbody_right_init <= 10'd80;
		birdbody_top_init <= 10'd230;
		birdbody_bottom_init <= 10'd250;
		//leg
		birdleg_left_init <= 10'd65;
		birdleg_right_init <= 10'd75;
		birdleg_top_init <= 10'd250;
		birdleg_bottom_init <= 10'd260;
		//obstacle
		obstacle_left[0] <= 10'd210;
		obstacle_width[0] <= 10'd30;
		obstacle_blank_top[0] <= 10'd150;
		obstacle_blank_height[0] <= 10'd110;
		
		obstacle_left[1] <= 10'd360;
		obstacle_width[1] <= 10'd30;
		obstacle_blank_top[1] <= 10'd250;
		obstacle_blank_height[1] <= 10'd100;
		
		obstacle_left[2] <= 10'd510;
		obstacle_width[2] <= 10'd35;
		obstacle_blank_top[2] <= 10'd300;
		obstacle_blank_height[2] <= 10'd110;
		
		obstacle_left[3] <= 10'd660;
		obstacle_width[3] <= 10'd30;
		obstacle_blank_top[3] <= 10'd50;
		obstacle_blank_height[3] <= 10'd100;
		
		obstacle_left[4] <= 10'd810;
		obstacle_width[4] <= 10'd25;
		obstacle_blank_top[4] <= 10'd200;
		obstacle_blank_height[4] <= 10'd90;
		
		obstacle_left[5] <= 10'd960;
		obstacle_width[5] <= 10'd40;
		obstacle_blank_top[5] <= 10'd80;
		obstacle_blank_height[5] <= 10'd100;
		
		//score
		score <= 0;
		history_score <= 0;
		
		//finish
		finish <= 0;
	end

	reg clk_25M;
	//generate a half frequency clock of 25MHz
	always@(posedge(clk))
	begin
		clk_25M <= ~clk_25M;
	end
	
	//generate 200ms clock
	reg[31:0] counter_200ms;
	reg clk_200ms;
	parameter COUNT_200ms = 4999999;
	always@(posedge(clk))
	begin
		if (counter_200ms == COUNT_200ms)
		begin
			counter_200ms = 0;
			clk_200ms = ~clk_200ms;
		end
		else
		begin
			counter_200ms = counter_200ms + 1;
		end
	end
	
	//generate 500ms clock
	reg[31:0] counter_500ms;
	reg clk_500ms;
	parameter COUNT_500ms = 12999999;
	always@(posedge(clk))
	begin
		if (counter_500ms == COUNT_500ms)
		begin
			counter_500ms = 0;
			clk_500ms = ~clk_500ms;
		end
		else
		begin
			counter_500ms = counter_500ms + 1;
		end
	end
	
	//sw9 for up_distance + 10, sw8 for up_distance + 2
	reg[9:0] extra_up;
	reg[9:0] extra_down;
	always@(posedge clk_25M)
	begin
		extra_up = 0;
		extra_down = 0;
		if (sw9 == 1)
			extra_up = 10;
		if (sw8 == 1)
			extra_down = 2;
	end
	
	//up and down
	parameter up_distance = 30;
	reg[9:0] up_total;
	always@(posedge(up) or negedge(reset))
	begin
		if (!reset)
			up_total = 0;
		else
			up_total = up_total + up_distance + extra_up;
	end
	
	parameter down_distance = 10;
	reg[9:0] down_total;
	always@(posedge(clk_200ms) or negedge(reset))
	begin
		if (!reset)
			down_total = 0;
		else
			down_total = down_total + down_distance + extra_down;
	end
	
	//refresh obstacle pos & get score
	integer j;
	parameter obstacle_move_speed = 10;
	reg[31:0] score;
	reg[31:0] history_score;
	always@(posedge(clk_200ms) or negedge(reset))
	begin
		if (!reset)
		begin
			obstacle_left[0] <= 10'd210;
			obstacle_width[0] <= 10'd30;
			obstacle_blank_top[0] <= 10'd150;
			obstacle_blank_height[0] <= 10'd110;
			
			obstacle_left[1] <= 10'd360;
			obstacle_width[1] <= 10'd30;
			obstacle_blank_top[1] <= 10'd250;
			obstacle_blank_height[1] <= 10'd100;
			
			obstacle_left[2] <= 10'd510;
			obstacle_width[2] <= 10'd35;
			obstacle_blank_top[2] <= 10'd300;
			obstacle_blank_height[2] <= 10'd110;
			
			obstacle_left[3] <= 10'd660;
			obstacle_width[3] <= 10'd30;
			obstacle_blank_top[3] <= 10'd50;
			obstacle_blank_height[3] <= 10'd100;
			
			obstacle_left[4] <= 10'd810;
			obstacle_width[4] <= 10'd25;
			obstacle_blank_top[4] <= 10'd200;
			obstacle_blank_height[4] <= 10'd90;
			
			obstacle_left[5] <= 10'd960;
			obstacle_width[5] <= 10'd40;
			obstacle_blank_top[5] <= 10'd80;
			obstacle_blank_height[5] <= 10'd100;
			
			score = 0;
		end
		else
		begin
			if (finish == 0)
			begin
				for (j = 0; j < obstacle_num; j = j + 1)
				begin
					obstacle_left[j] = obstacle_left[j] - obstacle_move_speed;
					if (obstacle_left[j] <= 30)
					begin
						obstacle_left[j] = obstacle_left[j] + obstacle_num * 150;
						score = score + 1;
						history_score = score > history_score ? score : history_score;
					end
				end
			end
		end
	end
	
	//refresh bird pos
	always@(posedge clk_25M)
	begin
		if (finish == 0)
		begin
			//head
			birdhead_left <= birdhead_left_init;
			birdhead_right <= birdhead_right_init;
			birdhead_top <= birdhead_top_init - up_total + down_total;
			birdhead_bottom <= birdhead_bottom_init - up_total + down_total;
			//body
			birdbody_left <= birdbody_left_init;
			birdbody_right <= birdbody_right_init;
			birdbody_top <= birdbody_top_init - up_total + down_total;
			birdbody_bottom <= birdbody_bottom_init - up_total + down_total;
			//leg
			birdleg_left <= birdleg_left_init;
			birdleg_right <= birdleg_right_init;
			birdleg_top <= birdleg_top_init - up_total + down_total;
			birdleg_bottom <= birdleg_bottom_init - up_total + down_total;
		end
	end
	
	vga_display screen(
	.clk(clk_25M),//50MHZ
	.reset(reset),
	.Hcnt(Hcnt),
	.Vcnt(Vcnt),
	.hs(HS),
	.vs(VS),
	.blank(VGA_BLANK_N),
	.vga_clk(VGA_CLK)
	);
	
	out_port_seg historyScoreboard(
	.in(history_score),
	.out1(hex5),
	.out0(hex4)
	);
	
	out_port_seg scoreboard(
	.in(score),
	.out1(hex1),
	.out0(hex0)
	);
	
	//game over
	integer k;
	reg finish;
	always@(posedge (clk_25M) or negedge(reset))
	begin
		if (!reset)
			finish = 0;
		else
		begin
			if (finish == 0)
			begin
				//out of screen
				if (birdhead_top <= 5 || birdleg_bottom >= 475)
				begin
					finish = 1;
				end
				//touch obstacle
				else
				begin
					for (k = 0; k < obstacle_num; k = k + 1)
					begin
						if ((Hcnt >= obstacle_left[k] && Hcnt < obstacle_left[k] + obstacle_width[k])
						&& (Vcnt <= obstacle_blank_top[k] || Vcnt >= obstacle_blank_top[k] + obstacle_blank_height[k]))
						begin
							if (Hcnt >= birdhead_left && Hcnt < birdhead_right 
								&& Vcnt >= birdhead_top && Vcnt < birdhead_bottom)
							begin
								finish = 1;
							end
							else if (Hcnt >= birdbody_left && Hcnt < birdbody_right 
								&& Vcnt >= birdbody_top && Vcnt < birdbody_bottom)
							begin
								finish = 1;
							end
							else if (Hcnt >= birdleg_left && Hcnt < birdleg_right 
								&& Vcnt >= birdleg_top && Vcnt < birdleg_bottom)
							begin
								finish = 1;
							end
						end
					end
				end
			end
		end
	end
	
	//assign color
	integer i;
	always@(posedge clk_25M)
	begin
		if (finish == 0)
		begin
			//birdhead
			if (Hcnt >= birdhead_left && Hcnt < birdhead_right 
				&& Vcnt >= birdhead_top && Vcnt < birdhead_bottom)
			begin
				VGA_R = 8'd0;
				VGA_G = 8'd0;
				VGA_B = 8'd0;
			end
			//birdbody
			else if (Hcnt >= birdbody_left && Hcnt < birdbody_right 
				&& Vcnt >= birdbody_top && Vcnt < birdbody_bottom)
			begin
				VGA_R = 8'd210;
				VGA_G = 8'd80;
				VGA_B = 8'd80;
			end
			//birdleg
			else if (Hcnt >= birdleg_left && Hcnt < birdleg_right 
				&& Vcnt >= birdleg_top && Vcnt < birdleg_bottom)
			begin
				VGA_R = 8'd0;
				VGA_G = 8'd0;
				VGA_B = 8'd0;
			end
			//background
			else
			begin
				//sky
				if (Vcnt <= 150)
				begin
					VGA_R = 8'd135;
					VGA_G = 8'd206;
					VGA_B = 8'd250;
				end
				//ground
				if (Vcnt > 150)
				begin
					VGA_R = 8'd221;
					VGA_G = 8'd169;
					VGA_B = 8'd105;
				end
				
				//obstacle
				for (i = 0; i < obstacle_num; i = i + 1)
				begin
					if ((Hcnt >= obstacle_left[i] && Hcnt < obstacle_left[i] + obstacle_width[i])
						&& (Vcnt <= obstacle_blank_top[i] || Vcnt >= obstacle_blank_top[i] + obstacle_blank_height[i]))
					begin
						VGA_R = 8'd80;
						VGA_G = 8'd255;
						VGA_B = 8'd80;
					end
				end
			end
		end
		//game over
		else
		begin
			VGA_R = 8'd255;
			VGA_G = 8'd128;
			VGA_B = 8'd128;
		end
	end

endmodule
