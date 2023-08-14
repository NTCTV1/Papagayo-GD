extends Control
const node:PackedScene = preload("res://Word/Node.tscn")
const project_json_path:String = "res://Output/project.json"
var audio_playing:bool = false

@onready var content_note:Control = $"BG/Content/Note"
@onready var content_word:Control = $"BG/Content/Word"
@onready var content_phonetic:Control = $"BG/Content/Phonetic"

func _ready():
	Global.mouth_node = $"Ui/Mouth/Mouth"
	
	get_tree().get_root().files_dropped.connect( self._load_project )
	$"Ui/Clear".pressed.connect( self._clear )
	$"Ui/Export".pressed.connect( self._export_project )
	$"Ui/FpsEdit".text_submitted.connect( self._change_fps )
	$"Ui/TextEdit".text_submitted.connect( self._add_word_and_phonetic )
	$"Ui/NoteEdit".text_submitted.connect( self._add_notes )
	$"Ui/Mode".toggled.connect( self._change_mode )
	$"AudioStreamPlayer".finished.connect( self._audio_finished )
	

func _process(_delta):
	#计算鼠标的位置
	var mouse_position_x:float = get_global_mouse_position().x + Global.draw_scrolling * Global.draw_scale
	#根据偏移设置背景的滚动
	$"BG/Content".position.x = -Global.draw_scrolling * Global.draw_scale
	$"BG/Content".position.y = Global.draw_offset_y
	$"BG/Content".scale.x = Global.draw_scale
	#根据音频的长短设置可活动区域的大小
	$"BG/Content/ActiveRange".size.x = $"AudioStreamPlayer".stream.get_length() * 10 * Global.project_fps
	#根据是否播放音频设置光标的位置
	$"BG/Content/VSeparator".position.x = ($"AudioStreamPlayer".get_playback_position() * Global.project_fps * Global.draw_spacing ) if audio_playing else (floor(mouse_position_x / Global.draw_spacing / Global.draw_scale) * Global.draw_spacing)
	#音频播放的位置！以像素作为单位！
	Global.playing_pos = $"BG/Content/VSeparator".position.x

# connect functions

func _load_project(files:PackedStringArray):
	for file in files:
		if file.ends_with(".json"):
			_clear()
			var project:Dictionary = Global.get_json(file)
			if project.has("fps"):
				Global.project_fps = project.fps
			for word in project.words:
				var new_word_node:WordPhoneticNode = node.instantiate()
				new_word_node.self_id = word.id
				
				new_word_node.real_size_x = word.size_x
				new_word_node.real_text = word.text
				new_word_node.self_type = WordPhoneticNode.types.Word
				new_word_node.real_position = Vector2(word.x,word.y)
				Global.words_nodes[new_word_node.self_id] = new_word_node
				
				content_word.add_child(new_word_node)
				if word.id > Global.project_node_count: # fixed the wrong movement like move other words'phonetics
					Global.project_node_count = word.id + 1
			for phonetic in project.phonetics:
				var new_phonetic_node:WordPhoneticNode = node.instantiate()
				new_phonetic_node.parent_id = phonetic.connect_id
				
				new_phonetic_node.real_size_x = phonetic.size_x
				new_phonetic_node.real_text = phonetic.text
				new_phonetic_node.self_type = WordPhoneticNode.types.Phonetic
				new_phonetic_node.real_position = Vector2(phonetic.x,phonetic.y)
				
				content_phonetic.add_child(new_phonetic_node)
			for note in project.notes:
				var new_note_node:WordPhoneticNode = node.instantiate()
				new_note_node.real_size_x = note.size_x
				new_note_node.real_text = note.text
				new_note_node.self_type = WordPhoneticNode.types.Note
				new_note_node.real_position = Vector2(note.x,note.y)
				
				content_note.add_child(new_note_node)
		elif file.ends_with(".wav"):
			var WavLoader:AudioLoader = AudioLoader.new()
			$"AudioStreamPlayer".stream = WavLoader.loadfile(file)

#清理项目
func _clear():
	Global.project_node_count = 0
	for word_node in content_word.get_children():
		word_node.queue_free()
	for phonetic_node in content_phonetic.get_children():
		phonetic_node.queue_free()

