/// @desc
display_set_gui_size(window_get_width(),window_get_height())
if (keyboard_check_pressed(vk_enter)) {
    if (array_length(list) > 0) {
        var _num = irandom(array_length(list)-1)
        string_show = $"({_num+1}/{array_length(list)})\n{list[_num]}"
    }
} 
if (keyboard_check_pressed(vk_escape)) {
    change_list()
}

if (keyboard_check_pressed(ord("C")) && keyboard_check(vk_control)) {
    if (string_show != "") {
        clipboard_set_text(string_show)
    }
}

draw_set_font(fontMain)
draw_text(10,10,"Press [Enter] for Random / Press [Esc] to Change File")
draw_text_ext(10,34,string_show,12,502)
