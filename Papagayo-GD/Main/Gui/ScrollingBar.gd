extends Node2D
const bg_color:Color = Color8(240,240,240)
const file_color:Color = Color8(160,165,174)
const font_color:Color = Color8(130,135,144)
var font := preload("res://Main/Gui/MSYH.TTC")

signal moved

func _process(_delta):
	queue_redraw()

func _draw():
	_draw_bar()

func _draw_bar():
	var bar_x_offset = fmod(Global.draw_scrolling,Global.draw_spacing)
	var real_num_offset = _get_real_offset(Global.draw_scrolling/Global.draw_spacing)
	draw_rect(Rect2(0,0,1284,32),bg_color)
	
	for line in ceil( (1284.0/Global.draw_spacing) / Global.draw_scale):
		var line_local_x:float = (line*Global.draw_spacing - bar_x_offset)*Global.draw_scale
		var line_real:int = line + real_num_offset
		
		if fmod(line_real, Global.project_fps) == 0:
			draw_string(font,Vector2(line_local_x,10) , str(line_real) , HORIZONTAL_ALIGNMENT_CENTER , -1 , 10 , font_color)
			draw_line(Vector2(line_local_x,16),Vector2(line_local_x,30),file_color)
		else :
			draw_line(Vector2(line_local_x,26),Vector2(line_local_x,30),file_color)
		draw_line(Vector2(line_local_x,32),Vector2(line_local_x,584),font_color)

func _get_real_offset(num:float):
	if num > 0:
		return floor(num)
	else :
		return ceil(num)

func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("mouse_right"):
			var relative_real = ( event.relative.x / Global.draw_scale )
			emit_signal("moved",relative_real)
			Global.draw_scrolling -= relative_real
			Global.draw_offset_y += event.relative.y