#导出项目
func _export_project():
	#导出的内容包括帧率注释，单词和音素
	Global.project_dic.fps = float($"Ui/FpsEdit".text)
	Global.project_dic.notes.clear()
	Global.project_dic.words.clear()
	Global.project_dic.phonetics.clear() # clear last exported things
	for note in content_note.get_children():
		Global.project_dic.notes.append( {
			"frame":Global.get_grid_pos(note.real_position.x)/10.0,
			"frame_length":note.size.x/10.0,
			"size_x":note.size.x,
			"text":note.real_text,
			"x":Global.get_grid_pos(note.real_position.x),
			"y":Global.get_grid_pos(note.real_position.y) } )
	for word in content_word.get_children():
		Global.project_dic.words.append( {
			"id":word.self_id,
			"size_x":word.size.x,
			"text":word.real_text,
			"x":Global.get_grid_pos(word.real_position.x),
			"y":Global.get_grid_pos(word.real_position.y) } )
	for phonetic in content_phonetic.get_children():
		Global.project_dic.phonetics.append( {
			"frame":Global.get_grid_pos(phonetic.real_position.x)/10.0,
			"frame_length":phonetic.size.x/10.0,
			"connect_id":phonetic.parent_id,
			"size_x":phonetic.size.x,
			"text":phonetic.real_text,
			"x":Global.get_grid_pos(phonetic.real_position.x),
			"y":Global.get_grid_pos(phonetic.real_position.y) } )
	Global.save_json(project_json_path,Global.project_dic)

func _change_fps(new_value:String):
	Global.project_fps = float(new_value)

func _change_mode(mode:bool):
	Global.project_safe_mode = mode

func _audio_finished():
	audio_playing = false

# api

func _add_word_and_phonetic( new_word:String ):
	_add_phonetic( new_word.to_lower() , Global.project_node_count)
	_add_word( new_word.to_lower() )
	$"Ui/TextEdit".text = ""
	$"Ui/TextEdit".release_focus()

func _add_notes( new_note:String ):
	_add_note( new_note )
	$"Ui/NoteEdit".text = ""
	$"Ui/NoteEdit".release_focus()

# ___note___

func _add_note( new_note:String ):
	var new_note_node:WordPhoneticNode = node.instantiate()
	new_note_node.self_type = WordPhoneticNode.types.Note
	new_note_node.real_position = Vector2(Global.playing_pos,150)
	new_note_node.real_text = new_note
	$"BG/Content/Note".add_child(new_note_node)

## ___main___

func _add_word( new_word:String ):
	var new_word_node:WordPhoneticNode = node.instantiate()
	new_word_node.self_type = WordPhoneticNode.types.Word
	new_word_node.real_position = Vector2(Global.playing_pos,150)
	new_word_node.real_text = new_word
	new_word_node.self_id = Global.project_node_count
	$"BG/Content/Word".add_child(new_word_node)
	Global.words_nodes[new_word_node.self_id] = new_word_node
	Global.project_node_count += 1

func _add_phonetic( new_word:String , parent_id:int ):
	var packed_word_phonetics:Dictionary = Global.parse_word(new_word)
	var phonetic_y:float = 200
	for phonetic in packed_word_phonetics.keys():
		var new_phonetic_node:WordPhoneticNode = node.instantiate()
		new_phonetic_node.real_position.x = Global.playing_pos + Global.get_frame_position(phonetic) 
		new_phonetic_node.real_position.y = phonetic_y
		new_phonetic_node.parent_id = parent_id
		new_phonetic_node.real_text = packed_word_phonetics[phonetic]
		new_phonetic_node.self_type = WordPhoneticNode.types.Phonetic
		$"BG/Content/Phonetic".add_child(new_phonetic_node)
		phonetic_y += 30
	var word_node:WordPhoneticNode = node.instantiate()
	word_node.real_position.x = Global.playing_pos + Global.get_frame_position(packed_word_phonetics.size())
	word_node.real_position.y = phonetic_y
	word_node.parent_id = parent_id
	word_node.real_text = "rest"
	word_node.self_type = WordPhoneticNode.types.Phonetic
	$"BG/Content/Phonetic".add_child(word_node)

# / connect functions 

func _input(event):
	var mouse_pos:Vector2 = get_global_mouse_position()
	if event is InputEventKey:
		if event.is_action_pressed("key_space") and (mouse_pos.y > 64 and mouse_pos.y < 368):
			audio_playing = not audio_playing
			if audio_playing:
				$"AudioStreamPlayer".play()
				$"AudioStreamPlayer".seek( abs($"BG/Content/VSeparator".position.x/10)/Global.project_fps )
			else :
				$"AudioStreamPlayer".stop()
	elif event is InputEventMouseButton:
		if event.is_action_pressed("mouse_left"):
			$"BG/Content/VSeparator".color = Color(0.5,0.5,0.5,0.5)
		elif event.is_action_released("mouse_left"):
			$"BG/Content/VSeparator".color = Color(0.1,0.1,0.1,0.5)
		if event.is_action_pressed("key_roll_up"):
			Global.draw_scale += 0.1
		elif event.is_action_pressed("key_roll_down"):
			Global.draw_scale -= 0.1
