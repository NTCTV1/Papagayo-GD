extends Control
const project_json_path:String = "res://Output/project.json"
var audio_playing:bool = false
var node:PackedScene = preload("res://Word/Node.tscn")

func _ready():
	get_tree().get_root().files_dropped.connect( self._load_project )
	$"Ui/Clear".pressed.connect( self._clear )
	$"Ui/Export".pressed.connect( self._export_project )
	$"Ui/FpsEdit".text_submitted.connect( self._change_fps )
	$"Ui/TextEdit".text_submitted.connect( self._add_word_and_phonetic )
	$"Ui/Mode".toggled.connect( self._change_mode )
	$"AudioStreamPlayer".finished.connect( self._audio_finished )

func _process(_delta):
	var mouse_position_x:float = get_global_mouse_position().x + Global.draw_scrolling * Global.draw_scale
	$"BG/Content".position.x = -Global.draw_scrolling * Global.draw_scale
	$"BG/Content".position.y = Global.draw_offset_y
	$"BG/Content".scale.x = Global.draw_scale
	$"BG/Content/ActiveRange".size.x = $"AudioStreamPlayer".stream.get_length() * 10 * Global.project_fps * Global.draw_scale
	if not audio_playing:
		$"BG/Content/VSeparator".position.x = (floor(mouse_position_x / Global.draw_spacing / Global.draw_scale) * Global.draw_spacing)
	else :
		$"BG/Content/VSeparator".position.x = ( ($"AudioStreamPlayer".get_playback_position() * Global.project_fps * 10 ))*Global.draw_scale

# connect functions

func _load_project(files:PackedStringArray):
	for file in files:
		print(file)
		if file.ends_with(".json"):
			_clear()
			var project:Dictionary = Global.get_json(file)
			for word in project.words:
				var new_word_node:WordPhoneticNode = node.instantiate()
				new_word_node.self_id = word.selfId
				new_word_node.real_size_x = word.sizeX
				new_word_node.real_text = word.text
				new_word_node.self_type = word.type
				new_word_node.position = Vector2(word.x,word.y)
				Global.words_nodes[new_word_node.self_id] = new_word_node
				$"BG/Content/Word".add_child(new_word_node)
				Global.project_node_count += 1
			for phonetic in project.phonetics:
				var new_phonetic_node:WordPhoneticNode = node.instantiate()
				new_phonetic_node.parent_id = phonetic.parentId
				new_phonetic_node.real_size_x = phonetic.sizeX
				new_phonetic_node.real_text = phonetic.text
				new_phonetic_node.self_type = phonetic.type
				new_phonetic_node.position = Vector2(phonetic.x,phonetic.y)
				print(new_phonetic_node.real_position)
				$"BG/Content/Phonetic".add_child(new_phonetic_node)
		elif file.ends_with(".wav"):
			var WavLoader:AudioLoader = AudioLoader.new()
			$"AudioStreamPlayer".stream = WavLoader.loadfile(file)

func _clear():
	for word_node in $"BG/Content/Word".get_children():
		word_node.queue_free()
	for phonetic_node in $"BG/Content/Phonetic".get_children():
		phonetic_node.queue_free()

func _export_project():
	Global.project_dic.words.clear()
	Global.project_dic.phonetics.clear()
	for word in $"BG/Content/Word".get_children():
		Global.project_dic.words.append( {
			"selfId":word.self_id,
			"sizeX":word.size.x,
			"text":word.real_text,
			"type":word.self_type,
			"x":word.position.x,
			"y":word.position.y } )
	for phonetic in $"BG/Content/Phonetic".get_children():
		Global.project_dic.phonetics.append( {
			"parentId":phonetic.parent_id,
			"sizeX":phonetic.size.x,
			"text":phonetic.real_text,
			"type":phonetic.self_type ,
			"x":phonetic.position.x,
			"y":phonetic.position.y,} )
	Global.save_json(project_json_path,Global.project_dic)
	print("Export over!")

func _change_fps(new_value:String):
	Global.project_fps = float(new_value)

func _change_mode(mode:bool):
	Global.project_safe_mode = mode

func _audio_finished():
	audio_playing = false

func _add_word_and_phonetic( new_word:String ):
	_add_phonetic( new_word.to_lower() , Global.project_node_count)
	_add_word( new_word.to_lower() )
	$"Ui/TextEdit".text = ""
	$"Ui/TextEdit".release_focus()

func _add_word( new_word:String ):
	var new_word_node:WordPhoneticNode = node.instantiate()
	new_word_node.self_type = WordPhoneticNode.types.Word
	new_word_node.real_position = Vector2(0,150)
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
		
		new_phonetic_node.real_position.x = _get_frame_position(phonetic)
		new_phonetic_node.real_position.y = phonetic_y
		new_phonetic_node.parent_id = parent_id
		new_phonetic_node.real_text = packed_word_phonetics[phonetic]
		new_phonetic_node.self_type = WordPhoneticNode.types.Phonetic
		
		$"BG/Content/Phonetic".add_child(new_phonetic_node)
		phonetic_y += 30

# / connect functions 

func _get_frame_position( frame:float ):
	return 10*frame

func _input(event):
	var mouse_pos:Vector2 = get_global_mouse_position()
	if event is InputEventKey:
		if event.is_action_pressed("key_space") and (mouse_pos.y > 64 and mouse_pos.y < 368):
			audio_playing = not audio_playing
			if audio_playing:
				$"AudioStreamPlayer".play()
				$"AudioStreamPlayer".seek( ($"BG/Content/VSeparator".position.x/10)/Global.project_fps/Global.draw_scale )
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
