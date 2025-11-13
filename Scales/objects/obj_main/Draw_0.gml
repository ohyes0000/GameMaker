var _gkstr = keyboard_string
var _newstr = ""
for (var _i = 0; _i < min(string_length(_gkstr),12); _i++) {
    var _e = string_lower(string_char_at(_gkstr,_i+1))
    if (string_count(_e,"wah")) {_newstr += _e}
}
scalestr = _newstr
keyboard_string = scalestr


draw_set_halign(fa_middle)
draw_set_color((valid_scale(scalestr) ? c_lime : c_gray))
draw_text_transformed(640,420,scalestr,4,4,0)


var _mdown = mouse_check_button(mb_left)
if (!_mdown) {keyswitched = []}

for (var _i = 0; _i < 12; _i++) {
    var _e = keyinsts[_i]
    if (!array_contains(keyswitched,_e)) {
        if (_mdown) {
            if (position_meeting(mouse_x,mouse_y,_e)) {
                keyenabled[_i] = !keyenabled[_i]
                array_push(keyswitched,_e)
            }
        }
    }
    _e.image_blend = (keyenabled[_i] ? c_lime : -1)
}