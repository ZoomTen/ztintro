; Audio Test

STARTING_SONG	EQU	0

; Sound engine constants and stuff
INCLUDE	"deflesound/wram.asm"
INCLUDE "hardware_constants.inc"

SECTION "Demo Variables", WRAM0
CurrentTextPointer:	ds 2
ScrollVar1:		ds 1
ScrollVar2:		ds 1
ScrollVar3:		ds 1
SineOffset:		ds 1
Sine2Offset:		ds 1

; The rst vectors are unused.
SECTION "rst 00", ROM0 [$00]
	reti
SECTION "rst 08", ROM0 [$08]
	reti
SECTION "rst 10", ROM0 [$10]
	reti
SECTION "rst 18", ROM0 [$18]
	reti
SECTION "rst 20", ROM0 [$20]
	reti
SECTION "rst 28", ROM0 [$28]
	reti
SECTION "rst 30", ROM0 [$30]
	reti
SECTION "rst 38", ROM0 [$38]
	reti
; Hardware interrupts
SECTION "vblank", ROM0 [$40]
	jp TimerRoutine
SECTION "hblank", ROM0 [$48]
	reti
SECTION "timer",  ROM0 [$50]
	reti
SECTION "serial", ROM0 [$58]
	reti
SECTION "joypad", ROM0 [$60]
	reti
	
SECTION "ROM Header",HOME[$100]
ProgramEntry:
	nop
	jp Start
; Nintendo(TM) logo
	db $CE, $ED, $66, $66, $CC, $0D, $00, $0B, $03, $73, $00, $83, $00, $0C
	db $00, $0D, $00, $08, $11, $1F, $88, $89, $00, $0E, $DC, $CC, $6E, $E6
	db $DD, $DD, $D9, $99, $BB, $BB, $67, $63, $6E, $0E, $EC, $CC, $DD, $DC
	db $99, $9F, $BB, $B9, $33, $3E

	db "ZT-INTRO       "	; Game title
	db $00			; GameBoy type
	db "46"			; New license
	db $00			; SGB flag
	db $01			; Cart type
	db $00			; ROM size, handled by RGBFIX
	db $00			; RAM size
	db $01			; Destination code
	db $33			; Old license
	db $01			; ROM version
	db $00			; Complement checksum, handled by RGBFIX
	dw $0000		; Global checksum, handled by RGBFIX
	
SECTION "Main Program",HOME[$150]
DisableLCD:
	ld a, [rLCDC]
	rlca			; put highest bit on carry flag
	ret nc			; exit if screen is off already
.wait:
	ld a,[rLY]
	cp 144			; V-blank?
	jr c,.wait		; keep waiting if not
	ld a,[rLCDC]
	res 7,a			; reset LCD enabled flag
	ld [rLCDC],a
	ret
	
EnableLCD:
	ld a, [rLCDC]
	set 7, a
	ld [rLCDC], a
	ret

CheckLine:
	ld a, [rLY]
	cp d			; check if a certain scanline is rendering
	jr nz, CheckLine
	ret
	
WaitVRAM:
	di
	ld a, [rSTAT]
	bit 1, a
	jr nz, WaitVRAM		; if 1, wait
	reti
	
FillVRAM:
; a  = value
; hl = dest
; bc = bytecount
; d  = backup for a
	push de
	ld d, a
.loop
	call WaitVRAM
	ld a, d
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, .loop
	pop de
	ret
	
	
CopyVRAM:
; hl = dest
; de = src
; bc = bytecount
	call WaitVRAM
	ld a, [de]
	inc de
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, CopyVRAM
	ret
	
FillRAM:
; a  = value
; hl = dest
; bc = bytecount
; d  = backup for a
	push de
	ld d, a
.loop
	ld a, d
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, .loop
	pop de
	ret
	
	
CopyRAM:
; hl = dest
; de = src
; bc = bytecount
	ld a, [de]
	inc de
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, CopyRAM
	ret
	
CopyRAM1bpp:
; for 1bpp fonts
; hl = dest
; de = src
; bc = bytecount
	ld a, [de]
	inc de
	ld [hli], a
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, CopyRAM1bpp
	ret
	
