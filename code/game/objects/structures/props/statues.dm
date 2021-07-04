/obj/structure/prop/statue
	name = "statue"
	desc = "A statue."
	icon = 'icons/obj/statuelarge.dmi'

/obj/structure/prop/info_terminal
	name = "info terminal"
	desc = "An information terminal where one can learn something new."
	icon = 'icons/obj/props/misc.dmi'
	icon_state = "infoterm"

/obj/structure/prop/statue/phoron
	name = "phoronic cascade"
	desc = "A sculpture made of pure phoron. It is covered in a lacquer that prevents erosion and renders it fireproof. It's safe. Probably."
	icon_state = "phoronic"
	layer = ABOVE_WINDOW_LAYER
	interaction_message = "<span class = 'notice'>Cool to touch and unbelievable smooth. You can almost see your reflection in it.</span>"

/obj/structure/prop/statue/phoron/New()
	set_light(2, 3, "#cc66ff")