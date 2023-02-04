extends Node2D
const font_color:Color = Color.BLACK
var font := preload("res://Main/Gui/MSYH.TTC")
var draw_text:String = "Test"

func _process(_delta):
	queue_redraw()

func _draw():
	var draw_position:Vector2 = Vector2(0,17)
	for _char in draw_text:
		draw_char(font,draw_position,_char,10,font_color)
		draw_position.x += 10 * Global.draw_scale
