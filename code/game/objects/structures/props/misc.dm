/obj/structure/prop/misc/display_case
	name = "display case"
	desc = "A display case for prized possessions. It taunts you to kick it."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassboxb0"
	density = 1
	anchored = 1
	interaction_message = "<span class='notice'>Whatever object this display case once held is now long gone.</span>"

/obj/structure/prop/misc/vending_machine
	name = "A broken vending machine"
	desc = "This is why you never shake the machine"
	icon = 'icons/obj/vending.dmi'
	icon_state = "gift-allly-machine"
	density = TRUE
	anchored= TRUE
	interaction_message = "An old fortten gift machine. The treasures it once held have been lost to time or found a new home inside a pawnshop."

/obj/structure/prop/water_fountain
	name = "water fountain"
	desc = "A water fountain for drinking, naturally."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "water_fountain"
	interaction_message = "<span class='notice'>You sip some water from fountain.</span>"

/obj/structure/prop/water_fountain/attack_hand(mob/living/user)
	if(!istype(user, /mob/living/carbon/human))
		return FALSE

	var/mob/living/carbon/human/H = user
	if(!H.check_has_mouth())
		to_chat(user, "<span class='warning'>How do you want to drink water? You don't have a mouth!</span>")
		return FALSE

	var/obj/item/blocked = H.check_mouth_coverage()
	if(blocked)
		user << "<span class='warning'>\The [blocked] is in the way!</span>"
		return FALSE

	user.setClickCooldown(user.get_attack_speed(src))
	playsound(user.loc, 'sound/items/drink.ogg', rand(10, 50), 1)

	var/datum/reagents/reagents = new /datum/reagents
	reagents.add_reagent("water", 5)
	reagents.trans_to_mob(user, issmall(user) ? 2.5 : 5, CHEM_INGEST)
	qdel(reagents)
	..()

/obj/structure/prop/water_fountain/attackby(obj/item/W, mob/user)
	if(!istype(W, /obj/item/weapon/reagent_containers))
		return FALSE
	
	var/obj/item/weapon/reagent_containers/R = W
	
	to_chat(user, "<span class='notice'>You fill [W] with some water from fountain.</span>")
	user.setClickCooldown(user.get_attack_speed(src))

	var/datum/reagents/reagents = new /datum/reagents
	reagents.add_reagent("water", 5)
	reagents.trans_to_holder(R.reagents, 5)
	qdel(reagents)
