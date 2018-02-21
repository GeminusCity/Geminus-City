/*
CONTAINS:
T-RAY
DETECTIVE SCANNER
HEALTH ANALYZER
GAS ANALYZER
MASS SPECTROMETER
REAGENT SCANNER
*/


/obj/item/device/healthanalyzer
	name = "health analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	icon_state = "health"
	item_state = "healthanalyzer"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = ITEMSIZE_SMALL
	throw_speed = 5
	throw_range = 10
	matter = list(DEFAULT_WALL_MATERIAL = 200)
	origin_tech = list(TECH_MAGNET = 1, TECH_BIO = 1)
	var/mode = 1;
	var/advscan = 0
	var/showadvscan = 1

/obj/item/device/healthanalyzer/New()
	if(advscan >= 1)
		verbs += /obj/item/device/healthanalyzer/proc/toggle_adv
	..()

/obj/item/device/healthanalyzer/do_surgery(mob/living/M, mob/living/user)
	if(user.a_intent != I_HELP) //in case it is ever used as a surgery tool
		return ..()
	scan_mob(M, user) //default surgery behaviour is just to scan as usual
	return 1

/obj/item/device/healthanalyzer/attack(mob/living/M, mob/living/user)
	scan_mob(M, user)

/obj/item/device/healthanalyzer/proc/scan_mob(mob/living/M, mob/living/user)
	if ((CLUMSY in user.mutations) && prob(50))
		user << text("<span class='warning'>You try to analyze the floor's vitals!</span>")
		for(var/mob/O in viewers(M, null))
			O.show_message("<span class='warning'>\The [user] has analyzed the floor's vitals!</span>", 1)
		user.show_message("<span class='notice'>Analyzing Results for The floor:</span>", 1)
		user.show_message("<span class='notice'>Overall Status: Healthy</span>", 1)
		user.show_message("<span class='notice'>    Damage Specifics: 0-0-0-0</span>", 1)
		user.show_message("<span class='notice'>Key: Suffocation/Toxin/Burns/Brute</span>", 1)
		user.show_message("<span class='notice'>Body Temperature: ???</span>", 1)
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return
	user.visible_message("<span class='notice'>[user] has analyzed [M]'s vitals.</span>","<span class='notice'>You have analyzed [M]'s vitals.</span>")

	if (!istype(M,/mob/living/carbon/human) || M.isSynthetic())
		//these sensors are designed for organic life
		user.show_message("<span class='notice'>Analyzing Results for ERROR:\n\t Overall Status: ERROR</span>")
		user.show_message("<span class='notice'>    Key: <font color='cyan'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font></span>", 1)
		user.show_message("<span class='notice'>    Damage Specifics: <font color='cyan'>?</font> - <font color='green'>?</font> - <font color='#FFA500'>?</font> - <font color='red'>?</font></span>")
		user.show_message("<span class='notice'>Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>", 1)
		user.show_message("<span class='warning'>Warning: Blood Level ERROR: --% --cl.</span> <span class='notice'>Type: ERROR</span>")
		user.show_message("<span class='notice'>Subject's pulse: <font color='red'>-- bpm.</font></span>")
		return

	var/fake_oxy = max(rand(1,40), M.getOxyLoss(), (300 - (M.getToxLoss() + M.getFireLoss() + M.getBruteLoss())))
	var/OX = M.getOxyLoss() > 50 	? 	"<b>[M.getOxyLoss()]</b>" 		: M.getOxyLoss()
	var/TX = M.getToxLoss() > 50 	? 	"<b>[M.getToxLoss()]</b>" 		: M.getToxLoss()
	var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 			? 	"<b>[fake_oxy]</b>" 			: fake_oxy
		user.show_message("<span class='notice'>Analyzing Results for [M]:</span>")
		user.show_message("<span class='notice'>Overall Status: dead</span>")
	else
		user.show_message("<span class='notice'>Analyzing Results for [M]:\n\t Overall Status: [M.stat > 1 ? "dead" : "[round((M.health/M.getMaxHealth())*100) ]% healthy"]</span>")
	user.show_message("<span class='notice'>    Key: <font color='cyan'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font></span>", 1)
	user.show_message("<span class='notice'>    Damage Specifics: <font color='cyan'>[OX]</font> - <font color='green'>[TX]</font> - <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font></span>")
	user.show_message("<span class='notice'>Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>", 1)
	if(M.tod && (M.stat == DEAD || (M.status_flags & FAKEDEATH)))
		user.show_message("<span class='notice'>Time of Death: [M.tod]</span>")
	if(istype(M, /mob/living/carbon/human) && mode == 1)
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_organs(1,1)
		user.show_message("<span class='notice'>Localized Damage, Brute/Burn:</span>",1)
		if(length(damaged)>0)
			for(var/obj/item/organ/external/org in damaged)
				if(org.robotic >= ORGAN_ROBOT)
					continue
				else
					user.show_message(text("<span class='notice'>     []: [][] - []</span>",
					capitalize(org.name),
					(org.brute_dam > 0) ? "<span class='warning'>[org.brute_dam]</span>" : 0,
					(org.status & ORGAN_BLEEDING)?"<span class='danger'>\[Bleeding\]</span>":"",
					(org.burn_dam > 0) ? "<font color='#FFA500'>[org.burn_dam]</font>" : 0),1)
		else
			user.show_message("<span class='notice'>    Limbs are OK.</span>",1)

	OX = M.getOxyLoss() > 50 ? 	"<font color='cyan'><b>Severe oxygen deprivation detected</b></font>" 		: 	"Subject bloodstream oxygen level normal"
	TX = M.getToxLoss() > 50 ? 	"<font color='green'><b>Dangerous amount of toxins detected</b></font>" 	: 	"Subject bloodstream toxin level minimal"
	BU = M.getFireLoss() > 50 ? 	"<font color='#FFA500'><b>Severe burn damage detected</b></font>" 			:	"Subject burn injury status O.K"
	BR = M.getBruteLoss() > 50 ? "<font color='red'><b>Severe anatomical damage detected</b></font>" 		: 	"Subject brute-force injury status O.K"
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 ? 		"<span class='warning'>Severe oxygen deprivation detected</span>" 	: 	"Subject bloodstream oxygen level normal"
	user.show_message("[OX] | [TX] | [BU] | [BR]")
	if(M.radiation)
		if(advscan >= 2 && showadvscan == 1)
			if(M.radiation >= 75)
				user.show_message("<span class='warning'>Critical levels of radiation detected. Immediate treatment advised.</span>")
			else if(M.radiation >= 50)
				user.show_message("<span class='warning'>Severe levels of radiation detected.</span>")
			else if(M.radiation >= 25)
				user.show_message("<span class='warning'>Moderate levels of radiation detected.</span>")
			else if(M.radiation >= 1)
				user.show_message("<span_class='warning'>Low levels of radiation detected.</span>")
		else
			user.show_message("<span class='warning'>Radiation detected.</span>")
	if(istype(M, /mob/living/carbon))
		var/mob/living/carbon/C = M
		if(C.reagents.total_volume)
			var/unknown = 0
			var/reagentdata[0]
			var/unknownreagents[0]
			for(var/A in C.reagents.reagent_list)
				var/datum/reagent/R = A
				if(R.scannable)
					reagentdata["[R.id]"] = "<span class='notice'>    [round(C.reagents.get_reagent_amount(R.id), 1)]u [R.name]</span>"
				else
					unknown++
					unknownreagents["[R.id]"] = "<span class='notice'>    [round(C.reagents.get_reagent_amount(R.id), 1)]u [R.name]</span>"
			if(reagentdata.len)
				user.show_message("<span class='notice'>Beneficial reagents detected in subject's blood:</span>")
				for(var/d in reagentdata)
					user.show_message(reagentdata[d])
			if(unknown)
				if(advscan >= 3 && showadvscan == 1)
					user.show_message("<span class='warning'>Warning: Non-medical reagent[(unknown>1)?"s":""] detected in subject's blood:</span>")
					for(var/d in unknownreagents)
						user.show_message(unknownreagents[d])
				else
					user.show_message("<span class='warning'>Warning: Unknown substance[(unknown>1)?"s":""] detected in subject's blood.</span>")
		if(C.ingested && C.ingested.total_volume)
			var/unknown = 0
			var/stomachreagentdata[0]
			var/stomachunknownreagents[0]
			for(var/B in C.ingested.reagent_list)
				var/datum/reagent/T = B
				if(T.scannable)
					stomachreagentdata["[T.id]"] = "<span class='notice'>    [round(C.ingested.get_reagent_amount(T.id), 1)]u [T.name]</span>"
					if (advscan == 0 || showadvscan == 0)
						user.show_message("<span class='notice'>[T.name] found in subject's stomach.</span>")
				else
					++unknown
					stomachunknownreagents["[T.id]"] = "<span class='notice'>    [round(C.ingested.get_reagent_amount(T.id), 1)]u [T.name]</span>"
			if(advscan >= 1 && showadvscan == 1)
				user.show_message("<span class='notice'>Beneficial reagents detected in subject's stomach:</span>")
				for(var/d in stomachreagentdata)
					user.show_message(stomachreagentdata[d])
			if(unknown)
				if(advscan >= 3 && showadvscan == 1)
					user.show_message("<span class='warning'>Warning: Non-medical reagent[(unknown > 1)?"s":""] found in subject's stomach:</span>")
					for(var/d in stomachunknownreagents)
						user.show_message(stomachunknownreagents[d])
				else
					user.show_message("<span class='warning'>Unknown substance[(unknown > 1)?"s":""] found in subject's stomach.</span>")
		if(C.virus2.len)
			for (var/ID in C.virus2)
				if (ID in virusDB)
					var/datum/data/record/V = virusDB[ID]
					user.show_message("<span class='warning'>Warning: Pathogen [V.fields["name"]] detected in subject's blood. Known antigen : [V.fields["antigen"]]</span>")
				else
					user.show_message("<span class='warning'>Warning: Unknown pathogen detected in subject's blood.</span>")
	if (M.getCloneLoss())
		user.show_message("<span class='warning'>Subject appears to have been imperfectly cloned.</span>")
