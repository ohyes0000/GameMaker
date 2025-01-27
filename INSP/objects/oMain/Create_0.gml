randomize()
list = []
string_show = ""

function change_list () {
	var _filename = get_open_filename("","")
	if (file_exists(_filename)) {
		list = []
		string_show = ""
		var _file = file_text_open_read(_filename)
		while (!file_text_eof(_file)) {
			var _ln = file_text_readln(_file)
			for (var _i = 0; _i < string_length(_ln); _i++) { 
				var _c = string_char_at(_ln,_i+1)
				switch (_c) {
					case "*": array_push(list,""); break
					case "\n": case "\t": case "\r": break
					default: if (array_length(list) > 0) {
						list[array_length(list)-1] += _c
					}
				}	
			}
		}
	}
}