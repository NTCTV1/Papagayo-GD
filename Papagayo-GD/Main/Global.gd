extends Node
const max_phonetic_length:int = 5
var project_safe_mode:bool = true
var project_node_count:int = 0
var project_fps:float = 24.0

var draw_scale:float = 1.0:
	set = _draw_scale_changed
var draw_spacing:float = 10.0
var draw_scrolling:float = 0.0
var draw_offset_y:float = 0.0:
	set = _draw_offset_y_changed

var style_boxs:Array = [
	preload("res://Word/WordNormal.tres"),
	preload("res://Word/WordPressed.tres"),
	preload("res://Word/PhoneticNormal.tres"),
	preload("res://Word/PhoneticPressed.tres")
]
var _safe_parse_phrases_map:Dictionary = {}
var _safe_parse_map:Dictionary = {}
var _parse_phrases_map:Dictionary = {}
var _parse_map:Dictionary = {}
var phonetics:Dictionary = {}
var words_nodes:Dictionary = {}
var project_dic:Dictionary = {"words":[],"phonetics":[]}

signal stop_moving_nodes
signal continue_moving_nodes

func _ready():
	_parse_phrases_map = get_json("res://PhonemeMapping/AutoPhoneme/PhrasesMap.json")
	_parse_map = get_json("res://PhonemeMapping/AutoPhoneme/Map.json")
	_safe_parse_phrases_map = get_json("res://PhonemeMapping/SafePhonemeMapping/PhrasesMap.json")
	_safe_parse_map = get_json("res://PhonemeMapping/SafePhonemeMapping/Map.json")

func get_frame_pos(fps:float = 24.0,frame:float = 0.0) -> float:
	return (1/fps)*frame

func _draw_scale_changed(new_value:float):
	draw_scale = clamp(new_value,1,20)

func _draw_offset_y_changed(new_value:float):
	draw_offset_y = clamp(new_value,-200,200)

func get_json(path:String) -> Dictionary:
	var file = FileAccess.open(path,FileAccess.READ)
	var json_obj = JSON.new()
	json_obj.parse(file.get_as_text())
	return json_obj.get_data()

func save_json(path:String,savefile:Dictionary) -> void:
	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_line(JSON.stringify(savefile,"\t"))

func parse_word(word:String) ->Dictionary:
	var packed_phonetic:Dictionary = {}
	var clear_word:String = word.replace(" ","")
	
	if project_safe_mode:
		if _safe_parse_phrases_map.has(clear_word):
			for num in _safe_parse_phrases_map[clear_word]:
				packed_phonetic[ float(num) ] = _safe_parse_map[_safe_parse_phrases_map[clear_word][num]]
		return packed_phonetic
	else :
		if _parse_phrases_map.has(clear_word):
			for num in _parse_phrases_map[clear_word]:
				packed_phonetic[ float(num) ] = _parse_phrases_map[clear_word][num]
		else :
			var tmp_phrase:String = clear_word
			for length in max_phonetic_length:
				for phonetic in _parse_map.keys():
					if tmp_phrase.contains(phonetic) and len(phonetic) == (max_phonetic_length - length):
						packed_phonetic[ float(clear_word.findn(phonetic)) ] = _parse_map[phonetic]
						tmp_phrase = tmp_phrase.replacen(phonetic,"")
		return packed_phonetic

func _input(_event):
	if Input.is_action_pressed("key_space"):
		emit_signal("stop_moving_nodes")
	else :
		emit_signal("continue_moving_nodes")
