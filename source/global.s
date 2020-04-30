; global.s
; Sean Latham, 2020

.if !.defined(GLOBAL_S)
.define GLOBAL_S

; Import/export RAM symbol macro originally by Brad Smith
.macro RESZP label, size
	.ifdef EXPORT_GLOBALS
		label: .res size
		.exportzp label
	.else
		.importzp label
	.endif
.endmacro

.macro RES label, size
	.ifdef EXPORT_GLOBALS
		label: .res size
		.export label
	.else
		.import label
	.endif
.endmacro

.segment "ZEROPAGE"

RESZP	tempA,				$01
RESZP	tempB,				$01
RESZP	tempC,				$01
RESZP	tempD,				$01
RESZP	tempE,				$01
RESZP	tempF,				$01
RESZP	tempG,				$01
RESZP	tempH,				$01
RESZP	tempPtrA,			$02
RESZP	tempPtrB,			$02
RESZP	tempPtrC,			$02
RESZP	tempPtrD,			$02

RESZP	gameLoopFlag,		$01	; 0 while game is running, 1 while spinning

RESZP	player1Buttons,		$01
RESZP	player2Buttons,		$01

.segment "STACK"

.segment "OAM"

RES		oamBuffer,			$100

.segment "RAM"

.endif	; GLOBAL_S

; EOF
