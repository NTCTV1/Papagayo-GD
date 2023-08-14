extends Sprite2D

var mouth:String = "":
	set = _set_mouth

var mouthes:Dictionary = {
	"AI":preload("res://Main/Mouth/AI.png"),
	"AH":preload("res://Main/Mouth/AH.png"),
	"O":preload("res://Main/Mouth/O.png"),
	"U":preload("res://Main/Mouth/U.png"),
	"WQ":preload("res://Main/Mouth/WQ.png"),
	"MBP":preload("res://Main/Mouth/MBP.png"),
	"M":null,
	"etc":preload("res://Main/Mouth/NN.png"),
	"E":preload("res://Main/Mouth/E.png"),
	"FV":preload("res://Main/Mouth/FV.png"),
	"L":preload("res://Main/Mouth/L.png"),
	"NN":preload("res://Main/Mouth/NN.png"),
	"SS":preload("res://Main/Mouth/SS.png"),
	"SH":preload("res://Main/Mouth/SH.png"),
	"TH":preload("res://Main/Mouth/TH.png"),
	"rest":preload("res://Main/Mouth/Nor.png")
}

func _set_mouth(new_mouth):
	if mouthes.has(new_mouth):
		if mouthes[new_mouth] != null:
			mouth = new_mouth
			texture = mouthes[new_mouth]
