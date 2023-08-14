extends Button
class_name WordPhoneticNode
const could_delete_phonetic:PackedStringArray = ["rest","etc"]
enum types { # Word or Phonetic
	Word,
	Phonetic,
	Note
	}

var parent_id:int = 0 # for phonetics
var self_id:int = 0 # for words
var self_type:int = 0: # Word or Phonetic
	set = _self_type_changed

var extend_able:bool = false # it means if can you extend the node
var move_able:bool = false # it means if can you move the node
var is_spoken:bool = false

var real_position:Vector2 = Vector2(0,0) # self_property
var real_size_x:float = 176
var real_text:String = "Test":
	set = _text_changed

func _ready(): # set size_x
	if real_size_x == 176:
		real_size_x = len(real_text)*10
	Global.stop_moving_nodes.connect(self._stop_moving) # if pressed "key_space" it will stop your control
	Global.continue_moving_nodes.connect(self._continue_moving) # if release "key_space" you can control it again
	$"Destory".pressed.connect(self._destory)

func _destory(): # for words
	match self_type:
		types.Word:
			Global.words_nodes.erase(self_id)
			for node in $"../../Phonetic".get_children():
				if node.parent_id == self_id:
					node.queue_free()
			queue_free()
		types.Phonetic:
			queue_free()
		types.Note:
			queue_free()

func _process(_delta):
	#每一帧处理xy和尺寸
	position.x = Global.get_grid_pos(real_position.x)
	position.y = Global.get_grid_pos(real_position.y)
	size.x = Global.get_grid_pos(real_size_x)
	
	#如果是音素的话被触碰到就会更改嘴型
	if (self_type == types.Phonetic):
		if (not is_spoken) and (Global.playing_pos >= position.x):
			is_spoken = true
			Global.mouth_node.mouth = real_text
		elif Global.playing_pos < position.x:
			is_spoken = false

func _text_changed(new_text:String):
	real_text = new_text
	$"Text".draw_text = real_text

func _self_type_changed(new_value):
	self_type = new_value
	match self_type:
		types.Word:
			pass
		types.Phonetic:
			if not ( real_text in could_delete_phonetic ):
				$"Destory".hide()
			set("theme_override_styles/normal",Global.style_boxs[2])
			set("theme_override_styles/disabled",Global.style_boxs[2])
			set("theme_override_styles/focus",Global.style_boxs[3])
			set("theme_override_styles/hover",Global.style_boxs[3])
			set("theme_override_styles/pressed",Global.style_boxs[3])
		types.Note:
			pass

func _stop_moving(): #由Global类绑定的信号
	disabled = true
	$"Destory".disabled = true
	$"RightExtend".disabled = true

func _continue_moving(): #由Global类绑定的信号
	disabled = false
	$"Destory".disabled = false
	$"RightExtend".disabled = false
	if button_pressed:
		extend_able = false
		move_able = true
	else :
		extend_able = false
		move_able = false
	if $"RightExtend".button_pressed:
		extend_able = true
		move_able = false

func _input(event):
	if event is InputEventMouseMotion :
		var move_x:float = event.relative.x / Global.draw_scale
		if move_able:
			real_position.x += move_x 
			real_position.y += event.relative.y
			#移动单词的同时移动子音素
			if self_type == types.Word and Global.words_nodes.has(self_id):
				for node in $"../../Phonetic".get_children():
					if node.parent_id == self_id:
						node.real_position.x += move_x
						node.real_position.y += event.relative.y
		if extend_able:
			real_size_x += move_x
			real_size_x = clamp(real_size_x,len(real_text)*10,1000)
