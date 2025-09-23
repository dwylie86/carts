pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
 x=60
 y=60
 anim_timer=0
 is_moving=false
	facing_dir="idle"
end

function _update()
	is_moving=false
	facing_dir="idle"
	
	
	--movement
	if btn(1) and btn(2) then  -- right + up
  x+=1
  y-=1
  is_moving=true
  facing_dir="up_right"
 elseif btn(1) and btn(3) then  -- right + down
  x+=1
  y+=1
  is_moving=true
  facing_dir="down_right"
 elseif btn(0) and btn(2) then  -- left + up
  x-=1
  y-=1
  is_moving=true
  facing_dir="up_left"
 elseif btn(0) and btn(3) then  -- left + down
  x-=1
  y+=1
  is_moving=true
  facing_dir="down_left"
 elseif btn(0) then
  x-=1
  is_moving=true
  facing_dir="left"
 elseif btn(1) then
  x+=1
  is_moving=true
  facing_dir="right"
 elseif btn(2) then
  y-=1
  is_moving=true
  facing_dir="up"
 elseif btn(3) then
  y+=1
  is_moving=true
  facing_dir="down"
 end
	
	anim_timer+=1
end

function _draw()
	cls(5)
	
		--normal sprites
	if is_moving then
		if facing_dir == "right" then
			spr(2,x,y)
		elseif facing_dir == "left" then
			spr(2,x,y,1,1,true)	
		elseif facing_dir == "up" then
			spr(3,x,y)
		elseif facing_dir == "down" then
			spr(3,x,y,1,1,false,true)
		elseif facing_dir == "up_right" then
   spr(4, x, y)
  elseif facing_dir == "down_right" then
   spr(5, x, y)
  elseif facing_dir == "up_left" then
   spr(4, x, y, 1, 1, true)
  elseif facing_dir == "down_left" then
   spr(5, x, y, 1, 1, true)
		end
		
		else
			idle_frame=anim_timer\15%2
			spr(idle_frame,x,y)				 
		end
		
	print("moving: "..(is_moving and "yes" or "no"),0,0)
	print("facing: "..facing_dir,0,8)
end
__gfx__
0aaaaaa00aaaaaa00aaaaaa00aa33aa00aaaa3300aaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaa3aaaa3333aaaaaaa333aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaaa33aaaaaaaa33aa333333aaaaa3333aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa33aaaaa3333aaaaa33333aaa33aaaaaa333aaaaa33aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000
aa3333aaaaa33aaaaaa33333aaa33aaaaaa33aaaaaa333aa00000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa33aaaaaaaaaaaaaaaa33aaaaaaaaaaaaaaaaaaaaa333300000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaa3aaaaaaaaaaaaaaaaaaaaaaa33300000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaa00aaaaaa00aaaaaa00aaaaaa00aaaaaa00aaaa33000000000000000000000000000000000000000000000000000000000000000000000000000000000