//	if (M.reagents && M.reagents.get_reagent_amount("inaprovaline"))
//		user.show_message("<span class='notice'>Bloodstream Analysis located [M.reagents:get_reagent_amount("inaprovaline")] units of rejuvenation chemicals.</span>")
	if (M.has_brain_worms())
		user.show_message("<span class='warning'>Subject suffering from aberrant brain activity. Recommend further scanning.</span>")
	else if (M.getBrainLoss() >= 60 || !M.has_brain())
		user.show_message("<span class='warning'>Subject is brain dead.</span>")
	else if (M.getBrainLoss() >= 25)
		user.show_message("<span class='warning'>Severe brain damage detected. Subject likely to have a traumatic brain injury.</span>")
	else if (M.getBrainLoss() >= 10)
		user.show_message("<span class='warning'>Significant brain damage detected. Subject may have had a concussion.</span>")
	else if (M.getBrainLoss() >= 1 && advscan >= 2 && showadvscan == 1)
		user.show_message("<span class='warning'>Minor brain damage detected.</span>")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/name_i in H.internal_organs_by_name)
			var/obj/item/organ/internal/i = H.internal_organs_by_name[name_i]
			if(istype(i, /obj/item/organ/internal/appendix))
				var/obj/item/organ/internal/appendix/a = H.internal_organs_by_name[name_i]
				if(a.inflamed > 3)
					user.show_message(text("<span class='warning'>Severe inflammation detected in subject [a.name].</span>"), 1)
				else if(a.inflamed > 2)
					user.show_message(text("<span class='warning'>Moderate inflammation detected in subject [a.name].</span>"), 1)
				else if(a.inflamed >= 1)
					user.show_message(text("<span class='warning'>Mild inflammation detected in subject [a.name].</span>"), 1)


		for(var/name in H.organs_by_name)
			var/obj/item/organ/external/e = H.organs_by_name[name]
			if(!e)
				continue
			var/limb = e.name
			if(e.status & ORGAN_BROKEN)
				if(((e.name == "l_arm") || (e.name == "r_arm") || (e.name == "l_leg") || (e.name == "r_leg")) && (!e.splinted))
					to_chat(user, "<span class='warning'>Unsecured fracture in subject [limb]. Splinting recommended for transport.</span>")
			if(e.has_infected_wound())
				to_chat(user, "<span class='warning'>Infected wound detected in subject [limb]. Disinfection recommended.</span>")

		for(var/name in H.organs_by_name)
			var/obj/item/organ/external/e = H.organs_by_name[name]
			if(e && e.status & ORGAN_BROKEN)
				if(advscan >= 1 && showadvscan == 1)
					user.show_message(text("<span class='warning'>Bone fractures detected in subject [e.name].</span>"), 1)
				else
					user.show_message(text("<span class='warning'>Bone fractures detected. Advanced scanner required for location.</span>"), 1)
					break
		for(var/obj/item/organ/external/e in H.organs)
			if(!e)
				continue
			for(var/datum/wound/W in e.wounds) if(W.internal)
				if(advscan >= 1 && showadvscan == 1)
					user.show_message(text("<span class='warning'>Internal bleeding detected in subject [e.name].</span>"), 1)
				else
					user.show_message(text("<span class='warning'>Internal bleeding detected. Advanced scanner required for location.</span>"), 1)
					break
			break

		if(M:vessel)
			var/blood_volume = H.vessel.get_reagent_amount("blood")
			var/blood_percent =  round((blood_volume / H.species.blood_volume)*100)
			var/blood_type = H.dna.b_type
			if((blood_percent <= BLOOD_VOLUME_SAFE) && (blood_percent > BLOOD_VOLUME_BAD))
				user.show_message("<span class='danger'>Warning: Blood Level LOW: [blood_percent]% [blood_volume]cl.</span> <span class='notice'>Type: [blood_type]</span>")
			else if(blood_percent <= BLOOD_VOLUME_BAD)
				user.show_message("<span class='danger'><i>Warning: Blood Level CRITICAL: [blood_percent]% [blood_volume]cl.</i></span> <span class='notice'>Type: [blood_type]</span>")
			else
				user.show_message("<span class='notice'>Blood Level Normal: [blood_percent]% [blood_volume]cl. Type: [blood_type]</span>")
		user.show_message("<span class='notice'>Subject's pulse: <font color='[H.pulse == PULSE_THREADY || H.pulse == PULSE_NONE ? "red" : "blue"]'>[H.get_pulse(GETPULSE_TOOL)] bpm.</font></span>")


