; Sound engine constants

; Command constants
byte_end		EQU	$FF
				; (NOT IMPLEMENTED YET)
;byte_reptch	EQU	$FE	; Repeats a part of the song n times, 1-byte parameter.
				; Param 1: times to repeat section	
byte_loop	EQU	$FD	
byte_fpitch	EQU	$FC	
byte_noise	EQU	$FB
byte_duty	EQU	$FB
byte_wave	EQU	$FB
byte_env	EQU	$FA
byte_stereo	EQU	$F9
byte_manual	EQU	$F8
byte_length	EQU	$F7
byte_transpose	EQU	$F6
byte_call	EQU	$F5
byte_endsub	EQU	$F4
byte_rest	EQU	$F3
byte_rept	EQU	$F2
byte_speed	EQU	$F1
byte_halfvol	EQU	$F0

; Base notes
rs		EQU	$00
C_		EQU	$01
C#		EQU	$02
D_		EQU	$03
D#		EQU	$04
E_		EQU	$05
F_		EQU	$06
F#		EQU	$07
G_		EQU	$08
G#		EQU	$09
A_		EQU	$0A
A#		EQU	$0B
B_		EQU	$0C

; Duty cycles
duty125		EQU	0
duty25		EQU	1
duty50		EQU	2
duty75		EQU	3

; Wave volumes
full		EQU	1
half		EQU	2
quarter		EQU	3