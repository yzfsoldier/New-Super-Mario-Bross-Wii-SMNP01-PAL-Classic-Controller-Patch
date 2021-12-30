#inject 0x801EAF74
waggle_adjust:
	
	lbz		r5, 0x5C(r3)
	cmpwi	r5, 2

	beq cc_waggle

	stfs	f0, 0(r4)
	blr

cc_waggle:

	li		r12, 0
	stw		r12, 0(r4)
	blr
