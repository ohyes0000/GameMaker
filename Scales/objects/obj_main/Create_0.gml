keyinsts = []
keyenabled = [1,0,1,0,1,1,0,1,0,1,0,1]
keyswitched = []
for (var _i = 0; _i < 12; _i++) {
    var _inst = instance_create_depth(640,360,0,obj_pianokey)
    _inst.image_xscale = 16
    _inst.image_yscale = _inst.image_xscale 
    _inst.image_index = _i
    array_push(keyinsts,_inst)
}
draw_set_font(font_main)

// wha

scalestr = "wwhwwwh"
keyboard_string = scalestr
function valid_scale(str) {
    var _v = 0
    for (var _i = 0; _i < string_length(str); _i++) {
        if (_i == 12) {return false}
        var _e = string_char_at(str,_i+1)
        switch (_e) {
        	case "h": _v++; break
            case "w": _v+=2; break
            case "a": _v+=3; break
            default: return false
        }
    }
    return (_v == 12)
}