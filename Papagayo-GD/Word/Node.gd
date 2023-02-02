extends Button
class_name WordPhoneticNode
enum types { # Word or Phonetic
	Word,
	Phonetic
	}

var parent_id:int = 0 # for phonetics
var self_id:int = 0 # for words
var self_type:int = 0: # Word or Phonetic
	set = _self_type_changed

var extend_able:bool = false # it means if can you extend the node
var move_able:bool = false # it means if can you move the node

var real_position:Vector2 = Vector2(0,0) # self_property
var real_size_x:float = 176
var real_text:String = "Test":
	set = _text_changed

func _ready(): # set size_x
	real_size_x = len(real_text)*10
	Global.stop_moving_nodes.connect(self._stop_moving) # if pressed "key_space" it will stop your control
	Global.continue_moving_nodes.connect(self._continue_moving) # if release "key_space" you can control it again

func _destory(): # for words
	Global.words_nodes.erase(self_id)
	for node in $"../../Phonetic".get_children():
		if node.parent_id == self_id:
			node.queue_free()
	queue_free()

func _process(_delta):
	position.x = floor(real_position.x/Global.draw_spacing)*Global.draw_spacing
	position.y = floor(real_position.y/Global.draw_spacing)*Global.draw_spacing
	size.x = floor(real_size_x/Global.draw_spacing)*Global.draw_spacing

func _text_changed(new_text:String):
	real_text = new_text
	$"Text".draw_text = real_text

func _self_type_changed(new_value):
	self_type = new_value
	match self_type:
		types.Word:
			$"Destory".pressed.connect(self._destory)
			set("theme_override_styles/normal",Global.style_boxs[0])
			set("theme_override_styles/disabled",Global.style_boxs[0])
			set("theme_override_styles/focus",Global.style_boxs[1])
			set("theme_override_styles/hover",Global.style_boxs[1])
			set("theme_override_styles/pressed",Global.style_boxs[1])
		types.Phonetic:
			$"Destory".hide()
			set("theme_override_styles/normal",Global.style_boxs[2])
			set("theme_override_styles/disabled",Global.style_boxs[2])
			set("theme_override_styles/focus",Global.style_boxs[3])
			set("theme_override_styles/hover",Global.style_boxs[3])
			set("theme_override_styles/pressed",Global.style_boxs[3])

func _stop_moving(): # see the note above
	disabled = true
	$"Destory".disabled = true
	$"RightExtend".disabled = true

func _continue_moving(): # see the note above
	disabled = false
	$"Destory".disabled = false
	$"RightExtend".disabled = false
	if button_pressed:
		extend_able = false
		move_able = true
	else :
		extend_able = false
		move_able = false
		if not Input.is_action_pressed("mouse_left"):
			real_position = position
	if $"RightExtend".button_pressed:
		extend_able = true
		move_able = false

func _input(event):
	if event is InputEventMouseMotion :
		if move_able:
			real_position.x += (event.relative.x) / Global.draw_scale
			real_position.y += event.relative.y
			
			if self_type == types.Word and Global.words_nodes.has(self_id):
				for node in $"../../Phonetic".get_children():
					if node.parent_id == self_id:
						node.real_position.x += (event.relative.x) / Global.draw_scale
						node.real_position.y += event.relative.y
		if extend_able:
			real_size_x += (event.relative.x) / Global.draw_scale
			real_size_x = clamp(real_size_x,len(real_text)*10,1000)
