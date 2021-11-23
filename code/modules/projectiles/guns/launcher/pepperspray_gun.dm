/obj/item/weapon/gun/launcher/teargun
	name = "BASED GUN"
	desc = "A bulky pump-action grenade launcher. Holds up to 6 grenades in a revolving magazine."
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = ITEMSIZE_LARGE
	force = 10

	fire_sound = 'sound/weapons/empty.ogg'
	fire_sound_text = "a metallic thunk"
	recoil = 0
	throw_distance = 7
	release_force = 5


	possible_transfer_amounts = null
	volume = 500
	matter = list(DEFAULT_WALL_MATERIAL = 4000)


/obj/item/weapon/gun/launcher/teargun/New()
..()
reagents.add_reagent("condensedcapsaicin", 500)