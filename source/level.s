; level.s
; Sean Latham, 2022

.include "nes.inc"
.include "macros.inc"
.include "global.s"

.segment "TEXT"

TEST_LEVEL:
    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$01
    .byte $01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00,$01
    .byte $01,$03,$03,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$04,$01,$01,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$04,$01,$01,$01,$05,$00,$00,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01
    .byte $01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$02,$02,$02,$02,$01,$00,$00,$00,$00,$01,$01,$00,$00,$00,$01
    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

LEVEL_METATILE_TL:
    .byte $00, $01, $02, $06, $0A, $0E

LEVEL_METATILE_TR:
    .byte $00, $01, $03, $07, $0B, $0F

LEVEL_METATILE_BL:
    .byte $00, $01, $04, $08, $0C, $10

LEVEL_METATILE_BR:
    .byte $00, $01, $05, $09, $0D, $11

.segment "CODE"

EXPORT_LABEL loadTestLevel
    ldx #$00            ; Obviously needs to use decompress level data later
:   lda TEST_LEVEL, x
    sta levelLayout, x
    inx
    cpx #LEVEL_LAYOUT_SIZE
    bne :-
    rts

EXPORT_LABEL renderAllLevelLayout
    lda ppuCtrlCache
    and #%11111011      ; Increment PPUADDR horizontally per write
    sta PPUCTRL
    sta ppuCtrlCache

    lda PPUSTATUS       ; Reset PPUADDR latch
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR

    sta tempPtrA        ; A is still $00
    lda #>levelLayout
    sta tempPtrA+1      ; Store pointer for indirect indexed addressing
@writeMetaTileRow:
    ldy #$00
@upperMetaTileLoop:
    lda (tempPtrA), y
    tax
    lda LEVEL_METATILE_TL, x
    sta PPUDATA
    lda LEVEL_METATILE_TR, x
    sta PPUDATA
    iny
    cpy #$10
    bne @upperMetaTileLoop
    ldy #$00            ; Read this row of level layout again for bottom half
@lowerMetaTileLoop:
    lda (tempPtrA), y
    tax
    lda LEVEL_METATILE_BL, x
    sta PPUDATA
    lda LEVEL_METATILE_BR, x
    sta PPUDATA
    iny
    cpy #$10
    bne @lowerMetaTileLoop
    clc
    lda tempPtrA        ; Move pointer to next row of level layout
    adc #$10
    sta tempPtrA        ; We're done once pointer exceeds level size
    cmp #LEVEL_LAYOUT_SIZE
    bcc @writeMetaTileRow
    rts

; tempA contains X-position, tempB contains Y-position (in pixels).
; Returns metatile data in A, clobbers tempA and X
EXPORT_LABEL getMetaTileData
    lda tempA
    lsr
    lsr
    lsr
    lsr
    sta tempA
    lda tempB
    and #$F0
    ora tempA
    tax
    lda levelLayout, x
    rts

; EOF
