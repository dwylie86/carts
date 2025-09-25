pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--main entry point of game

function _init()
	score = 0
	lives = 3
	game_state = "playing"

	init_paddle()
	init_ball()
	music(0)
end

function _update()
	if game_state == "playing" then
		move_paddle()
		move_ball()
 		bounce_paddle()
 		lose_dead_ball()
	elseif game_state == "game_over" then
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
	elseif game_state == "game_over" then
  print("game over", 45, 64, 15)
  print("score: "..score, 45, 72, 15)
  print("press x to restart", 25, 80, 15)	
	end
end	
-->8
--paddle functions
function init_paddle()
	pad = {
		x=52,
		y=122,
		w=24,
		h=4,
		s=2
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
        score += 10
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
        ball.x = pad.x + pad.w/2  -- center on paddle
        ball.y = pad.y - ball.s - 1  -- just above paddle
        
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
    
    	if ball.y + ball.vely < 0 + ball.s then
        	ball.vely *= -1
        	sfx(0)
    	else
        	ball.y += ball.vely
    	end
	end
end

function lose_dead_ball()      
	if ball.y>128 then             
		if lives>0 then
			sfx(3)             
			lives-=1
			ball.on_paddle=true      
		else
		 game_over() 
 		end    
	end
end
-->8
--game state functions
function draw_ui()
	print(
		"score: "..score,8, 6,15
	)
	for i=1,lives do
		spr(004,90+i*8,4)
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

