; Song pointers
SoundPointers::
	dw Sound1
	
Sound1:
	db 4		; 4 channels
	dw Sound1_Ch1
	dw Sound1_Ch2
	dw Sound1_Ch3
	dw Sound1_Ch4

; Song data
INCLUDE "sound_engine/data/song1.asm"