; Sound engine RAM variables

SECTION "Sound", WRAM0
SoundRamStart::

seIsPlaying::		ds 1	; "is playing" flag
seNumChannels::		ds 1	; number of channels to update

; Sound "PC's" (program counters)
seCh1CurPointer::	ds 2
seCh2CurPointer::	ds 2
seCh3CurPointer::	ds 2
seCh4CurPointer::	ds 2

; Saved sound "PC's"
seCh1SavedPointer::	ds 2
seCh2SavedPointer::	ds 2
seCh3SavedPointer::	ds 2
seCh4SavedPointer::	ds 2

; Delay time until next note
seCh1Delay::		ds 1
seCh2Delay::		ds 1
seCh3Delay::		ds 1
seCh4Delay::		ds 1

; Channel's fine pitch
seCh1FinePitch::	ds 1
seCh2FinePitch::	ds 1
seCh3FinePitch::	ds 1
seCh4FinePitch::	ds 1	; unused

; Current note, used for debugging
seCh1CurNote::		ds 1
seCh2CurNote::		ds 1
seCh3CurNote::		ds 1
seCh4CurNote::		ds 1

; Set note length (for auto mode)
seCh1AutoLength::	ds 1
seCh2AutoLength::	ds 1
seCh3AutoLength::	ds 1
seCh4AutoLength::	ds 1

; Note key transpose
seCh1Transpose::	ds 1
seCh2Transpose::	ds 1
seCh3Transpose::	ds 1
seCh4Transpose::	ds 1	; unused

; Current envelope value
seCh1CurEnvelope::	ds 1
seCh2CurEnvelope::	ds 1
seCh3CurEnvelope::	ds 1
seCh4CurEnvelope::	ds 1

; Length counter
seCh1Length::		ds 1
seCh2Length::		ds 1
seCh3Length::		ds 1
seCh4Length::		ds 1

; Channel speed
seCh1Speed::		ds 1
seCh2Speed::		ds 1
seCh3Speed::		ds 1
seCh4Speed::		ds 1

SoundRamEnd::