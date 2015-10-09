; steven you-nee-verse

SONG1TR		equ 2

Sound1_Ch1::
	stereo 15, 15
	setSpeed 0
	setEnvelope 15, 5
	duty 1
	finepitch 1
	transpose 0 + SONG1TR
	noterow rs,0, 5,4
	noterow C_,3, 5,2
	noterow A_,2, 5,2
	noterow C_,3, 5,2
	noterow A_,2, 5,2
	noterow C_,3, 5,2
	noterow D_,3, 5,2
	noterow E_,3, 5,4
	noterow F_,3, 5,2
	noterow E_,3, 5,10
	noterow D_,3, 5,2
	noterow C_,3, 5,4
	noterow F_,2, 5,4
	noterow G_,2, 5,4
	noterow A_,2, 5,2
	noterow D_,3, 5,2
	noterow C_,3, 5,2
	noterow C_,3, 5,4
	noterow G_,2, 5,2
	noterow A_,2, 5,2
	noterow A#,2, 5,2
	noterow A_,2, 5,6
	noterow C_,3, 5,2
	noterow A_,2, 5,2
	noterow C_,3, 5,2
	noterow A_,2, 5,2
	noterow C_,3, 5,2
	noterow D_,3, 5,2
	noterow E_,3, 5,4
	noterow F_,3, 5,2
	noterow E_,3, 5,4
	noterow C_,3, 5,4
	noterow C_,3, 5,2
	noterow F_,3, 5,4
	noterow F_,3, 5,2
	noterow F_,3, 5,4
	noterow D_,3, 5,2
	noterow D_,3, 5,2
	noterow D_,3, 5,2
	noterow A_,3, 5,4
	noterow G_,3, 5,2
	noterow F_,3, 5,6
	noterow E_,3, 5,4
	noterow C_,3, 5,16
.loop
	noterow A_,3, 5,4
	noterow G_,3, 5,2
	noterow F_,3, 5,4
	noterow G_,3, 5,4
	noterow E_,3, 5,16
	noterow C_,3, 5,2
	noterow A_,3, 5,4
	noterow G_,3, 5,4
	noterow F_,3, 5,4
	noterow E_,3, 5,2
	noterow F_,3, 5,16
	noterow C_,3, 5,2
	noterow A_,3, 5,4
	noterow G_,3, 5,4
	noterow F_,3, 5,4
	noterow E_,3, 5,2
	noterow C_,3, 5,10
	noterow C_,3, 5,8
	noterow A_,3, 5,4
	noterow G_,3, 5,4
	noterow F_,3, 5,4
	noterow E_,3, 5,2
	noterow F_,3, 5,14
	noterow C_,3, 5,4
	noterow A_,3, 5,6
	noterow G_,3, 5,2
	noterow F_,3, 5,2
	noterow G_,3, 5,6
	noterow A_,3, 5,8
	noterow G_,3, 5,8
	noterow E_,3, 5,12
	noterow G_,3, 5,2
	noterow G_,3, 5,4
	noterow F_,3, 5,14
	noterow A_,3, 5,2
	noterow G_,3, 5,4
	noterow F_,3, 5,4
	noterow G_,3, 5,4
	noterow F_,3, 5,10
	noterow C#,3, 5,8
	noterow A_,3, 5,12
	noterow G_,3, 5,4
	noterow F_,3, 5,16
	loopChannel .loop
	
Sound1_Ch2::
	setSpeed 0
	setEnvelope 12, 5
	duty 2
	transpose -12 + SONG1TR
	
	noterow A_,2, 5,16
	noterow A_,2, 5,16
	noterow A#,2, 5,16
	noterow A#,2, 5,12
	noterow A#,2, 5,2
	noterow A_,2, 5,2
	callChannel .ACh
	callChannel .ACh
	callChannel .AsCh
	callChannel .AsCh
.loop
	callChannel .ACh
	callChannel .ACh
	callChannel .ACh
	callChannel .ACh
	
	callChannel .AsCh
	callChannel .AsCh
	callChannel .AsCh
	callChannel .AsCh
	
	callChannel .ACh
	callChannel .ACh
	callChannel .ACh
	callChannel .ACh
	
	callChannel .AsCh
	callChannel .AsCh
	callChannel .AsCh
	callChannel .AsCh
	
	loopChannel .loop
	
