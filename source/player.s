; player.s
; Sean Latham, 2020

.include "nes.inc"
.include "macros.inc"
.include "global.s"

.segment "TEXT"

; Not really the best place to store tile indices. Should be alongside actual
; tile data. Would also be nice to programatically determine indices
PLAYER_SPRITE_START = $00
EXPORT_LABEL METASPRITE_TL
    .byte PLAYER_SPRITE_START + $00 ; Facing right, standing
    .byte PLAYER_SPRITE_START + $00 ; Facing right, stepping
    .byte PLAYER_SPRITE_START + $06 ; Facing down, standing
    .byte PLAYER_SPRITE_START + $06 ; Facing down, stepping
    .byte PLAYER_SPRITE_START + $09 ; Facing up, standing
    .byte PLAYER_SPRITE_START + $09 ; Facing up, stepping
    
EXPORT_LABEL METASPRITE_TR
    .byte PLAYER_SPRITE_START + $01 ; Facing right, standing
    .byte PLAYER_SPRITE_START + $01 ; Facing right, stepping
    .byte PLAYER_SPRITE_START + $06 ; Facing down, standing
    .byte PLAYER_SPRITE_START + $06 ; Facing down, stepping
    .byte PLAYER_SPRITE_START + $09 ; Facing up, standing
    .byte PLAYER_SPRITE_START + $09 ; Facing up, stepping
    
EXPORT_LABEL METASPRITE_BL
    .byte PLAYER_SPRITE_START + $02 ; Facing right, standing
    .byte PLAYER_SPRITE_START + $04 ; Facing right, stepping
    .byte PLAYER_SPRITE_START + $08 ; Facing down, standing
    .byte PLAYER_SPRITE_START + $07 ; Facing down, stepping
    .byte PLAYER_SPRITE_START + $0B ; Facing up, standing
    .byte PLAYER_SPRITE_START + $0A ; Facing up, stepping
    
EXPORT_LABEL METASPRITE_BR
    .byte PLAYER_SPRITE_START + $03 ; Facing right, standing
    .byte PLAYER_SPRITE_START + $05 ; Facing right, stepping
    .byte PLAYER_SPRITE_START + $08 ; Facing down, standing
    .byte PLAYER_SPRITE_START + $07 ; Facing down, stepping
    .byte PLAYER_SPRITE_START + $0B ; Facing up, standing
    .byte PLAYER_SPRITE_START + $0A ; Facing up, stepping

PLAYER_MOVE_SPEED = $0180

.segment "CODE"

EXPORT_LABEL updatePlayerState
    inc player1StateTimer   ; Update player state
    lda player1Buttons      ; Check if the player is moving
    and #BUTTON_LEFT | BUTTON_RIGHT | BUTTON_DOWN | BUTTON_UP
    beq @setStandingState
        lda player1State
        cmp #$01            ; Could also handle button input here?
        bne @updateWalkingAnimIndex
            lda #$01
            sta player1State
            lda #$00
            sta player1StateTimer
@updateWalkingAnimIndex:    ; TODO: maybe need anim indices arrays?
        lda player1StateTimer
        and #$08
        beq @setSecondWalkingFrame
            lda #$00
            sta player1AnimIndex
            jmp @exit
@setSecondWalkingFrame:
            lda #$01
            sta player1AnimIndex
            jmp @exit
@setStandingState:
        lda player1State
        bne @exit
            lda #$00
            sta player1State
            sta player1StateTimer
            sta player1AnimIndex

@exit:
    rts

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
