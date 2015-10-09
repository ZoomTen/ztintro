; ZoomTen's GameBoy sound driver
; version 1.2

UpdateMusic:			; this is the main sound driver
				; updates channel data every frame
	ld a, [seIsPlaying]
	and a			; if 0 (stopped)
	jp z, .stopallsounds
	ld a, [seNumChannels]	; load number of channels
	push af
	call UpdateCh1		; update pulse 1
	pop af
	dec a
	ret z			; return if 1 channel
	push af
	call UpdateCh2		; update pulse 2
	pop af
	dec a
	ret z			; return if 2 channels
	push af
	call UpdateCh3		; update wave
	pop af
	dec a
	ret z			; return if 3 channels
	push af
	call UpdateCh4		; update noise
	pop af			; don't screw up the call stack
	ret
.stopallsounds
	xor a
	ld [rNR12], a
	ld [rNR22], a
	ld [rNR32], a
	ld [rNR42], a
	ld [rNR52], a
	ret
	
NotesCommonPitches:		; note pitches
	dw	$ffff	  ; unused
	dw   44,  156,  262,  363,  457,  547,  631,  710,  786,  854,  923,  986 ; 01-0c (C3-B3)
	dw 1046, 1102, 1155, 1205, 1253, 1297, 1339, 1379, 1417, 1452, 1486, 1517 ; 0d-18 (C4-B4)
	dw 1546, 1575, 1602, 1627, 1650, 1673, 1694, 1714, 1732, 1750, 1767, 1783 ; 19-24 (C5-B5)
	dw 1798, 1812, 1825, 1837, 1849, 1860, 1871, 1881, 1890, 1899, 1907, 1915 ; 25-30 (C6-B6)
	dw 1923, 1930, 1936, 1943, 1949, 1954, 1959, 1964, 1969, 1974, 1978, 1982 ; 31-3c (C7-B7)
	dw 1985, 1988, 1992, 1995, 1998, 2001, 2004, 2006, 2009, 2011, 2013, 2015 ; 3d-48 (C8-B8)
	
Waveforms:			; wave channel waveforms
	dw .w0	;0
	dw .w1	;1
	dw .w2	;2
	dw .w3	;3
	dw .w4	;4
	dw .w5	;5
	dw .w6	;6
	dw .w7	;7
	dw .w8	;8
	dw .w9	;9
	dw .w0	;a
	dw .w0	;b
	dw .w0	;c
	dw .w0	;d
	dw .w0	;e
	dw .w0	;f
.w0			; saw wave
	db $00,$11,$22,$33,$44,$55,$66,$77,$88,$99,$aa,$bb,$cc,$dd,$ee,$ff
.w1			; thingamabob
	db $00,$10,$11,$22,$20,$33,$30,$44,$40,$55,$50,$66,$60,$77,$70,$78
.w2			; pokemon smooth wave ver 1
	db $02,$46,$8A,$CE,$FF,$FE,$ED,$DC,$CB,$A9,$87,$65,$44,$33,$22,$11
.w3			; pokemon smooth wave ver 2
	db $02,$46,$8A,$CE,$EF,$FF,$FE,$EE,$DD,$CB,$A9,$87,$65,$43,$22,$11
.w4			; pokemon smooth wave ver 3
	db $02,$46,$8A,$CD,$EF,$FE,$DE,$FF,$EE,$DC,$BA,$98,$76,$54,$32,$10
.w5			; pokemon smooth wave ver 4
	db $13,$69,$BD,$EE,$EE,$FF,$FF,$ED,$DE,$FF,$FF,$EE,$EE,$DB,$96,$31
.w6			; pokemon saw wave
	db $01,$23,$45,$67,$8A,$CD,$EE,$F7,$7F,$EE,$DC,$A8,$76,$54,$32,$10
.w7			; basic triangle wave
	db $01,$23,$45,$67,$89,$AB,$CD,$EF,$FE,$DC,$BA,$98,$76,$54,$32,$10
.w8			; derp wave
	db $91,$11,$12,$22,$34,$56,$78,$9a,$bc,$cd,$de,$88,$76,$64,$21,$00