.ACh
	noterow A_,2, 5,6
	noterow A_,2, 5,6
	noterow A_,2, 5,4
	endSub
.AsCh
	noterow A#,2, 5,6
	noterow A#,2, 5,6
	noterow A#,2, 5,4
	endSub
	
Sound1_Ch3::
	setSpeed 0
	wave 1, 9
	transpose 0 + SONG1TR
	noterow F_,1, 5,4
	noterow rs,0, 5,12
	noterow E_,1, 5,4
	noterow rs,0, 5,12
	noterow D_,1, 5,4
	noterow rs,0, 5,12
	noterow C_,1, 5,4
	noterow rs,0, 5,8
	noterow D_,1, 5,2
	noterow E_,1, 5,2
	
	noterow F_,1, 5,4
	noterow rs,0, 5,2
	noterow F_,1, 5,4
	noterow rs,0, 5,2
	noterow F_,1, 5,4
	
	noterow E_,1, 5,4
	noterow rs,0, 5,2
	noterow E_,1, 5,4
	noterow rs,0, 5,2
	noterow E_,1, 5,4
	
	noterow D_,1, 5,4
	noterow rs,0, 5,2
	noterow D_,1, 5,4
	noterow D_,0, 5,2
	noterow D_,1, 5,4
	noterow D_,1, 5,6
	noterow C_,1, 5,2
	noterow E_,1, 5,8
	noterow F_,1, 5,32
.loop
	callChannel .octE
	callChannel .octE
	callChannel .octD
	callChannel .octD
	callChannel .octCs
	callChannel .octE
	
	callChannel .octF
	callChannel .octF
	callChannel .octE
	callChannel .octE
	callChannel .octD
	callChannel .octD
	callChannel .octCs
	callChannel .octCs
	callChannel .octF
	callChannel .octF
	loopChannel .loop
	
.octE
	wave 1, 9
	noterow E_,1, 5,2
	noterow E_,2, 5,2
	noterow E_,1, 5,2
	noterow E_,2, 5,2
	noterow E_,1, 5,2
	noterow E_,2, 5,2
	noterow E_,1, 5,2
	noterow E_,2, 5,2
	endSub
	
.octF
	wave 1, 9
	noterow F_,1, 5,2
	noterow F_,2, 5,2
	noterow F_,1, 5,2
	noterow F_,2, 5,2
	noterow F_,1, 5,2
	noterow F_,2, 5,2
	noterow F_,1, 5,2
	noterow F_,2, 5,2
	endSub
	
.octD
	wave 1, 9
	noterow D_,1, 5,2
	noterow D_,2, 5,2
	noterow D_,1, 5,2
	noterow D_,2, 5,2
	noterow D_,1, 5,2
	noterow D_,2, 5,2
	noterow D_,1, 5,2
	noterow D_,2, 5,2
	endSub
.octCs
	wave 1, 9
	noterow C#,1, 5,2
	noterow C#,2, 5,2
	noterow C#,1, 5,2
	noterow C#,2, 5,2
	noterow C#,1, 5,2
	noterow C#,2, 5,2
	noterow C#,1, 5,2
	noterow C#,2, 5,2
	endSub
	
Sound1_Ch4::
	setSpeed 0
	restrow 5,16
	restrow 5,16
	restrow 5,16
	restrow 5,16
	restrow 5,16
	restrow 5,16
	restrow 5,16
	restrow 5,16
	setEnvelope 14, 1
	noiserow $43, 5,16
	noiserow $43, 5,6
	noiserow $43, 5,6
	callChannel .snare
	callChannel .snare
.loop
	setEnvelope 14, 1
	noiserow $43, 5,2
	setEnvelope 9, 1
	noiserow $35, 5,2
	
	callChannel .snare
	
	setEnvelope 14, 1
	noiserow $43, 5,2
	setEnvelope 9, 1
	noiserow $35, 5,2
	
	setEnvelope 14, 1
	noiserow $43, 5,2
	
	callChannel .snare
	
	setEnvelope 9, 1
	noiserow $35, 5,2
	
	loopChannel .loop
.snare
	setEnvelope 14, 0
	noise $27, 1
	setEnvelope 13, 1
	noise $24, 7
	endSub