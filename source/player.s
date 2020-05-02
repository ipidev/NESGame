; player.s
; Sean Latham, 2020

.include "nes.inc"
.include "macros.inc"
.include "global.s"

PLAYER_MOVE_SPEED = $0180

.segment "CODE"

EXPORT_LABEL handlePlayerMovement
    lda player1Buttons
    and #BUTTON_RIGHT
    beq @checkLeft
        clc
        lda player1XLo
        adc #<PLAYER_MOVE_SPEED
        sta player1XLo
        lda player1XHi
        adc #>PLAYER_MOVE_SPEED
        sta player1XHi
@checkLeft:
    lda player1Buttons
    and #BUTTON_LEFT
    beq @checkDown
        sec
        lda player1XLo
        sbc #<PLAYER_MOVE_SPEED
        sta player1XLo
        lda player1XHi
        sbc #>PLAYER_MOVE_SPEED
        sta player1XHi
@checkDown:
    lda player1Buttons
    and #BUTTON_DOWN
    beq @checkUp
        clc
        lda player1YLo
        adc #<PLAYER_MOVE_SPEED
        sta player1YLo
        lda player1YHi
        adc #>PLAYER_MOVE_SPEED
        sta player1YHi
@checkUp:
    lda player1Buttons
    and #BUTTON_UP
    beq @exit
        sec
        lda player1YLo
        sbc #<PLAYER_MOVE_SPEED
        sta player1YLo
        lda player1YHi
        sbc #>PLAYER_MOVE_SPEED
        sta player1YHi
@exit:
    rts

; EOF
