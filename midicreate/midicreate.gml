function midicreate() constructor {
	enum midiprgm {
		acousticGrandPiano = 0,
		celesta = 8,
		drawbarOrgan = 16,
		acousticGuitar = 24,
		acousticBass = 32,
		violin = 40,
		stringEnsemble1 = 48,
		trumpet = 56,
		sopranoSax = 64,
		piccolo = 72,
		lead1 = 80,
		pad1 = 88,
		fx1 = 96,
		sitar = 104,
		tinkleBell = 112,
		guitarFretNoise = 120
	}
	
	function _wrt_ (val) {
		currenttracklength++
		buffer_write(buff,buffer_u8,val)
	}
	function _wrttext_ (text) {
		currenttracklength+=string_length(text)
		buffer_write(buff,buffer_text,text)
	}
	
	function _multwrt_ (bytes,val) {
		for (var _i = (bytes/8)-1; _i > -1; _i--) {
			_wrt_((val&(255<<(_i*8)))>>(_i*8))
		} 	
	} 
	
	function _rawrmultwrt_ (buffer,bytes,val) {
		for (var _i = (bytes/8)-1; _i > -1; _i--) {
			buffer_write(buffer,buffer_u8,(val&(255<<(_i*8)))>>(_i*8))
		} 	
	} 
	
	function _vlq_ (val) { // Variable Length Quantity
		if (val > 127) {
			var _len = floor(log2(val)/7)+1
			var _arr = []
			for (var _i = 0; _i < _len; _i++) {
				array_push(_arr,(_i+1 == _len)*128 + ((val >> _i*7)&$7F))
			}
			for (var _i = array_length(_arr)-1; _i > -1; _i--) {
				_wrt_(_arr[_i])
			}
		} else {
			_wrt_(val)
		}
	}
	
	function metaTempo (delta,tempo) {
		_vlq_(delta)
		var _ = floor((60/tempo)*1000000)
		_wrt_($FF)
		_wrt_($51)
		_wrt_(3) //len
		_multwrt_(24,_)
	}
	function metaTimeSignature (delta,num,denom) {
		_vlq_(delta)
		_wrt_($FF)
		_wrt_($58)
		_wrt_(4) //len
		_wrt_(num)
		_wrt_(log2(denom))
		_wrt_(24*(4/denom))//metronome clicks
		_wrt_(8)//32nd-notes in quarter note
	}
	function metaKeySignature (delta,sf,minor) {
		_vlq_(delta)
		_wrt_($FF)
		_wrt_($59)
		_wrt_(2) //len
		_wrt_((256+sf)%256)//-7 = 7flats; 7 = 7sharps
		_wrt_(minor)
	}
	function metaTrackName (delta,text) {
		_vlq_(delta)
		_wrt_($FF)
		_wrt_($03)
		_vlq_(string_length(text)) //len
		_wrttext_(text) 
	}
	
	function metaInstrumentName (delta,text) {
		_vlq_(delta)
		_wrt_($FF)
		_wrt_($04)
		_vlq_(string_length(text)) //len
		_wrttext_(text) 
	}
	function metaMidiChannelPrefix (delta,channel) {
		_vlq_(delta)
		_wrt_($FF)
		_wrt_($20)
		_wrt_(1) //len
		_wrt_(channel) //0-15
	}
	function metaEndTrack (delta) {
		_vlq_(delta)
		_wrt_($FF)
		_wrt_($2F)
		_wrt_(0) //len
		array_push(tracklengths,currenttracklength)
	}
	function midiNoteOn (delta,channel,note,vel) {
		_vlq_(delta)
		_wrt_($90+channel)
		_wrt_(note)
		_wrt_(vel)
		for (var _i = 4; _i < argument_count; _i+=2) {
			_wrt_(0)
			_wrt_(argument[_i])
			_wrt_(argument[_i+1])
		}
	}
	function midiNoteOff (delta,channel,note,vel) {
		_vlq_(delta)
		_wrt_($80+channel)
		_wrt_(note)
		_wrt_(vel)
		for (var _i = 4; _i < argument_count; _i+=2) {
			_wrt_(0)
			_wrt_(argument[_i])
			_wrt_(argument[_i+1])
		}
	}
	function midiProgramChange (delta,channel,prgm) {
		_vlq_(delta)
		_wrt_($C0+channel)
		_wrt_(prgm) //Instrument
	}
	
	function ccPan (delta,channel,pan) {
		_vlq_(delta)
		_wrt_($B0+channel)
		_wrt_($0A)
		_wrt_(pan)
	}
	
	function ccVibrato (delta,channel,vibrato) {
		_vlq_(delta)
		_wrt_($B0+channel)
		_wrt_($01)
		_wrt_(vibrato)
	}
	
	function ccPortamento (delta,channel,portamento) {
		_vlq_(delta)
		_wrt_($B0+channel)
		_wrt_($05)
		_wrt_(portamento)
	}
	
	function gmStartTrack () {
		buff = buffer_create(0,buffer_grow,1)
		array_push(bufftracks,buff)
		currenttracklength = 0
	}
	
	function __midi_creation_start () {
		buffmain = buffer_create(0,buffer_grow,1)
		bufftracks = []
		currenttracklength = 0
		tracklengths = []
	}
	
	function __midi_creation_end (filename,ticks) {

		buffer_write(buffmain,buffer_text,"MThd")
		_rawrmultwrt_(buffmain,32,6)
		
		_rawrmultwrt_(buffmain,16,1)
		_rawrmultwrt_(buffmain,16,array_length(bufftracks))
		_rawrmultwrt_(buffmain,16,ticks)
		
		for (var _i = 0; _i < array_length(bufftracks); _i++) {
			var _btrk = bufftracks[_i]
			var _size = tracklengths[_i]
			buffer_write(buffmain,buffer_text,"MTrk")
			_rawrmultwrt_(buffmain,32,_size)
			
			buffer_seek(_btrk,buffer_seek_start,0)
			repeat (_size) {
				buffer_write(buffmain,buffer_u8,buffer_read(_btrk,buffer_u8))
			}
		}
		buffer_save(buffmain,filename)
	}
}