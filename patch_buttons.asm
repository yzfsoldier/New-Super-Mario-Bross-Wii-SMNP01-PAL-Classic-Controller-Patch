#inject 0x801eb6f8
.entry:
  addi      r1, r1, 0x50
  stwu r1,-0x30(r1)
  mflr r0
  stw r4,0x10(r1)
  stw r5,0x14(r1)
  stw r6,0x18(r1)
  stw r26,0x1C(r1)
  stfs	f8,0x20(r1)
  stfs	f9,0x24(r1)
  stfs	f10,0x28(r1)
  stfs	f11,0x2C(r1)
  lbz r5,0x5C(r26)
  cmpwi r5,2
  bne .cleanup
  lwz r5,0x60(r26)

.tilt:
  lwz		r5,	0x80(r26)
  cmpwi	r5,	0
  beq		.skip_tilt_left
  lfs     f11, 0x80(r26)
  lis		r5,	0
  stw		r5,	0x80(r26)
  lfs		f10, 0x80(r26)
  fsubs	f11, f10, f11
  stfs    f11, 0x58(r26)
  li		r5,	0
  stw     r5,	0x54(r26)

.skip_tilt_left:
  lwz		r5,	0x7C(r26)
  cmpwi	r5,	0
  beq		.skip_tilt_right
  stw     r5,	0x58(r26)
  li		r5,	0
  stw     r5,	0x54(r26)

.skip_tilt_right:
  lwz     r5,0x60(r26)
  bl     .patch_buttons
  lwz     r4,0(r26)
  or      r5,r5,r4
  stw     r5,0(r26)
  lwz     r5,0x64(r26)
  bl      .patch_buttons
  lwz     r4,4(r26)
  or      r5,r5,r4
  stw     r5,4(r26)
  lwz     r5,0x68(r26)
  bl      .patch_buttons
  lwz     r4,8(r26)
  or      r5,r5,r4
  stw     r5,8(r26)

.cleanup:
	lwz		r4,0x10(r1)
	lwz		r5,0x14(r1)
	lwz		r6,0x18(r1)
	lwz		r26,0x1C(r1)
	lfs		f8,0x20(r1)
	lfs		f9,0x24(r1)
	lfs		f10,0x28(r1)
	lfs		f11,0x2C(r1)
	mtlr    r0
	addi	r1,r1,0x30
	blr

.patch_buttons:
  li r6,0
  andi.     r4, r5, 0x800
  beq-      .skip_home
  ori       r6, r6, 0x8000

.skip_home:
  andi.     r4, r5, 0x28
  beq-      .skip_y_x
  ori       r6, r6, 0x200

.skip_y_x:
  andi.     r4, r5, 0x50
  beq-      .skip_a_b
  ori       r6, r6, 0x100


.skip_a_b:
  andi.     r4, r5, 0x400
  beq-      .skip_plus
  ori       r6, r6, 0x10

.skip_plus:
  andi.     r4, r5, 0x1000
  beq-      .skip_minus
  ori       r6, r6, 0x1000

.skip_minus:
  andi.     r4, r5, 0x2200
  beq-      .skip_zl_zr
  lis       r6, 0x7FC0
  stw       r6, 0x10(r26)

.skip_zl_zr:
  andi. r4,r5,0xC003
  beq- analog

  andi.     r4, r5, 0x1
  beq-      .skip_up
  ori       r6, r6, 0x2

.skip_up:
  andi.     r4, r5, 0x2
  beq-      .skip_left
  ori       r6, r6, 0x8

.skip_left:
  andi.     r4, r5, 0x8000
  beq-      .skip_right
  ori       r6, r6, 0x4

.skip_right:
  andi.     r4, r5, 0x4000
  beq-      .skip_down
  ori       r6, r6, 0x1

.skip_down:
  mr        r5, r6
  blr

analog:
	lfs		f8,0x6c(r26)
	lfs		f9,0x70(r26)

	lis		r5,float_one@ha
	lfs		f10,float_one@l(r5)

	lis		r5,float_neg_one@ha
	lfs		f11,float_neg_one@l(r5)

	fcmpu	cr0,f8,f10
	blt		skip_right_analog
	ori     r6,r6,4
skip_right_analog:
	fcmpu	cr0,f9,f10
	blt		skip_up_analog
	ori     r6,r6,2
skip_up_analog:
	fcmpu	cr0,f8,f11
	bge		skip_down_analog
	ori     r6,r6,8
skip_down_analog:
	fcmpu	cr0,f9,f11
	bge		skip_left_analog
	ori     r6,r6,1
skip_left_analog:
	mr      r5,r6
	blr

float_one:
.long 0x3f000000
float_neg_one:
.long 0xbf000000
float_zero:
.long 0x00000000
