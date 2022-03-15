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

.macro EXPORT_LABEL label
    label:
    .export label
.endmacro

.macro GUARANTEED_BEQ label, constant
    .if .paramcount = 2
        .assert constant = $00, error, "Value will fail BEQ branch"
    .endif
    beq label
    .if .paramcount = 1
        .ifdef DEBUG
            brk
        .endif
    .endif
.endmacro

.macro GUARANTEED_BNE label, constant
    .if .paramcount = 2
        .assert constant <> $00, error, "Value will fail BNE branch"
    .endif
    bne label
    .if .paramcount = 1
        .ifdef DEBUG
            brk
        .endif
    .endif
.endmacro

.macro GUARANTEED_BPL label, constant
    .if .paramcount = 2
        .assert constant & $80 = 0, error, "Value will fail BPL branch"
    .endif
    bpl label
    .if .paramcount = 1
        .ifdef DEBUG
            brk
        .endif
    .endif
.endmacro

.macro GUARANTEED_BMI label, constant
    .if .paramcount = 2
        .assert constant & $80 = 0, error, "Value will fail BMI branch"
    .endif
    bmi label
    .if .paramcount = 1
        .ifdef DEBUG
            brk
        .endif
    .endif
.endmacro

.endif  ; MACROS_INC

; EOF
