extends Node

#func _ready():
#	_trans_dic()

#func _trans_dic():
#	var loaded_text = FileAccess.open("res://PhonemeMapping/SafePhonemeMapping/standard_dictionary_2015.txt",FileAccess.READ).get_as_text()
#	var over_dic:Dictionary
#	var word_and_phoneme_array:Array
#	loaded_text = loaded_text.replacen("\n",",")
#	word_and_phoneme_array = loaded_text.rsplit(",",false)
#	print(word_and_phoneme_array)
#
#	for phonemes in word_and_phoneme_array:
#		var tmp_phonemes:Array = phonemes.rsplit(" ",false)
#		var phrase = tmp_phonemes[0].lstrip("{").lstrip("}").to_lower()
#		over_dic[phrase] = {}
#		tmp_phonemes.remove_at(0)
#
#		for phoneme in len(tmp_phonemes):
#			over_dic[phrase][str(phoneme)] = tmp_phonemes[phoneme].replacen("\n","").replacen("\r","")
#
#	Global.save_json("res://PhonemeMapping/SafePhonemeMapping/PhrasesMap2.json",over_dic)

#func _trans_map():
#	var loaded_text = FileAccess.open("res://PhonemeMapping/SafePhonemeMapping/phoneme_mapping.txt",FileAccess.READ).get_as_text()
#	var phoneme_array:Array = []
#	var packed_phoneme_map:Dictionary = {}
#
#	loaded_text = loaded_text.replacen("\n",",")
#	loaded_text = loaded_text.replacen(" "," ")
#
#	phoneme_array = loaded_text.rsplit(",",false)
#	for phoneme in phoneme_array:
#		packed_phoneme_map[phoneme.rsplit(" ",false)[0]] = phoneme.rsplit(" ",false)[1]
#	Global.save_json("res://PhonemeMapping/SafePhonemeMapping/Map.json",packed_phoneme_map)
