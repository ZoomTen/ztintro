; requires wram.asm

PlaySound::
	di				; stop music updating
	push af
; clear sound RAM
	call StopSound
; set play flag...
	ld a, 1
	ld [seIsPlaying], a
; load sound pointers
	pop af
	ld hl, SoundPointers
	push bc
	ld c, a
	ld b, 0
; load appropriate entry
	add hl, bc
	add hl, bc
; load address from pointer
	ld a, [hli]
	ld c, a
	ld a, [hl]
	ld b, a
	push bc
	pop hl
	pop bc
; parse pointer
	ld a, [hli]	; get number of channels
	ld [seNumChannels], a
	ld c, a
; first channel...
	ld a, [hli]
	ld [seCh1CurPointer], a
	ld a, [hli]
	ld [seCh1CurPointer+1], a
	dec c
	jr z, .done	; if 1 channel, done
; second channel...
	ld a, [hli]
	ld [seCh2CurPointer], a
	ld a, [hli]
	ld [seCh2CurPointer+1], a
	dec c
	jr z, .done	; if 2 channels, done
; third channel...
	ld a, [hli]
	ld [seCh3CurPointer], a
	ld a, [hli]
	ld [seCh3CurPointer+1], a
	dec c
	jr z, .done	; if 3 channels, done
; fourth channel...
	ld a, [hli]
	ld [seCh4CurPointer], a
	ld a, [hli]
	ld [seCh4CurPointer+1], a
.done
	ei
	ret
	
StopSound::
	di
	ld hl, seIsPlaying
	xor a
	ld [hli], a
	ld [hli], a
	ld [rNR12], a
	ld [rNR22], a
	ld [rNR32], a
	ld [rNR42], a
	ld c, 4*2*2		; 16-bit variables
.clearsoundram1
	ld [hli],a
	dec c
	jr nz, .clearsoundram1
	ld [hli], a
	ld c, 5*4		; 8-bit variables
.clearsoundram2
	ld [hli],a
	dec c
	jr nz, .clearsoundram2
	ei
	ret
	
PauseSound::			; for pausing/resuming playback
	di
	ld a, [seIsPlaying]
	bit 0, a
	jr nz, .reset
	set 0, a
	ld [seIsPlaying], a
; restore volume
	ld a, [seCh1CurEnvelope]
	ld [rNR12], a
	ld a, [seCh2CurEnvelope]
	ld [rNR22], a
	ld a, [seCh3CurEnvelope]
	ld [rNR32], a
	ld a, [seCh4CurEnvelope]
	ld [rNR42], a
	ei
	ret
.reset
	res 0, a
	ld [seIsPlaying], a
	ei
	ret