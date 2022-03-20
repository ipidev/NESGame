; debug.s
; Sean Latham, 2022

.include "nes.inc"
.include "macros.inc"
.include "global.s"

.ifdef DEBUG

.segment "CODE"

; Expects X and Y positions to be below return address on the stack
EXPORT_LABEL debug_addArrow
    txa
    pha
    tya
    pha
    ldy debug_arrowCount
    cpy #$04
    bcs @exit
        tsx
        lda $105, x
        sta debug_arrowYPos, y
        lda $106, x
        sta debug_arrowXPos, y
        iny
        sty debug_arrowCount
@exit:
    pla
    tay
    pla
    tax
    rts

EXPORT_LABEL debug_drawArrows
    sec
    ldx #$04
    ldy #$FF    ; TODO: Need a proper sprite batching method
@loopStart:
    dex
    cpx debug_arrowCount
    bcs @clearSprite
        lda debug_arrowXPos, x
        sta oamBuffer, y
        dey
        txa
        sta oamBuffer, y
        dey
        lda #$10    ; Arrow sprite tile index - really shouldn't be hard-coded!
        sta oamBuffer, y
        dey
        lda debug_arrowYPos, x
        sbc #$01
        sta oamBuffer, y
        dey
        jmp @loopEnd
@clearSprite:
    lda #$FE
    sta oamBuffer, y
    dey
    sta oamBuffer, y
    dey
    sta oamBuffer, y
    dey
    sta oamBuffer, y
    dey
@loopEnd:
    cpx #$00
    bne @loopStart
@exit:
    stx debug_arrowCount    ; Reset arrows for next frame
    rts

.endif ; DEBUG

; EOF