/obj/item/device/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"

	mode = !mode
	switch (mode)
		if(1)
			to_chat(usr, "The scanner now shows specific limb damage.")
		if(0)
			to_chat(usr, "The scanner no longer shows limb damage.")

/obj/item/device/healthanalyzer/proc/toggle_adv()
	set name = "Toggle Advanced Scan"
	set category = "Object"

	showadvscan = !showadvscan
	switch (showadvscan)
		if(1)
			to_chat(usr, "The scanner will now perform an advanced analysis.")
		if(0)
			to_chat(usr, "The scanner will now perform a basic analysis.")

/obj/item/device/healthanalyzer/improved //reports bone fractures, IB, quantity of beneficial reagents in stomach; also regular health analyzer stuff
	name = "improved health analyzer"
	desc = "A miracle of medical technology, this handheld scanner can produce an accurate and specific report of a patient's biosigns."
	advscan = 1
	origin_tech = list(TECH_MAGNET = 5, TECH_BIO = 6)
	icon_state = "health1"

/obj/item/device/healthanalyzer/advanced //reports all of the above, as well as radiation severity and minor brain damage
	name = "advanced health analyzer"
	desc = "An even more advanced handheld health scanner, complete with a full biosign monitor and on-board radiation and neurological analysis suites."
	advscan = 2
	origin_tech = list(TECH_MAGNET = 6, TECH_BIO = 7)
	icon_state = "health2"

