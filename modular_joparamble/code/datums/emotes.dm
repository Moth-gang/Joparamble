/datum/emote/living/get_sound(mob/living/user)
	if(sound)
		return sound
	else
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/used_sound
			var/possible_sounds
			var/modifier
			if(H.age == AGE_OLD)
				modifier = "old"
			if(!ignore_silent && (H.silent || !H.can_speak()))
				modifier = "silenced"
			if(user.gender == FEMALE && H.dna.species.soundpack_f)
				possible_sounds = H.dna.species.soundpack_f.get_sound(key,modifier)
			else if(H.dna.species.soundpack_m)
				possible_sounds = H.dna.species.soundpack_m.get_sound(key,modifier)
			if(possible_sounds)
				if(islist(possible_sounds))
					var/list/PS = possible_sounds
					if(PS.len > 1)
						used_sound = pick_n_take(possible_sounds)
						if(used_sound == H.last_sound)
							used_sound = pick(possible_sounds)
					else
						used_sound = pick(possible_sounds)
				else //direct file
					used_sound = possible_sounds
				H.last_sound = used_sound
				return used_sound
		else
			return user.get_sound(key)