.w9			; square wave
	db $FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	
UpdateCh1:				; where all the magic happens :P
; if delay != 0
; don't update music
	ld a, [seCh1Delay]
	and a
	jp nz, .cont
; if length != 0
; don't update music
	ld a, [seCh1Length]
	and a
	jp nz, .cont2
; load music pointers to hl
	ld a, [seCh1CurPointer]
	ld l, a
	ld a, [seCh1CurPointer+1]
	ld h, a
.readcommands
; parse command bytes
	ld a, [hl]
	cp byte_call
	jp z, .pushChannelptr	; run callChannel command
	
	cp byte_endsub
	jp z, .popChannelptr	; run endSub command
	
	cp byte_manual
	jp z, .domanual		; run setManual command
	
	cp byte_length
	jp z, .setlength	; run setLength commannd
	
	cp byte_transpose
	jp z, .transpose	; run transpose command
	
	cp byte_stereo
	jp z, .dostereo		; run stereo command
	
	cp byte_fpitch
	jp z, .finepitch	; run finepitch command
	
	cp byte_loop
	jp z, .loopsong		; run loopChannel command
	
	cp byte_end
	jp z, .disablesound	; run endChannel command
	
	cp byte_duty
	jp z, .updateduty	; run duty command
	
	cp byte_env
	jp z, .setenvelope	; run setEnvelope command
	
	cp byte_speed
	jp z, .setspeed		; run setSpeed command
	
; notes $00 - $48
	cp $49
	jp c, .playnote		; play a note
	jp .end
.cont
; instead decrement the delay
	ld a, [seCh1Delay]
	dec a
	ld [seCh1Delay], a
	ret
.cont2
; decrement length counter
	ld a, [seCh1Length]
	dec a
	ld [seCh1Length], a
	ld a, [seCh1Speed]	; load song speed
	ld [seCh1Delay], a	; set as delay
	ret
.end
; update music pointer in RAM
	ld a, l
	ld [seCh1CurPointer], a
	ld a, h
	ld [seCh1CurPointer+1], a
	ret
.disablesound
; disables all sounds
	xor a
	ld [rNR12], a
	jp .end