/obj/item/device/healthanalyzer/phasic //reports all of the above, as well as name and quantity of nonmed reagents in stomach
	name = "phasic health analyzer"
	desc = "Possibly the most advanced health analyzer to ever have existed, utilising bluespace technology to determine almost everything worth knowing about a patient."
	advscan = 3
	origin_tech = list(TECH_MAGNET = 7, TECH_BIO = 8)
	icon_state = "health3"

/obj/item/device/analyzer
	name = "analyzer"
	desc = "A hand-held environmental scanner which reports current gas levels."
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = ITEMSIZE_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20

	matter = list(DEFAULT_WALL_MATERIAL = 30,"glass" = 20)

	origin_tech = list(TECH_MAGNET = 1, TECH_ENGINEERING = 1)

/obj/item/device/analyzer/atmosanalyze(var/mob/user)
	var/air = user.return_air()
	if (!air)
		return

	return atmosanalyzer_scan(src, air, user)

/obj/item/device/analyzer/attack_self(mob/user as mob)

	if (user.stat)
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	analyze_gases(src, user)
	return

/obj/item/device/mass_spectrometer
	name = "mass spectrometer"
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	icon_state = "spectrometer"
	w_class = ITEMSIZE_SMALL
	flags = CONDUCT | OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20

	matter = list(DEFAULT_WALL_MATERIAL = 30,"glass" = 20)

	origin_tech = list(TECH_MAGNET = 2, TECH_BIO = 2)
	var/details = 0
	var/recent_fail = 0

