function midireader(mid_file) constructor {
	mid_buff = buffer_load(mid_file)
	byte_num = 0
	deltas = []
	events = []
	header_name = ""
	header_format = -1
	header_track_number = 0
	header_division = 0
	track_names = []

	function __r1byte () {
		byte_num++
		if (byte_num > buffer_get_size(mid_buff)) {
			show_error("<limit>\n File Invaild >>> Exceeded Buffer Size",true)
		}
		return buffer_read(mid_buff,buffer_u8)
	}
	
	function __read (bits,rd=true) {
		var _ret = 0, _num = bits/8, _at = rd*_num
		repeat (_num) {
			_at -= (rd)
			_ret += __r1byte()<<(8*_at)
			_at += (!rd)
		}
		return _ret
	}
	
	function __read_text (len) {
		var _ret = ""
		repeat (len) {_ret += chr(__r1byte())}
		return _ret
	}
	
	function __read_vlq () {
		var _ret = 0, _cont = true, _byte
		while (_cont) {
			_cont = false
			_byte = __r1byte()
			_ret += _byte&127
			if (_byte > 127) {
				_ret = _ret<<7
				_cont = true
			}
		}
		return _ret
	}
	
	// "Delta" and "Event Lengths" are Variable Length Quanities
	// Does not support System Messages
	var _ch_len, 
	_ch_bg_at, _dl_arr, _ev_arr, _ev, _dat,
	_chn_id, _chn_num, _len, _tog, _extblen
	
	header_name = __read_text(4) // MThd
	_ch_len = __read(32) //bytes
	header_format = __read(16)
	header_track_number = __read(16)
	header_division = __read(16)
	repeat (_ch_len - 6) {__r1byte()}
	
	for (var _track_at = 0; _track_at < header_track_number; _track_at++) {
		_dl_arr = []
		_ev_arr = []
		array_push(deltas,_dl_arr)
		array_push(events,_ev_arr)
		
		array_push(track_names,__read_text(4)) // MTrk
		_ch_len = __read(32) //bytes
		_ch_bg_at = byte_num
		while (byte_num < _ch_bg_at+_ch_len) {
			array_push(_dl_arr,__read_vlq())
			_dat = __r1byte()
			
			if (_dat < 128) {
				_ev = variable_clone(_ev)
				array_push(_ev_arr,_ev)
				_extblen = (array_length(_ev)-_len)
				_ev[_extblen] = _dat
				for (var _extb = _extblen+1; _extb < array_length(_ev); _extb++) {
					_ev[_extb] = __r1byte()
				}
			} else {
				_ev = []
				array_push(_ev_arr,_ev)
				if (_dat == $FF) {
					_dat = __r1byte()
					_tog = false
					switch (_dat) {
						case $03: array_push(_ev,"track_name"); break 
						case $04: array_push(_ev,"instr_name"); break 
						case $20: array_push(_ev,"chn_prefix"); break 
						case $51: array_push(_ev,"tempo"); _tog = true; break 
						case $58: array_push(_ev,"time_sign"); break
						case $59: array_push(_ev,"key_sign"); break
						case $2F: array_push(_ev,"track_end"); break
						default: array_push(_ev,"unknown_meta"); break
					}
					_len = __read_vlq()
					
					if (0 < _dat && _dat < $10) {array_push(_ev,__read_text(_len))}
					else if (_tog) {array_push(_ev,__read(_len*8))}
					else {repeat (_len) {array_push(_ev,__r1byte())}}
				} else {
					_chn_id = _dat&$F0
					_chn_num = _dat&$F
					_tog = false
					_len = 0
					switch (_chn_id) {
						case $80: array_push(_ev,"note_off"); _len = 2; break
						case $90: array_push(_ev,"note_on"); _len = 2; break
						case $A0: array_push(_ev,"key_pressure"); _len = 2; break
						case $B0: array_push(_ev,"ctrl_change"); _len = 2; break
						case $C0: array_push(_ev,"prgm_change"); _len = 1; break
						case $D0: array_push(_ev,"chn_pressure"); _len = 1; break
						case $E0: array_push(_ev,"pitch_wheel"); _len = 2; _tog = true; break
						case $F0: array_push(_ev,"system"); show_error("<sys>\nDoes not support System Messages",true); break
					}
					array_push(_ev,_chn_num)
					
					if (_tog) {array_push(_ev,__read(_len*8))}
					else {repeat (_len) {array_push(_ev,__r1byte())}}
					
				}
			}
		}
	}
	
	var _delta_length = []
	var _event_length = []
	for (var _i = 0; _i < array_length(deltas); _i++) {
		array_push(_delta_length,array_length(deltas[_i]))
	}
	for (var _i = 0; _i < array_length(events); _i++) {
		array_push(_event_length,array_length(events[_i]))
	}
	
	if (!array_equals(_delta_length,_event_length)) {
		show_error($"<unbalanced>\nFile Invalid >>> Delta: {_delta_length}, Event: {_event_length}",true)
	}
	
}