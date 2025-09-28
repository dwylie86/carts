pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--main entry point of game
function _init()
	score = 0
	lives = 3
	multiplier = 1
	game_state = "playing"
	bricks = {}
	total_bricks_possible=0
	bricks_destroyed_combo=0
	max_combo=0
	
	multi_effects = {
		[1] = {shake=0, color=15},
		[2] = {shake=1, color=10},
		[3] = {shake=2, color=9},
		[4] = {shake=3, color=8}
	}
	
	combo_popup = {
    active = false,
    text = "",
    x = 0,
    y = 64,
    start_time = 0
}
	init_paddle()
	init_ball()
	make_bricks()
	--music(0)
end

function _update()
	if game_state == "playing" then
		move_paddle()
		move_ball()
 		bounce_paddle()
 		lose_dead_ball()
 		check_win()
	elseif game_state == "game_over" then
  		if btnp(❎) then
   		_init()
  		end
	elseif game_state == "win" then
		if btnp(❎) then
			_init()
		end
	end
end

function _draw()
	cls(3)
	
	if game_state == "playing" then
		draw_paddle()
		draw_ball()
		draw_ui()
		foreach(bricks, draw_brick)
		draw_combo_popup()
	elseif game_state == "game_over" then
		print("game over", 64 - #"game over" * 2, 50, 15)
		local score_text = "score: "..score
		print(score_text, 64 - #score_text * 2, 58, 15)
		print("press x to restart", 64 - #"press x to restart" * 2, 66, 15)
	elseif game_state == "win" then
    	print("you win!", 64 - #"you win!" * 2, 42, 11)
    	local score_text = "score: "..score
    	print(score_text, 64 - #score_text * 2, 50, 15)
    	if bricks_destroyed_combo == total_bricks_possible and time() % 0.5 < 0.25 then
    		print("perfect round!", 64 - #"perfect round!" * 2, 58, 11)
		end
    local combo_text = "max combo: "..max_combo
    print(combo_text, 64 - #combo_text * 2, 66, 15)
    print("press x to restart", 64 - #"press x to restart" * 2, 74, 15)
	end	
end
-->8
--paddle functions
function init_paddle()
	pad = {
		x=52,
		y=122,
		w=28,
		h=4,
		s=3
	}
end

function move_paddle()
	if btn(⬅️) then 
		pad.x-=pad.s
	end
	if btn(➡️) then
		pad.x+=pad.s
	end
	if pad.x < 0 then
  		pad.x = 0
 	end
 	if pad.x + pad.w > 128 then
		pad.x = 128 - pad.w
 	end
end

function draw_paddle()
	rectfill(
		pad.x,pad.y,
		pad.x+pad.w,pad.y+pad.h,
		15
		)
end

function bounce_paddle()
    if ball.x >= pad.x - ball.s and 
       ball.x <= pad.x + pad.w + ball.s and
       ball.y >= pad.y - ball.s and 
       ball.y <= pad.y + ball.s then
        
        sfx(0)
        ball.y = pad.y - ball.s - 1
        
        local hit_pos = (ball.x - pad.x) - pad.w/2
        ball.velx = hit_pos * 0.3
        ball.vely = -abs(ball.vely)
    end
end
-->8
--ball functions
function init_ball()
	ball = {
		x=64,
		y=64,
		s=3,
		velx=0,
		vely=0,
		on_paddle=true
	}
end

function draw_ball()
	circfill(
	 ball.x,ball.y,ball.s,15
	)
end

function move_ball()
	if ball.on_paddle then
        ball.x = pad.x + pad.w/2
        ball.y = pad.y - ball.s - 1
        
        if btnp(❎) then
            ball.velx = 2
            ball.vely = -4
            ball.on_paddle = false
        end
    else
		if ball.x + ball.velx < 0 + ball.s or
    	   ball.x + ball.velx > 128 - ball.s then
        	ball.velx *= -1
        	sfx(0)
    	else
        	ball.x += ball.velx
    	end
    
    	if ball.y + ball.vely < 12 + ball.s then
        	ball.vely *= -1
        	sfx(0)
    	else
        	ball.y += ball.vely
    	end
		check_brick_collision()
	end
end

function check_brick_collision()
    for brick in all(bricks) do
        if brick.alive then
            if ball.x + ball.s >= brick.x and
               ball.x - ball.s <= brick.x + brick.w and
               ball.y + ball.s >= brick.y and
               ball.y - ball.s <= brick.y + brick.h then
               handle_brick_hit(brick)
			end   
		end
    end
end

function handle_brick_hit(brick)
	if brick.health > 0 then
    	brick.health -= 1
	    if brick.health == 0 then
    	    brick.alive = false
        	update_combo()
        	update_score(brick)
    	end
	end
	sfx(0)
	ball.vely *= -1
    if ball.vely > 0 then
		ball.y = brick.y + brick.h + ball.s + 1
	else
		ball.y = brick.y - ball.s - 1
    end
    return
end

function update_combo()
	bricks_destroyed_combo += 1
	if bricks_destroyed_combo > max_combo then
   		max_combo = bricks_destroyed_combo
	end
	if bricks_destroyed_combo % 10 == 0 then
		combo_popup.active = true
		combo_popup.text = bricks_destroyed_combo.." combo!"
		combo_popup.start_time = time()
				
		local mult_tier = flr(multiplier)
		combo_popup.color = multi_effects[mult_tier].color
				
		combo_popup.x = rnd(128 - #combo_popup.text * 4)
		combo_popup.y = 64
	end
end

function update_score(brick)
	score += ceil(brick.type * 10 * multiplier)
    multiplier = min(multiplier + 0.25, 4)
end

function lose_dead_ball()      
	if ball.y>128 then             
		if lives>0 then
			sfx(3)             
			lives-=1
			multiplier=1
			if bricks_destroyed_combo > max_combo then
       			max_combo = bricks_destroyed_combo
    		end
			bricks_destroyed_combo=0
			ball.on_paddle=true      
		else
		 game_over() 
 		end    
	end
end

function check_win()
    for brick in all(bricks) do
        if brick.alive and brick.health > 0 then
            return
        end
    end
    game_state = "win"
end
-->8
--scene functions
--level layout
level = {
	{1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1},
	{1,1,4,4,1,1,4,4,1,1},
	{1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1}
}

function make_bricks()
    local brick_w=10
	local brick_h=3
	local start_x=4
	local start_y=20
	local gap=2

	for row = 1, #level do
        for col = 1, #level[row] do
            local brick_type = level[row][col]
            
            if brick_type > 0 then
				local health=brick_type
				if brick_type==4 then
					health=-1
				end
                if health > 0 then  -- Only count destructible bricks
    				total_bricks_possible += 1
				end
				add(bricks, {
                    x = start_x + (col-1) * (brick_w + gap),
                    y = start_y + (row-1) * (brick_h + gap),
                    w = brick_w,
                    h = brick_h,
                    type = brick_type,
					health=health,
					max_health=brick_type,
                    color = brick_type + 7,
                    alive = true
                })
            end
        end
    end
end

function draw_brick(brick)
    if brick.alive then
        rectfill(brick.x, brick.y, 
                 brick.x + brick.w, 
                 brick.y + brick.h, 
                 brick.color)
    end
end
-->8
--game state functions
function draw_ui()
	rectfill(0, 0, 127, 12, 1)
	print(
		"score: "..score,8,4,15
	)
	local mult_tier = flr(multiplier)
	local effect = multi_effects[mult_tier]
	local shake_x = 0
	local shake_y = 0
	if effect.shake > 0 then
		shake_x = rnd(effect.shake * 2) - effect.shake
		shake_y = rnd(effect.shake * 2) - effect.shake
	end
	print(multiplier.."x", 60 + shake_x, 4 + shake_y, effect.color)
	
	for i=1,lives do
		spr(004,90+i*8,2)
 	end
	line(0, 12, 127, 12, 7)
end

function draw_combo_popup()
    if combo_popup.active then
        local elapsed = time() - combo_popup.start_time
        local slide_y = combo_popup.y + (elapsed * 30)
        
        if elapsed > 1.5 or slide_y > 128 then
            combo_popup.active = false
        else
            print(combo_popup.text, combo_popup.x, slide_y, combo_popup.color)
        end
    end
end

function game_over()
	game_state = "game_over"
	music(-1)
end	
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000ff0ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000fffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000fffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000000000000000000000000000fffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000000000000000000000000000fff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000025050290502d0502f0503105032050310502f0502e0502a05025050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0130002011132101321113213132111321013211132151321d1321f132211321f1321d1321c1321d1321a132111321013211132131321113210132111320e1321d1321f132211321f1321d1321c1321d1321a132
011800200701500000070350702507015000000703507025070150000007035070250701500000070350702507015000000103501025010150000001035010250101500000010350102501015000000103501025
000600002715021150151500c15009150061500315003150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0118002024615000000c0130000024615000000c0130000024615000000c0130000024615000000c0130000024615000000c0230000024615000000c0130000024615000000c0130000024615000000c01300000
0118002000000000003f6253f61500000000003f6253f61500000000003f6253f61500000000003f6253f61500000000003f6253f61500000000003f6253f61500000000003f6253f61500000000003f6253f615
__music__
03 01020405

