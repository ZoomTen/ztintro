note:	MACRO
; \1 = note
; \2 = octave
; \3 = delay
	db (\1 + $c * (\2))
	db \3
	ENDM
	
noterow:	MACRO
; \1 = note
; \2 = octave
; \3 = speed
; \4 = num of rows
	db (\1 + $c * (\2))
	db (\3 * \4) - 1
	ENDM
	
notedata:	MACRO
; \1 = note
; \2 = octave
	db (\1 + $c * (\2))
	ENDM
	
endChannel: MACRO
; stops channel playback
	db byte_end
	ENDM
	
loopChannel:	MACRO
; loops from a position
; \1 = loop point
	db byte_loop
	dw \1
	ENDM
	
finepitch:	MACRO
; sets channel's fine pitch
; \1 = pitch shift
	db byte_fpitch, \1
	ENDM
	
noise:	MACRO	
; \1 = noise type
; \2 = delay (if manual mode is set)
	db byte_noise, \1, \2
	ENDM
	
noiserow:	MACRO
; \1 = noise type
; \2 = speed
; \3 = rows
	db byte_noise, \1, (\2 * \3)-1
	ENDM
	
noisedata:	MACRO	
; \1 = noise type
; \2 = delay (if manual mode is set)
	db byte_noise, \1
	ENDM
	
duty:	MACRO
; sets square 1/2 duty cycle
; \1 = duty cycle
	db byte_duty, \1
	ENDM
	
wave:	MACRO
; sets ch 3 wave instrument
; \1 = volume?
; \2 = wave instrument
	db byte_wave, (\1 * $10) + \2
	ENDM
	
setEnvelope:	MACRO
; sets ch 1, 2, 4 envelope
; \1 = start volume
; \2 = volume modifier (0-7 down; 8-F up)
	db byte_env, (\1 * $10) + \2
	ENDM
	
stereo:	MACRO
; sets global stereo effect
; \1 = left
; \2 = right
	db byte_stereo, (\1 * $10) + \2
	ENDM
	
setManual:	MACRO
; sets manual note length mode
	db byte_manual
	ENDM
	
setLength:	MACRO
; sets auto note length
; \1 = length
	db byte_length, \1
	ENDM
	
transpose:	MACRO
; sets channel note transpose
; \1 = transpose
	db byte_transpose, \1
	ENDM
	
callChannel:	MACRO
; plays a section of a channel
; \1 = call point
	db byte_call
	dw \1
	ENDM
	
endSub:		MACRO
; ends a channel section
	db byte_endsub
	ENDM
	
reptnote:	MACRO
; repeats note with the same length
	db byte_rept
	ENDM
	
rest:		MACRO
; only used on noise channel
	db byte_rest, \1
	ENDM
	
restrow:		MACRO
; only used on noise channel
	db byte_rest, (\1 * \2)-1
	ENDM
	
restauto:	MACRO
	db byte_rest
	ENDM
	
setSpeed:	MACRO
; sets a channel's speed
	db byte_speed
	db \1
	ENDM
	
halfvol:		MACRO
	db byte_halfvol
	db \1
	ENDM

halfvol2:		MACRO
; plays note but halved volume
	db byte_halfvol
	ENDM