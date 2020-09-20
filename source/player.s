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

; 2D array of walk animation indices per direction. Slightly awkward data layout
; but makes maths quicker. Sprite is horizontal flipped if MSB set
EXPORT_LABEL PLAYER_ANIMATION_INDICES
    .byte $00, $80, $02, $04    ; Frame 0
    .byte $01, $81, $03, $05    ; Frame 1
    .byte $00, $80, $02, $04    ; Frame 2
    .byte $01, $81, $83, $85    ; Frame 3
        ; Rite Left Down Up

PLAYER_MOVE_SPEED = $0180

.enum PlayerState
    IDLE
    WALKING
.endenum

.enum PlayerFacing
    RIGHT
    LEFT
    DOWN
    UP
.endenum

.segment "CODE"

EXPORT_LABEL updatePlayerState
    inc player1StateTimer   ; Update player state
    lda player1Buttons      ; Check if the player is moving
    and #BUTTON_LEFT | BUTTON_RIGHT | BUTTON_DOWN | BUTTON_UP
    beq @setStandingState
        lda #PlayerState::WALKING   ; Load immediate, compare with memory
        cmp player1State            ; If not already walking, value is instantly
        bne @updateWalkingAnimIndex ; written - saves 2 cycles and 2 bytes :^>
            sta player1State
            lda #$0C                ; Take first step a bit sooner
            sta player1StateTimer
@updateWalkingAnimIndex:
        lda player1StateTimer
        and #%00011000  ; LSB must be 0 to avoid carry bit affecting addition
        clc
        lsr                 ; Now bits 2+3 hold animation frame index
        adc player1Facing
        sta player1AnimIndex
        rts
@setStandingState:
        lda player1State
        bne @exit
            lda #PlayerState::IDLE
            sta player1State
            sta player1StateTimer
            sta player1AnimIndex
@exit:
    rts

EXPORT_LABEL handlePlayerMovement
    lda player1Buttons
    and #BUTTON_RIGHT
    beq @checkLeft
        lda #PlayerFacing::RIGHT
        sta player1Facing
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
        lda #PlayerFacing::LEFT
        sta player1Facing
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
        lda #PlayerFacing::DOWN
        sta player1Facing
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
        lda #PlayerFacing::UP
        sta player1Facing
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
