if (keyboard_check_pressed(vk_enter)) {
	if (array_length(list) > 0) {
		string_show = list[irandom(array_length(list)-1)]
	}
} 
if (keyboard_check_pressed(vk_escape)) {
	change_list()
}

draw_set_font(fontMain)
draw_text(10,10,"Press [Enter] for Random / Press [Esc] to Change File")
draw_text_ext(10,34,string_show,12,502)