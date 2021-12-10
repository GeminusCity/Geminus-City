/mob/living/simple_mob/humanoid/zombie
	name = "zombie"
	desc = "A rotting human - or at least, what remains of one."
	tt_desc = "Homo putredine"
	speak_emote = "growls"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/human

	maxHealth = 70
	health = 70
	movement_cooldown = 20
	poison_resist = 1
	unsuitable_atoms_damage = 0
	taser_kill = 0

	melee_damage_lower = 6
	melee_damage_upper = 12
	attack_sharp = 1
	attack_edge = 1
	attack_sound = 'sound/weapons/bite.ogg'

	icon = 'icons/mob/animal.dmi'
	icon_state = "zombie"
	icon_living = "zombie"
	icon_dead = "zombie_dead"

	faction = "zombie"
	ai_holder_type = /datum/ai_holder/simple_mob/melee

	response_help  = "touches"
	response_disarm = "pushes aside"
	response_harm   = "punches"

/mob/living/simple_mob/humanoid/zombie/proc/Revive()
	spawn(rand(75, 600)) //yes it's awful to have nested sleep() statements, but short of some funky goto usage, this is the only way
		visible_message(pick(
		"[src] twitches slightly...",
		"Did [src] just move?",
		"[src]'s wounds seem a little less severe than they were a moment ago...",
		"A tumourous growth appears and fades on [src], leaving their wounds slightly smaller than before.",
		"A faint groaning noise comes from [src]. Just the wind, right?",
		"[src]'s fingers spasm, even as it lies dead on the ground.",
		"[src]'s eyes reflexively flit around for a moment."))
		spawn(rand(75, 600))
			visible_message(pick(
			"[src] twitches slightly...",
			"Did [src] just move?",
			"[src]'s wounds seem a little less severe than they were a moment ago...",
			"A tumourous growth appears and fades on [src], leaving their wounds slightly smaller than before.",
			"A faint groaning noise comes from [src]. Just the wind, right?",
			"[src]'s fingers spasm, even as it lies dead on the ground.",
			"[src]'s eyes reflexively flit around for a moment."))
			spawn(rand(75, 600))
				bruteloss = 0
				sleep(20) //We need to delay for a moment so that health can catch up with bruteloss
				if(health > 0)
					icon_state = "zombie"
					stat -= DEAD

/mob/living/simple_mob/humanoid/zombie/death()
	stat += DEAD
	icon_state = "zombie_dead"
	if((health + bruteloss) > 0) //burn damage puts zombies down for good
		Revive()