.finepitch
; basic command format.
; applies a fine pitch
	inc hl			; read next byte
	ld a, [hl]
	ld [seCh1FinePitch], a	; put variable
	inc hl
	jp .readcommands	; parse the next byte
				; (so we don't sacrifice a frame :P)
.dostereo
; this is a global command, meaning it affects all channels
	inc hl
	ld a, [hl]
	ld [rNR51], a		; change output channels
	inc hl
	jp .readcommands
.updateduty
; changes pulse instrument
; 0=12.5%, 1=25%, 2=50%, 3=75%
	inc hl
	ld a, [hl]
	rla			; duty is set in bits 6-7
	rla			; so we move stuff
	rla
	rla
	rla
	rla
	ld [rNR11], a		; apply duty
	inc hl
	jp .readcommands
.setenvelope
; first nibble  = starting volume
; second nibble = envelope (0-7 down, 8-F up)
	inc hl
	ld a, [hl]
	ld [rNR12], a
	ld [seCh1CurEnvelope], a
	inc hl
	jp .readcommands
.playnote
; plays a note
	ld a, [hl]
	ld [seCh1CurNote], a		; used for debug
	and a
	jp z, .rest			; if rest note
	ld b, a
	ld a, [seCh1CurEnvelope]	; reinstate envelope
					; if not
	ld [rNR12], a
	ld a, [seCh1Transpose]		; transpose
	add b
	push hl
	ld hl, NotesCommonPitches
	ld c, a
	xor a
	ld b, a				; bc = note offset
	add hl, bc
	add hl, bc
	ld a, [seCh1FinePitch]		; load fine pitch
	ld b, a
	ld a, [hli]			; get frequency's low byte
	sub b				; apply fine pitch
	ld [rNR13], a
	ld a, [hl]			; get frequency's high byte
	set 7, a			; set "sound restart" flag
	ld [rNR14], a
	pop hl
; get delay
	ld a, [seCh1AutoLength]		; check if note length defined
	and a
	jp nz, .setautolength
	inc hl
	ld a, [hl]
	ld [seCh1Length], a
	ld a, [seCh1Speed]	; load song speed
	ld [seCh1Delay], a	; set as delay
	inc hl
	jp .end				; save music pointer to RAM
.loopsong
	inc hl
; save address pointed by the next 2 bytes to RAM,
; replacing the current byte
	ld a, [hli]
	ld [seCh1CurPointer], a
	ld a, [hl]
	ld [seCh1CurPointer+1], a
	jp UpdateCh1		; start back from the top
.domanual
; set manual length mode by clearing the note length
	xor a
	ld [seCh1AutoLength], a
	inc hl
	jp .readcommands
.setlength
; set auto length mode
	inc hl
	ld a, [hl]
	ld [seCh1AutoLength], a
	inc hl
	jp .readcommands
.transpose
; set transpose
	inc hl
	ld a, [hl]
	ld [seCh1Transpose], a
	inc hl
	jp .readcommands
.setautolength
; transfer auto length
	ld a, [seCh1AutoLength]
	ld [seCh1Length], a
	ld a, [seCh1Speed]	; load song speed
	ld [seCh1Delay], a	; set as delay
	inc hl
	jp .end
.pushChannelptr
; saves channel pointer and reads call pointer
	inc hl
	inc hl
	inc hl			; move to next instruction
	ld a, h
	ld [seCh1SavedPointer+1], a
	ld a, l
	ld [seCh1SavedPointer], a
	dec hl
	dec hl
; save address pointed by the next 2 bytes to RAM,
; replacing the current byte
	ld a, [hli]
	ld [seCh1CurPointer], a
	ld a, [hl]
	ld [seCh1CurPointer+1], a
	jp UpdateCh1		; start back from the top
.popChannelptr
; restores channel pointer
	ld a, [seCh1SavedPointer]
	ld [seCh1CurPointer], a
	ld a, [seCh1SavedPointer+1]
	ld [seCh1CurPointer+1], a
	jp UpdateCh1		; start back from the top
.rest
	xor a
	ld [rNR12], a
	ld a, [seCh1AutoLength]		; check if note length defined
	and a
	jp nz, .setautolength
	inc hl
	ld a, [hl]
	ld [seCh1Length], a
	ld a, [seCh1Speed]	; load song speed
	ld [seCh1Delay], a	; set as delay
	inc hl
	jp .end
.setspeed
	inc hl
	ld a, [hl]
	ld [seCh1Speed], a
	inc hl
	jp .readcommands
	
UpdateCh2:
; it's really mostly just the same as ch1
; just with ch1 replaced with ch2
	ld a, [seCh2Delay]
	and a
	jp nz, .cont
	
	ld a, [seCh2Length]
	and a
	jp nz, .cont2
	
	ld a, [seCh2CurPointer]
	ld l, a
	ld a, [seCh2CurPointer+1]
	ld h, a
.readcommands
	ld a, [hl]
	cp byte_call
	jp z, .pushChannelptr	; run callChannel command
	
	cp byte_endsub
	jp z, .popChannelptr	; run endSub command
	
	cp byte_manual
	jp z, .domanual		; run setManual command
	
	cp byte_length
	jp z, .setlength	; run setLength commannd
	
	cp byte_transpose
	jp z, .transpose	; run transpose command
	
	cp byte_stereo
	jp z, .dostereo		; run stereo command
	
	cp byte_fpitch
	jp z, .finepitch	; run finepitch command
	
	cp byte_loop
	jp z, .loopsong		; run loopChannel command
	
	cp byte_end
	jp z, .disablesound	; run endChannel command
	
	cp byte_duty
	jp z, .updateduty	; run duty command
	
	cp byte_env
	jp z, .setenvelope	; run setEnvelope command
	
	cp byte_speed
	jp z, .setspeed		; run setSpeed command
	
; notes $00 - $48
	cp $49
	jp c, .playnote		; play a note
	jp .end
.cont
	ld a, [seCh2Delay]
	dec a
	ld [seCh2Delay], a
	ret
.cont2
	ld a, [seCh2Length]
	dec a
	ld [seCh2Length], a
	ld a, [seCh2Speed]	; load song speed
	ld [seCh2Delay], a	; set as delay
	ret
.end
	ld a, l
	ld [seCh2CurPointer], a
	ld a, h
	ld [seCh2CurPointer+1], a
	ret
.disablesound
	xor a
	ld [rNR22], a
	jp .end
.finepitch
	inc hl			; read next byte
	ld a, [hl]
	ld [seCh2FinePitch], a	; put variable
	inc hl
	jp .readcommands	; parse the next byte
				; (so we don't sacrifice a frame :P)
.dostereo
	inc hl
	ld a, [hl]
	ld [rNR51], a		; change output channels
	inc hl
	jp .readcommands
.updateduty
	inc hl
	ld a, [hl]
	rla			; duty is set in bits 6-7
	rla			; so we move stuff
	rla
	rla
	rla
	rla
	ld [rNR21], a		; apply duty
	inc hl
	jp .readcommands
.setenvelope
	inc hl
	ld a, [hl]
	ld [rNR22], a
	ld [seCh2CurEnvelope], a
	inc hl
	jp .readcommands
.playnote
	ld a, [hl]
	ld [seCh2CurNote], a		; used for debug
	and a
	jp z, .rest			; if rest note
	ld b, a
	ld a, [seCh2CurEnvelope]	; reinstate envelope
					; if not
	ld [rNR22], a
	ld a, [seCh2Transpose]		; transpose
	add b
	push hl
	ld hl, NotesCommonPitches
	ld c, a
	xor a
	ld b, a				; bc = note offset
	add hl, bc
	add hl, bc
	ld a, [seCh2FinePitch]		; load fine pitch
	ld b, a
	ld a, [hli]			; get frequency's low byte
	sub b				; apply fine pitch
	ld [rNR23], a
	ld a, [hl]			; get frequency's high byte
	set 7, a			; set "sound restart" flag
	ld [rNR24], a
	pop hl
	
	ld a, [seCh2AutoLength]		; check if note length defined
	and a
	jp nz, .setautolength
	inc hl
	ld a, [hl]
	ld [seCh2Length], a
	ld a, [seCh2Speed]	; load song speed
	ld [seCh2Delay], a	; set as delay
	inc hl
	jp .end				; save music pointer to RAM
.loopsong
	inc hl
	
	ld a, [hli]
	ld [seCh2CurPointer], a
	ld a, [hl]
	ld [seCh2CurPointer+1], a
	jp UpdateCh2		; start back from the top
.domanual
	xor a
	ld [seCh2AutoLength], a
	inc hl
	jp .readcommands
.setlength
	inc hl
	ld a, [hl]
	ld [seCh2AutoLength], a
	inc hl
	jp .readcommands
.transpose
	inc hl
	ld a, [hl]
	ld [seCh2Transpose], a
	inc hl
	jp .readcommands
.setautolength
	ld a, [seCh2AutoLength]
	ld [seCh2Length], a
	ld a, [seCh2Speed]	; load song speed
	ld [seCh2Delay], a	; set as delay
	inc hl
	jp .end
.pushChannelptr
	inc hl
	inc hl
	inc hl			; move to next instruction
	ld a, h
	ld [seCh2SavedPointer+1], a
	ld a, l
	ld [seCh2SavedPointer], a
	dec hl
	dec hl
	
	ld a, [hli]
	ld [seCh2CurPointer], a
	ld a, [hl]
	ld [seCh2CurPointer+1], a
	jp UpdateCh2		; start back from the top
.popChannelptr
	ld a, [seCh2SavedPointer]
	ld [seCh2CurPointer], a
	ld a, [seCh2SavedPointer+1]
	ld [seCh2CurPointer+1], a
	jp UpdateCh2		; start back from the top
.rest
	xor a
	ld [rNR22], a
	ld a, [seCh2AutoLength]		; check if note length defined
	and a
	jp nz, .setautolength
	inc hl
	ld a, [hl]
	ld [seCh2Length], a
	ld a, [seCh2Speed]	; load song speed
	ld [seCh2Delay], a	; set as delay
	inc hl
	jp .end
.setspeed
	inc hl
	ld a, [hl]
	ld [seCh2Speed], a
	inc hl
	jp .readcommands
	
UpdateCh3:
	ld a, [seCh3Delay]
	and a
	jp nz, .cont
	
	ld a, [seCh3Length]
	and a
	jp nz, .cont2
	
	ld a, [seCh3CurPointer]
	ld l, a
	ld a, [seCh3CurPointer+1]
	ld h, a
.readcommands
	ld a, [hl]
	cp byte_call
	jp z, .pushChannelptr	; run callChannel command
	
	cp byte_endsub
	jp z, .popChannelptr	; run endSub command
	
	cp byte_manual
	jp z, .domanual		; run setManual command
	
	cp byte_length
	jp z, .setlength	; run setLength commannd
	
	cp byte_transpose
	jp z, .transpose	; run transpose command
	
	cp byte_stereo
	jp z, .dostereo		; run stereo command
	
	cp byte_fpitch
	jp z, .finepitch	; run finepitch command
	
	cp byte_loop
	jp z, .loopsong		; run loopChannel command
	
	cp byte_end
	jp z, .disablesound	; run endChannel command
	
	cp byte_wave
	jp z, .updatewave	; run wave set command
	
	cp byte_speed
	jp z, .setspeed		; run setSpeed command
	
	cp byte_halfvol
	jp z, .half		; run half command
; notes $00 - $48
	cp $49
	jp c, .playnote		; play a note
	jp .end
.cont
	ld a, [seCh3Delay]
	dec a
	ld [seCh3Delay], a
	ret
.cont2
	ld a, [seCh3Length]
	dec a
	ld [seCh3Length], a
	ld a, [seCh3Speed]	; load song speed
	ld [seCh3Delay], a	; set as delay
	ret
.end
	ld a, l
	ld [seCh3CurPointer], a
	ld a, h
	ld [seCh3CurPointer+1], a
	ret
.disablesound
	xor a
	ld [rNR32], a
	jp .end
.finepitch
	inc hl			; read next byte
	ld a, [hl]
	ld [seCh3FinePitch], a	; put variable
	inc hl
	jp .readcommands	; parse the next byte
				; (so we don't sacrifice a frame :P)
.dostereo
	inc hl
	ld a, [hl]
	ld [rNR51], a		; change output channels
	inc hl
	jp .readcommands
.updatewave
; this is an update wave command
; high nibble = volume
; low nibble  = wave index
	inc hl
	ld a, [hl]		; get parameter
	and %00001111		; grab lower nibbles
; get wave address
	ld c, a
	xor a
	ld b, a			; wave index
	push hl
	ld hl, Waveforms	; load index
; load wave from index
	add bc
	add bc
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	ld l, e
	ld h, d			; de = wave's address
	ld c, $30
; disable ch3 so we can copy our waveform
	xor a
	ld [rNR30], a
	ld a, [de]			; 0
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 1
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 2
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 3
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 4
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 5
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 6
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 7
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 8
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 9
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 10
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 11
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 12
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 13
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 14
	ld [$FF00+c], a
	inc de
	inc c
	ld a, [de]			; 15
	ld [$FF00+c], a	
; done copying, enable ch3
	ld a, $80
	ld [rNR30], a
	pop hl
; get next parameter
	ld a, [hl]
	rla			; move parameter by 1 bit to the left
	and %11110000		; get volume
	ld [rNR32], a
	ld [seCh3CurEnvelope], a
; done
	inc hl
	jp .readcommands
.playnote
	ld a, [hl]
	ld [seCh3CurNote], a		; used for debug
	and a
	jp z, .rest			; if rest note
	ld b, a
	ld a, [seCh3CurEnvelope]	; reinstate envelope
					; if not
	ld [rNR32], a
	ld a, [seCh3Transpose]		; transpose
	add b
	push hl
	ld hl, NotesCommonPitches
	ld c, a
	xor a
	ld b, a				; bc = note offset
	add hl, bc
	add hl, bc
	ld a, [seCh3FinePitch]		; load fine pitch
	ld b, a
	ld a, [hli]			; get frequency's low byte
	sub b				; apply fine pitch
	ld [rNR33], a
	ld a, [hl]			; get frequency's high byte
	set 7, a			; set "sound restart" flag
	ld [rNR34], a
	pop hl
	
	ld a, [seCh3AutoLength]		; check if note length defined
	and a
	jp nz, .setautolength
	inc hl
	ld a, [hl]
	ld [seCh3Length], a
	ld a, [seCh3Speed]	; load song speed
	ld [seCh3Delay], a	; set as delay
	inc hl
	jp .end				; save music pointer to RAM
.loopsong
	inc hl
	
	ld a, [hli]
	ld [seCh3CurPointer], a
	ld a, [hl]
	ld [seCh3CurPointer+1], a
	jp UpdateCh3		; start back from the top
.domanual
	xor a
	ld [seCh3AutoLength], a
	inc hl
	jp .readcommands
.setlength
	inc hl
	ld a, [hl]
	ld [seCh3AutoLength], a
	inc hl
	jp .readcommands
.transpose
	inc hl
	ld a, [hl]
	ld [seCh3Transpose], a
	inc hl
	jp .readcommands
.setautolength
	ld a, [seCh3AutoLength]
	ld [seCh3Length], a
	ld a, [seCh3Speed]	; load song speed
	ld [seCh3Delay], a	; set as delay
	inc hl
	jp .end
.pushChannelptr
	inc hl
	inc hl
	inc hl			; move to next instruction
	ld a, h
	ld [seCh3SavedPointer+1], a
	ld a, l
	ld [seCh3SavedPointer], a
	dec hl
	dec hl
	
	ld a, [hli]
	ld [seCh3CurPointer], a
	ld a, [hl]
	ld [seCh3CurPointer+1], a
	jp UpdateCh3		; start back from the top
.popChannelptr
	ld a, [seCh3SavedPointer]
	ld [seCh3CurPointer], a
	ld a, [seCh3SavedPointer+1]
	ld [seCh3CurPointer+1], a
	jp UpdateCh3		; start back from the top
.rest
	xor a
	ld [rNR32], a
	ld a, [seCh3AutoLength]		; check if note length defined
	and a
	jp nz, .setautolength
	inc hl
	ld a, [hl]
	ld [seCh3Length], a
	ld a, [seCh3Speed]	; load song speed
	ld [seCh3Delay], a	; set as delay
	inc hl
	jp .end
.setspeed
	inc hl
	ld a, [hl]
	ld [seCh3Speed], a
	inc hl
	jp .readcommands
.half
; plays the same note with half volume?
	ld a, [seCh3CurEnvelope]
	rla
	ld [rNR32], a
	ld a, [seCh3AutoLength]		; check if note length defined
	and a
	jp nz, .setautolength
	inc hl
	ld a, [hl]
	ld [seCh3Length], a
	ld a, [seCh3Speed]	; load song speed
	ld [seCh3Delay], a	; set as delay
	inc hl
	jp .end
	
UpdateCh4:
	ld a, [seCh4Delay]
	and a
	jp nz, .cont
	
	ld a, [seCh4Length]
	and a
	jp nz, .cont2
	
	ld a, [seCh4CurPointer]
	ld l, a
	ld a, [seCh4CurPointer+1]
	ld h, a
.readcommands
	ld a, [hl]
	cp byte_rept
	jp z, .rept		; run reptnote command
	
	cp byte_call
	jp z, .pushChannelptr	; run callChannel command
	
	cp byte_endsub
	jp z, .popChannelptr	; run endSub command
	
	cp byte_manual
	jp z, .domanual		; run setManual command
	
	cp byte_length
	jp z, .setlength	; run setLength commannd
	
	cp byte_stereo
	jp z, .dostereo		; run stereo command

	cp byte_loop
	jp z, .loopsong		; run loopChannel command
	
	cp byte_end
	jp z, .disablesound	; run endChannel command
	
	cp byte_noise
	jp z, .setnoisetype	; run noise command
	
	cp byte_env
	jp z, .setenvelope	; run setEnvelope command
	
	cp byte_speed
	jp z, .setspeed		; run setSpeed command
	
	cp byte_rest
	jp z, .rest		; run rest command
	jp .end
.cont
	ld a, [seCh4Delay]
	dec a
	ld [seCh4Delay], a
	ret

.cont2
	ld a, [seCh4Length]
	dec a
	ld [seCh4Length], a
	ld a, [seCh4Speed]	; load song speed
	ld [seCh4Delay], a	; set as delay
	ret
.end
	ld a, l
	ld [seCh4CurPointer], a
	ld a, h
	ld [seCh4CurPointer+1], a
	ret
.disablesound
	xor a
	ld [rNR42], a
	jp .end
.dostereo
	inc hl
	ld a, [hl]
	ld [rNR51], a		; change output channels
	inc hl
	jp .readcommands
.setenvelope
	inc hl
	ld a, [hl]
	ld [rNR42], a
	ld [seCh4CurEnvelope], a
	inc hl
	jp .readcommands
.setnoisetype
; set noise type
	ld a, [seCh4CurEnvelope]
	ld [rNR42], a			; reload envelope
	inc hl
	ld a, [hl]			; get noise
	ld [rNR43], a
	ld [seCh4CurNote], a
	ld a, $80
	ld [rNR44], a
	ld a, [seCh4AutoLength]		; check if note length defined
	and a
	jp nz, .setautolength
	inc hl
	ld a, [hl]
	ld [seCh4Length], a
	ld a, [seCh4Speed]	; load song speed
	ld [seCh4Delay], a	; set as delay
	inc hl
	jp .end
.loopsong
	inc hl
	ld a, [hli]
	ld [seCh4CurPointer], a
	ld a, [hl]
	ld [seCh4CurPointer+1], a
	jp UpdateCh4		; start back from the top
.domanual
	xor a
	ld [seCh4AutoLength], a
	inc hl
	jp .readcommands
.setlength
	inc hl
	ld a, [hl]
	ld [seCh4AutoLength], a
	inc hl
	jp .readcommands
.setautolength
	ld a, [seCh4AutoLength]
	ld [seCh4Length], a
	ld a, [seCh4Speed]	; load song speed
	ld [seCh4Delay], a	; set as delay
	inc hl
	jp .end
.pushChannelptr
	inc hl
	inc hl
	inc hl			; move to next instruction
	ld a, h
	ld [seCh4SavedPointer+1], a
	ld a, l
	ld [seCh4SavedPointer], a
	dec hl
	dec hl
	
	ld a, [hli]
	ld [seCh4CurPointer], a
	ld a, [hl]
	ld [seCh4CurPointer+1], a
	jp UpdateCh4		; start back from the top
.popChannelptr
	ld a, [seCh4SavedPointer]
	ld [seCh4CurPointer], a
	ld a, [seCh4SavedPointer+1]
	ld [seCh4CurPointer+1], a
	jp UpdateCh4		; start back from the top
.rest
	xor a
	ld [rNR42], a
	ld a, [seCh4AutoLength]		; check if note length defined
	and a
	jp nz, .setautolength
	inc hl
	ld a, [hl]
	ld [seCh4Length], a
	ld a, [seCh4Speed]	; load song speed
	ld [seCh4Delay], a	; set as delay
	inc hl
	jp .end
.setspeed
	inc hl
	ld a, [hl]
	ld [seCh4Speed], a
	inc hl
	jp .readcommands
.rept
	ld a, [seCh4CurNote]
	ld [rNR43], a
	ld a, $80
	ld [rNR44], a
	ld a, [seCh4AutoLength]
	ld [seCh4Length], a
	ld a, [seCh4Speed]	; load song speed
	ld [seCh4Delay], a	; set as delay
	inc hl
	jp .end