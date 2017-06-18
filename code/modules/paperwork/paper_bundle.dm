/obj/item/weapon/paper_bundle
	name = "paper bundle"
	gender = PLURAL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	throwforce = 0
	w_class = 1.0
	throw_range = 2
	throw_speed = 1
	layer = 4
	pressure_resistance = 1
	attack_verb = list("bapped")
	var/amount = 0 //Amount of items clipped to the paper
	var/page = 1
	var/screen = 0

/obj/item/weapon/paper_bundle/attackby(obj/item/weapon/W, mob/user)
	..()
	var/obj/item/weapon/paper/P
	if(istype(W, /obj/item/weapon/paper))
		P = W
		if (istype(P, /obj/item/weapon/paper/carbon))
			var/obj/item/weapon/paper/carbon/C = P
			if (!C.iscopy && !C.copied)
				user << "<span class='notice'>Take off the carbon copy first.</span>"
				add_fingerprint(user)
				return
		if(loc == user)
			user.drop_inv_item_on_ground(P)
			attach_doc(P, user)
	else if(istype(W, /obj/item/weapon/photo))
		if(loc == user)
			user.drop_inv_item_on_ground(W)
			attach_doc(W, user)
	else if(istype(W, /obj/item/weapon/flame))
		burnpaper(W, user)
	else if(istype(W, /obj/item/weapon/paper_bundle))
		if(loc == user)
			user.drop_inv_item_on_ground(W)
			for(var/obj/O in W)
				attach_doc(O, user, TRUE)
			user << "<span class='notice'>You add \the [W.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name].</span>"
			cdel(W)
	else
		if(istype(W, /obj/item/weapon/pen) || istype(W, /obj/item/toy/crayon))
			usr << browse("", "window=[name]") //Closes the dialog
		P = contents[page]
		P.attackby(W, user)

	update_icon()
	attack_self(user) //Update the browsed page.
	add_fingerprint(user)



/obj/item/weapon/paper_bundle/proc/burnpaper(obj/item/weapon/flame/P, mob/user)
	var/class = "<span class='warning'>"

	if(P.lit && !user.is_mob_restrained())
		if(istype(P, /obj/item/weapon/flame/lighter/zippo))
			class = "<span class='rose'>"

		user.visible_message("[class][user] holds \the [P] up to \the [src], it looks like \he's trying to burn it!", \
		"[class]You hold \the [P] up to \the [src], burning it slowly.")

		spawn(20)
			if(get_dist(src, user) < 2 && user.get_active_hand() == P && P.lit)
				user.visible_message("[class][user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.", \
				"[class]You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.")

				if(user.get_inactive_hand() == src)
					user.drop_inv_item_on_ground(src)

				new /obj/effect/decal/cleanable/ash(src.loc)
				cdel(src)

			else
				user << "\red You must hold \the [P] steady to burn \the [src]."


/obj/item/weapon/paper_bundle/examine(mob/user)
	user << desc
	if(in_range(user, src))
		src.attack_self(user)
	else
		user << "<span class='notice'>It is too far away.</span>"


/obj/item/weapon/paper_bundle/attack_self(mob/user as mob)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/dat
		var/obj/item/weapon/W = contents[page]
		switch(screen)
			if(0)
				dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=\ref[src];remove=1'>Remove [(istype(W, /obj/item/weapon/paper)) ? "paper" : "photo"]</A></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV><BR><HR>"
			if(1)
				dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=\ref[src];remove=1'>Remove [(istype(W, /obj/item/weapon/paper)) ? "paper" : "photo"]</A></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV><BR><HR>"
			if(2)
				dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=\ref[src];remove=1'>Remove [(istype(W, /obj/item/weapon/paper)) ? "paper" : "photo"]</A></DIV><BR><HR>"
				dat+= "<DIV STYLE='float;left; text-align:right; with:33.33333%'></DIV>"
		if(istype(src[page], /obj/item/weapon/paper))
			var/obj/item/weapon/paper/P = W
			if(!(istype(usr, /mob/living/carbon/human) || istype(usr, /mob/dead/observer) || istype(usr, /mob/living/silicon)))
				dat+= "<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[stars(P.info)][P.stamps]</BODY></HTML>"
			else
				dat+= "<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[P.info][P.stamps]</BODY></HTML>"
			human_user << browse(dat, "window=[name]")
			P.add_fingerprint(usr)
		else if(istype(src[page], /obj/item/weapon/photo))
			var/obj/item/weapon/photo/P = W
			human_user << browse_rsc(P.img, "tmp_photo.png")
			human_user << browse(dat + "<html><head><title>[P.name]</title></head>" \
			+ "<body style='overflow:hidden'>" \
			+ "<div> <img src='tmp_photo.png' width = '180'" \
			+ "[P.scribble ? "<div> Written on the back:<br><i>[P.scribble]</i>" : ]"\
			+ "</body></html>", "window=[name]")
			P.add_fingerprint(usr)
		add_fingerprint(usr)
		update_icon()
	return


