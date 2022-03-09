; player.s
; Sean Latham, 2020

.include "nes.inc"
.include "macros.inc"
.include "global.s"

.segment "TEXT"

; Not really the best place to store tile indices. Should be alongside actual
; tile data. Would also be nice to programatically determine indices
PLAYER_PATTERN_START = $00
EXPORT_LABEL PLAYER_METASPRITE_TL
    .byte PLAYER_PATTERN_START + $00 ; Idle
    .byte PLAYER_PATTERN_START + $04 ; Squashed
    .byte PLAYER_PATTERN_START + $08 ; Stretched
    
EXPORT_LABEL PLAYER_METASPRITE_TR
    .byte PLAYER_PATTERN_START + $01 ; Idle
    .byte PLAYER_PATTERN_START + $05 ; Squashed
    .byte PLAYER_PATTERN_START + $09 ; Stretched
    
EXPORT_LABEL PLAYER_METASPRITE_BL
    .byte PLAYER_PATTERN_START + $02 ; Idle
    .byte PLAYER_PATTERN_START + $06 ; Squashed
    .byte PLAYER_PATTERN_START + $0A ; Stretched
    
EXPORT_LABEL PLAYER_METASPRITE_BR
    .byte PLAYER_PATTERN_START + $03 ; Idle
    .byte PLAYER_PATTERN_START + $08 ; Squashed
    .byte PLAYER_PATTERN_START + $0B ; Stretched

PLAYER_ACCELERATION = $00C0
PLAYER_TOP_RIGHT_SPEED = $0200
PLAYER_TOP_LEFT_SPEED = ~PLAYER_TOP_RIGHT_SPEED + 1

.enum PlayerState
    IDLE
    JUMPING
    FALLING
.endenum

.enum PlayerFacing
    RIGHT
    LEFT
.endenum

.segment "CODE"

EXPORT_LABEL updatePlayerState
    inc player1StateTimer   ; Update player state
@exit:
    rts

EXPORT_LABEL handlePlayerMovement
    lda player1Buttons      ; Update player input
    and #BUTTON_RIGHT
    beq @checkLeft
        lda #PlayerFacing::RIGHT
        sta player1Facing
        clc
        lda player1XSpeedLo
        adc #<PLAYER_ACCELERATION
        sta player1XSpeedLo
        lda player1XSpeedHi
        adc #>PLAYER_ACCELERATION
        sta player1XSpeedHi
        lda player1XSpeedLo             ; Check if speed now exceeds maximum
        cmp #<PLAYER_TOP_RIGHT_SPEED    ; Sets carry flag for next SBC
        lda player1XSpeedHi
        sbc #>PLAYER_TOP_RIGHT_SPEED
        bvc :+              ; N eor V
            eor #$80
:       bmi @postHandleInput
            lda #<PLAYER_TOP_RIGHT_SPEED
            sta player1XSpeedLo
            lda #>PLAYER_TOP_RIGHT_SPEED
            sta player1XSpeedHi
            bne @postHandleInput        ; Should be guaranteed branch
@checkLeft:
    lda player1Buttons
    and #BUTTON_LEFT
    beq @handleNoInput
        lda #PlayerFacing::LEFT
        sta player1Facing
        sec
        lda player1XSpeedLo
        sbc #<PLAYER_ACCELERATION
        sta player1XSpeedLo
        lda player1XSpeedHi
        sbc #>PLAYER_ACCELERATION
        sta player1XSpeedHi
        lda player1XSpeedLo             ; Check if speed now exceeds maximum
        cmp #<PLAYER_TOP_LEFT_SPEED     ; Sets carry flag for next SBC
        lda player1XSpeedHi
        sbc #>PLAYER_TOP_LEFT_SPEED
        bvc :+              ; N eor V
            eor #$80
:       bpl @postHandleInput
            lda #<PLAYER_TOP_LEFT_SPEED
            sta player1XSpeedLo
            lda #>PLAYER_TOP_LEFT_SPEED
            sta player1XSpeedHi
            bne @postHandleInput        ; Should be guaranteed branch
@handleNoInput:
    lda player1XSpeedLo                 ; Check speed is non-zero
    bne :+
        lda player1XSpeedHi
        beq @postHandleInput
:   lda player1XSpeedHi
    bmi @handleNoInputNegSpeed
        sec
        lda player1XSpeedLo
        sbc #<PLAYER_ACCELERATION
        sta player1XSpeedLo
        lda player1XSpeedHi
        sbc #>PLAYER_ACCELERATION
        bcc :+
            lda #$00
            sta player1XSpeedLo
:       sta player1XSpeedHi
        jmp @postHandleInput
@handleNoInputNegSpeed:
    clc
    lda player1XSpeedLo
    adc #<PLAYER_ACCELERATION
    sta player1XSpeedLo
    lda player1XSpeedHi
    adc #>PLAYER_ACCELERATION
    bcc :+
        lda #$00
        sta player1XSpeedLo
:   sta player1XSpeedHi

@postHandleInput:
@movePlayer:
    lda player1XLo
    adc player1XSpeedLo
    sta player1XLo
    lda player1XHi
    adc player1XSpeedHi
    sta player1XHi
    rts

EXPORT_LABEL drawPlayerSprite
    ldy player1AnimIndex
    
    lda player1YHi       ; Scrolling sprite test, top-left
    sta oamBuffer+0
    lda PLAYER_METASPRITE_TL, y
    sta oamBuffer+1
    lda #$00
    sta oamBuffer+2
    lda player1XHi
    sta oamBuffer+3
    
    lda player1YHi       ; Scrolling sprite test, top-right
    sta oamBuffer+4
    lda PLAYER_METASPRITE_TR, y
    sta oamBuffer+5
    lda #$00
    sta oamBuffer+6
    lda player1XHi
    clc
    adc #$08
    sta oamBuffer+7
    
    lda player1YHi       ; Scrolling sprite test, bottom-left
    adc #$08
    sta oamBuffer+8
    lda PLAYER_METASPRITE_BL, y
    sta oamBuffer+9
    lda #$00
    sta oamBuffer+10
    lda player1XHi
    sta oamBuffer+11
    
    lda player1YHi       ; Scrolling sprite test, top-right
    adc #$08
    sta oamBuffer+12
    lda PLAYER_METASPRITE_BR, y
    sta oamBuffer+13
    lda #$00
    sta oamBuffer+14
    lda player1XHi
    clc
    adc #$08
    sta oamBuffer+15
    rts

; EOF