Start:
	di			; init the whole thing
	ld sp, $DFFF		; set stack
	ld a, %11100100		; set background palette
	ld [rBGP],a
	
	xor a
	ld [rSCX],a		; reset scroll
	ld [rSCY],a
	ld hl, $c000
	ld bc, $dfff - $c000
.clearwram
	xor a
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, .clearwram
	
	call DisableLCD			; LCD needs to be off to copy tiles
; Load the tiles
	ld hl, vChars0
	ld de, FontTiles
	ld bc, $800
	call CopyRAM1bpp
	ld hl, vChars0 + $900
	ld de, LogoTiles
	ld bc, $690
	call CopyRAM
; Load map
	ld hl, vBGMap0 + 3 + ($20 * 4)
	ld de, LogoMap
	ld bc, LogoE - LogoS
.copylogo
	ld a, [de]
	cp $50
	jr z, .skip
.continue
	inc de
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, .copylogo
	jr .continue2
.skip
	push de
	ld de, $20
	add hl, de
	ld de, -15
	add hl, de
	pop de
	inc de
	ld a, [de]
	jr .continue
	
.continue2
	ld a, %10010001		; bg on at 9800, tiles at 8000, lcd on
	ld [rLCDC], a
	
	ld a, STARTING_SONG
	call PlaySong
	
	ld a,%00000101  ; Enable V-blank & timer interrupt
	ld [rIE], a

	ld hl, ScrollerText
	ld a, h
	ld [CurrentTextPointer], a
	ld a, l
	ld [CurrentTextPointer+1], a
Loop:
; d = scanline compare value
; e = table limit
; c = table offset
	call DoGradients
	call DoScroll
; scroll the text
	ld a, [ScrollVar2]
	inc a
	inc a
	ld [ScrollVar2], a
; increment sine offsets
	ld a, [SineOffset]
	inc a
	ld [SineOffset], a

	ld a, [Sine2Offset]
	inc a
	ld [Sine2Offset], a
; get sine
	ld hl, SineTableSize
	ld de, SineOffset
	call GetSine
	ld de, ScrollVar1
	call GetSine2
	
	ld hl, SineTable2Size
	ld de, Sine2Offset
	call GetSine
	ld de, ScrollVar3
	call GetSine2
	sub a, 15
	ld [rSCX], a		; makes the logo move
; done.
	jp Loop
	
DoGradients:
	xor a
	ld d, a
	call CheckLine
	ld a, %11100100		; set background palette
	ld [rBGP],a
	
	ld a, [ScrollVar1]
	ld c, 12
	ld d, a
.dothing
	call CheckLine
	ld a, %00011011		; set background palette
	ld [rBGP],a
	call WaitVRAM
	ld a, [rSCX]
	inc a
	ld [rSCX],a
	inc d
	dec c
	jr nz, .dothing
	ld c, 12
.dothing2
	call CheckLine
	ld a, %00011011		; set background palette
	ld [rBGP],a
	call WaitVRAM
	ld a, [rSCX]
	dec a
	ld [rSCX],a
	inc d
	dec c
	jr nz, .dothing2
	
	
	call CheckLine
	ld a, %11100100		; set background palette
	ld [rBGP],a
	ld a, [ScrollVar3]
	sub a, 15
	ld [rSCX], a
	ret
	
DoScroll:
	ld a, [ScrollVar2]		; current position
	and a
	jr nz, .skiploadingtexttile	; if we're still scrolling
					; skip the routine below
; load text tile
	call WaitVRAM			; ensuring on-time VRAM manipulation
	ld a, [vBGMap0 + $1e0]		; move the first visible tile
	ld [vBGMap0 + $1ff], a		; to the end of the row
	ld b, 20			; tiles to move
	ld hl, vBGMap0 + $1e1		; begin offset
.move
	call WaitVRAM			; wait till it's safe to tinker
					; with VRAM
	ld a, [hl]
	dec hl
	ld [hli], a			; move tile backwards
	inc hl				; next tile
	dec b
	jr nz, .move