/obj/item/weapon/paper_bundle/Topic(href, href_list)
	..()
	if((src in usr.contents) || (istype(src.loc, /obj/item/weapon/folder) && (src.loc in usr.contents)))
		if(href_list["next_page"])
			if(page == amount)
				screen = 2
			else if(page == 1)
				screen = 1
			else if(page == amount+1)
				return
			page++
			playsound(src.loc, "pageturn", 15, 1)
		if(href_list["prev_page"])
			if(page == 1)
				return
			else if(page == 2)
				screen = 0
			else if(page == amount+1)
				screen = 1
			page--
			playsound(src.loc, "pageturn", 15, 1)
		if(href_list["remove"])
			var/obj/item/weapon/W = contents[page]
			usr.put_in_hands(W)
			usr << "<span class='notice'>You remove the [W.name] from the bundle.</span>"
			if(amount == 1)
				var/obj/item/weapon/paper/P = contents[1]
				usr.drop_inv_item_on_ground(src)
				usr.put_in_hands(P)
				cdel(src)
				return
			else if(page == amount)
				screen = 2
			else if(page == amount+1)
				page--

			amount--
			update_icon()

		src.attack_self(src.loc)
		updateUsrDialog()
	else
		usr << "<span class='notice'>You need to hold it in hands!</span>"




/obj/item/weapon/paper_bundle/verb/rename()
	set name = "Rename bundle"
	set category = "Object"
	set src in usr

	var/n_name = copytext(sanitize(input(usr, "What would you like to label the bundle?", "Bundle Labelling", null)  as text), 1, MAX_NAME_LEN)
	if((loc == usr && usr.stat == 0))
		name = "[(n_name ? text("[n_name]") : "paper")]"
	add_fingerprint(usr)



/obj/item/weapon/paper_bundle/verb/remove_all()
	set name = "Loose bundle"
	set category = "Object"
	set src in usr

	usr << "<span class='notice'>You loosen the bundle.</span>"
	for(var/obj/O in src)
		O.forceMove(usr.loc)
		O.add_fingerprint(usr)
	usr.drop_inv_item_on_ground(src)
	cdel(src)


/obj/item/weapon/paper_bundle/update_icon()
	if(contents.len)
		var/obj/item/I = contents[1]
		icon_state = I.icon_state
		overlays = I.overlays
	underlays = 0
	var/i = 0
	var/photo
	for(var/obj/O in src)
		var/image/IMG = image('icons/obj/bureaucracy.dmi')
		if(istype(O, /obj/item/weapon/paper))
			IMG.icon_state = O.icon_state
			IMG.pixel_x -= min(1*i, 2)
			IMG.pixel_y -= min(1*i, 2)
			pixel_x = min(0.5*i, 1)
			pixel_y = min(  1*i, 2)
			underlays += IMG
			i++
		else if(istype(O, /obj/item/weapon/photo))
			var/obj/item/weapon/photo/PH = O
			IMG = PH.tiny
			photo = 1
			overlays += IMG
	if(i>1)
		desc =  "[i] papers clipped to each other."
	else
		desc = "A single sheet of paper."
	if(photo)
		desc += "\nThere is a photo attached to it."
	overlays += image('icons/obj/bureaucracy.dmi', "clip")

/obj/item/weapon/paper_bundle/proc/attach_doc(obj/item/I, mob/living/user, no_message)
	if(I.loc == user)
		user.drop_inv_item_on_ground(I)
	I.forceMove(src)
	I.add_fingerprint(user)
	amount++
	if(!no_message)
		user << "<span class='notice'>You add [I] to [src].</span>"
	if(screen == 2)
		screen = 1
	update_icon()

