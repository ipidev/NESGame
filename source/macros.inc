; macros.inc
; Sean Latham, 2020

.if !.defined(MACROS_INC)
.define MACROS_INC

.macro ALIAS alias, original
	.if !.defined(alias)
		alias = original
	.endif
.endmacro

.macro SWAP_NIBBLES
	asl
	adc #$80
	rol
	asl
	adc #$80
	rol
.endmacro

.endif	; MACROS_INC

; EOF