/obj/item/device/mass_spectrometer/New()
	..()
	var/datum/reagents/R = new/datum/reagents(5)
	reagents = R
	R.my_atom = src

/obj/item/device/mass_spectrometer/on_reagent_change()
	if(reagents.total_volume)
		icon_state = initial(icon_state) + "_s"
	else
		icon_state = initial(icon_state)

/obj/item/device/mass_spectrometer/attack_self(mob/user as mob)
	if (user.stat)
		return
	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(reagents.total_volume)
		var/list/blood_traces = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id != "blood")
				reagents.clear_reagents()
				to_chat(user, "<span class='warning'>The sample was contaminated! Please insert another sample</span>")
				return
			else
				blood_traces = params2list(R.data["trace_chem"])
				break
		var/dat = "Trace Chemicals Found: "
		for(var/R in blood_traces)
			if(details)
				dat += "[R] ([blood_traces[R]] units) "
			else
				dat += "[R] "
		to_chat(user, "[dat]")
		reagents.clear_reagents()
	return

/obj/item/device/mass_spectrometer/adv
	name = "advanced mass spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = list(TECH_MAGNET = 4, TECH_BIO = 2)

/obj/item/device/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents."
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = ITEMSIZE_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	matter = list(DEFAULT_WALL_MATERIAL = 30,"glass" = 20)

	origin_tech = list(TECH_MAGNET = 2, TECH_BIO = 2)
	var/details = 0
	var/recent_fail = 0

/obj/item/device/reagent_scanner/afterattack(obj/O, mob/user as mob, proximity)
	if(!proximity)
		return
	if (user.stat)
		return
	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(!istype(O))
		return

	if(!isnull(O.reagents))
		var/dat = ""
		if(O.reagents.reagent_list.len > 0)
			var/one_percent = O.reagents.total_volume / 100
			for (var/datum/reagent/R in O.reagents.reagent_list)
				dat += "\n \t <span class='notice'>[R][details ? ": [R.volume / one_percent]%" : ""]</span>"
		if(dat)
			to_chat(user, "<span class='notice'>Chemicals found: [dat]</span>")
		else
			user << "<span class='notice'>No active chemical agents found in [O].</span>"
	else
		user << "<span class='notice'>No significant chemical agents found in [O].</span>"

	return

/obj/item/device/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = list(TECH_MAGNET = 4, TECH_BIO = 2)

/obj/item/device/slime_scanner
	name = "slime scanner"
	icon_state = "xenobio"
	item_state = "xenobio"
	origin_tech = list(TECH_BIO = 1)
	w_class = ITEMSIZE_SMALL
	flags = CONDUCT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	matter = list(DEFAULT_WALL_MATERIAL = 30,"glass" = 20)

/obj/item/device/slime_scanner/attack(mob/living/M as mob, mob/living/user as mob)
	if(!isslime(M))
		user << "<B>This device can only scan slimes!</B>"
		return
	var/mob/living/simple_animal/slime/S = M
	user.show_message("Slime scan results:")
	user.show_message(text("[S.slime_color] [] slime", S.is_adult ? "adult" : "baby"))

	user.show_message("Health: [S.health]")
	user.show_message("Mutation Probability: [S.mutation_chance]")

	var/list/mutations = list()
	for(var/potential_color in S.slime_mutation)
		var/mob/living/simple_animal/slime/slime = potential_color
		mutations.Add(initial(slime.slime_color))

	user.show_message("Potental to mutate into [english_list(mutations)] colors.")
	user.show_message("Extract potential: [S.cores]")

	user.show_message(text("Nutrition: [S.nutrition]/[]", S.get_max_nutrition()))
	if (S.nutrition < S.get_starve_nutrition())
		user.show_message("<span class='alert'>Warning: Subject is starving!</span>")
	else if (S.nutrition < S.get_hunger_nutrition())
		user.show_message("<span class='warning'>Warning: Subject is hungry.</span>")
	user.show_message("Electric change strength: [S.power_charge]")

	if(S.resentment)
		user.show_message("<span class='warning'>Warning: Subject is harboring resentment.</span>")
	if(S.docile)
		user.show_message("Subject has been pacified.")
	if(S.rabid)
		user.show_message("<span class='danger'>Subject is enraged and extremely dangerous!</span>")
	if(S.unity)
		user.show_message("Subject is friendly to other slime colors.")

	user.show_message("Growth progress: [S.amount_grown]/10")