; get character from pointer
	ld a, [CurrentTextPointer]
	ld h, a
	ld a, [CurrentTextPointer + 1]
	ld l, a
	ld a, [hl]
	push af
	call WaitVRAM
	pop af
; add new character
	cp "@"				; end of text?
	jr z, .finishtext
	ld [vBGMap0 + $1f3], a
; update the current character pointer
	inc hl
	ld a, h
	ld [CurrentTextPointer], a
	ld a, l
	ld [CurrentTextPointer + 1], a
; reset counter
	ld a, -8
	ld [ScrollVar2], a
.skiploadingtexttile
; update scx
	ld d, 120-4
	call CheckLine
	ld a, [ScrollVar2]
	ld [rSCX], a
	ld a, %00011011		; set background palette
	ld [rBGP],a
	ld d, 128
	call CheckLine
	ld a, %00011001		; set background palette
	ld [rBGP],a
	xor a
	ld [rSCX], a		; return SCX to its place
	ld d, 143
	call CheckLine
	ld a, %11100100		; set background palette
	ld [rBGP],a
	ret
.finishtext
	ld hl, ScrollerText
	ld a, h
	ld [CurrentTextPointer], a
	ld a, l
	ld [CurrentTextPointer+1], a
	jr DoScroll
	
GetSine:
	ld a, [hli]
	ld c, a			; c = sine table size
	ld a, [de]
	cp a, c
	ret nz
	xor a
	ld [de], a
	jr GetSine
	
GetSine2:
	push de
	call GetTable
	pop de
	ld [de], a
	ret
	
GetTable:
	ld d, 0
	ld e, a
	add hl,de
	ld a, [hl]
	ret

INCLUDE "deflesound/interfaces.asm"
INCLUDE "deflesound/engine.asm"

SineTableSize:
	db SineTableE - SineTableS
SineTableS:
	db 40,43,45,47,50,52,55,57,59,61,64,65,67,69,71,72,74,75,76,77,78,79,79,80,80,80,80,80,79,79,78,77,76,75,74,72,71,69,67,65,64,61,59,57,55,52,50,47,45,43,40,37,35,33,30,28,25,23,21,19,16,15,13,11,9,8,6,5,4,3,2,1,1,0,0,0,0,0,1,1,2,3,4,5,6,8,9,11,13,15,16,19,21,23,25,28,30,33,35,37
SineTableE:

SineTable2Size:
	db SineTable2E - SineTable2S
SineTable2S:
	db 15,16,17,18,19,20,21,21,22,23,24,25,25,26,27,27,28,28,29,29,29,30,30,30,30,30,30,30,30,30,29,29,29,28,28,27,27,26,25,25,24,23,22,21,21,20,19,18,17,16,15,14,13,12,11,10,9,9,8,7,6,5,5,4,3,3,2,2,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,2,2,3,3,4,5,5,6,7,8,9,9,10,11,12,13,14
SineTable2E:

FontTiles:
INCBIN	"font.1bpp"

ScrollerText:
	db "YUSH!!!! I FINALLY GOT DEFLEMASK'S SOUND ENGINE WORKING!!! :DDDD "
	db "NOW I CAN MAKE SHIT WITHOUT HAVING TO HANDWRITE ALL OF EM!!!! "
	db "                  @"
	
LogoTiles:
INCBIN	"logo.2bpp"

LogoMap:
LogoS:
	db $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $9e, $50
	db $af, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $50
	db $ae, $af, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bc, $50
	db $bd, $be, $bf, $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $50
	db $cc, $cd, $ce, $cf, $d0, $d1, $d2, $d3, $d4, $d5, $d6, $d7, $d8, $d9, $da, $50
	db $db, $dc, $dd, $de, $df, $e0, $e1, $e2, $e3, $e4, $e5, $e6, $e7, $e8, $e9, $50
	db $ea, $eb, $ec, $ed, $ee, $ef, $f0, $f1, $f2, $f3, $f4, $f5, $f6, $f7, $f8, $50
LogoE:

	INCLUDE "deflesound/data.asm"