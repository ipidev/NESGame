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

PLAYER_OAM_ATTRIBTES:
    .byte $00       ; Facing right
    .byte $40       ; Facing left

PLAYER_LEFTMOST_SPRITE_OFFSETS:
    .byte $F8       ; Facing right
    .byte $00       ; Facing left

PLAYER_RIGHTMOST_SPRITE_OFFSETS:
    .byte $00       ; Facing right
    .byte $F8       ; Facing left

PLAYER_ACCELERATION = $00C0
PLAYER_TOP_RIGHT_SPEED = $0200
PLAYER_TOP_LEFT_SPEED = ~PLAYER_TOP_RIGHT_SPEED + 1
PLAYER_TOP_FALL_SPEED = $0480
PLAYER_POSITIVE_COLLISION_OFFSET = $07
PLAYER_NEGATIVE_COLLISION_OFFSET = $F9 ; Can't seem to negate byte literals?
PLAYER_JUMP_SPEED = ~$0480 + 1
PLAYER_JUMP_DECELERATION = $00C0
PLAYER_GRAVITY = $0040

PLAYER_HORIZONTAL_COLLISION_OFFSETS:
    .byte PLAYER_NEGATIVE_COLLISION_OFFSET
    .byte PLAYER_POSITIVE_COLLISION_OFFSET - 1  ; Avoid clipping with ground

PLAYER_VERTICAL_COLLISION_OFFSETS:
    .byte PLAYER_NEGATIVE_COLLISION_OFFSET
    .byte PLAYER_POSITIVE_COLLISION_OFFSET - 1  ; Avoid clipping with wall

.enum PlayerState
    IDLE
    JUMPING
    FALLING
.endenum

.enum PlayerFacing
    RIGHT
    LEFT
.endenum

; Offset between x-axis data and y-axis data for player.
; Can be used as an index for collision functions that handle both axes
PLAYER_POSITION_AXIS_OFFSET = player1YLo - player1XLo

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
:       bmi @checkJump
            lda #<PLAYER_TOP_RIGHT_SPEED
            sta player1XSpeedLo
            lda #>PLAYER_TOP_RIGHT_SPEED
            sta player1XSpeedHi
            GUARANTEED_BNE @checkJump, >PLAYER_TOP_RIGHT_SPEED
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
:       bpl @checkJump
            lda #<PLAYER_TOP_LEFT_SPEED
            sta player1XSpeedLo
            lda #>PLAYER_TOP_LEFT_SPEED
            sta player1XSpeedHi
            GUARANTEED_BNE @checkJump, >PLAYER_TOP_LEFT_SPEED
@handleNoInput:
    lda player1XSpeedLo                 ; Check speed is non-zero
    bne :+
        lda player1XSpeedHi
        beq @checkJump
:   lda player1XSpeedHi
    bmi @handleNoInputNegSpeed
        sec
        lda player1XSpeedLo
        sbc #<PLAYER_ACCELERATION
        sta player1XSpeedLo
        lda player1XSpeedHi
        sbc #>PLAYER_ACCELERATION
        bcc :+                          ; Clamp player speed to zero
            lda #$00
            sta player1XSpeedLo
:       sta player1XSpeedHi
        jmp @checkJump
@handleNoInputNegSpeed:
    clc
    lda player1XSpeedLo
    adc #<PLAYER_ACCELERATION
    sta player1XSpeedLo
    lda player1XSpeedHi
    adc #>PLAYER_ACCELERATION
    bcc :+                          ; Clamp player speed to zero
        lda #$00
        sta player1XSpeedLo
:   sta player1XSpeedHi
@checkJump:
    bit player1Buttons      ; Check A button (bit 7)
    bpl @notPressingJump
        lda player1Grounded
        beq @applyGravity
            lda player1JumpDebounce
            bne @applyGravity
                lda #<PLAYER_JUMP_SPEED ; Trigger jump
                sta player1YSpeedLo
                lda #>PLAYER_JUMP_SPEED
                sta player1YSpeedHi
                lda #$01
                sta player1JumpDebounce
                GUARANTEED_BNE @applyGravity, $01
@notPressingJump:
    lda #$00
    sta player1JumpDebounce
    lda player1Grounded
    bne @applyGravity
        bit player1YSpeedHi
        bpl @applyGravity
            clc
            lda player1YSpeedLo
            adc #<PLAYER_JUMP_DECELERATION  ; Decelerate while A button released
            sta player1YSpeedLo
            lda player1YSpeedHi
            adc #>PLAYER_JUMP_DECELERATION
            sta player1YSpeedHi
@applyGravity:
    clc
    lda player1YSpeedLo     ; Always apply gravity, even while on the ground
    adc #<PLAYER_GRAVITY
    sta player1YSpeedLo
    lda player1YSpeedHi
    adc #>PLAYER_GRAVITY
    sta player1YSpeedHi
    lda player1YSpeedLo             ; Check if speed now exceeds maximum
    cmp #<PLAYER_TOP_FALL_SPEED     ; Sets carry flag for next SBC
    lda player1YSpeedHi
    sbc #>PLAYER_TOP_FALL_SPEED
    bvc :+              ; N eor V
        eor #$80
:   bmi movePlayer
        lda #<PLAYER_TOP_FALL_SPEED
        sta player1YSpeedLo
        lda #>PLAYER_TOP_FALL_SPEED
        sta player1YSpeedHi
    ; Fallthrough to movePlayer


movePlayer:
.scope
; Setup local aliases (we clobber a lot)
tempXPos = tempA    ; Clobbered within this scope
tempYPos = tempB
tempCollisionOffset = tempC
tempXPosMirror = tempD
tempLastLayoutIndex = tempE
tempLastBlockIndex = tempF

movePlayerHorizontally:
    clc
    lda player1XLo
    adc player1XSpeedLo
    sta player1XLo
    lda player1XHi
    adc player1XSpeedHi
    sta player1XHi
    lda #$00
    sta tempLastLayoutIndex         ; Cache the index of the blocks we hit
    lda player1XSpeedHi
    bne @determineOffset
        lda player1XSpeedLo
        bne @usePositiveOffset      ; Always +ve with non-zero lo and zero hi
        beq movePlayerVertically    ; Skip horizontal checks if not moving
@determineOffset:
        bmi :+                      ; Select offset based off velocity
@usePositiveOffset:
            lda #PLAYER_POSITIVE_COLLISION_OFFSET
            bne :++                 ; Should be guaranteed branch
:       lda #PLAYER_NEGATIVE_COLLISION_OFFSET
:       sta tempCollisionOffset     ; Keep hold of the offset we choose
        clc
        adc player1XHi
        sta tempXPosMirror          ; getMetaTileData clobbers the x-position
        ldy #$01
@collisionCheckLoopStart:
        sta tempXPos                ; We reload tempD at the end of the loop
        clc
        lda player1YHi
        adc PLAYER_HORIZONTAL_COLLISION_OFFSETS, y  ; Check top/bottom of player
        sta tempYPos
        jsr getLevelLayoutIndexAtPos
        cmp tempLastLayoutIndex
        beq @collisionCheckLoopEnd  ; Skip if we've already hit this block
            sta tempLastLayoutIndex
            tax
            lda levelLayout, x      ; Which block is this?
            sta tempLastBlockIndex
            beq @collisionCheckLoopEnd  ; Is there no block?
                cmp #$01                ; Is there a solid block?
                bne @setupCollisionWithSpike
                    lda tempXPosMirror
                    ldx #$00
                    jsr resolveBlockCollision
                    jmp @collisionCheckLoopEnd
@setupCollisionWithSpike:
                sec
                sbc #$02
                ; jsr
@collisionCheckLoopEnd:
        lda tempXPosMirror
        dey
        bpl @collisionCheckLoopStart
    ; Fallthrough to movePlayerVertically

movePlayerVertically:
    lda player1YLo
    adc player1YSpeedLo
    sta player1YLo
    lda player1YHi
    adc player1YSpeedHi
    sta player1YHi
    lda #$00
    sta player1Grounded
    sta tempLastBlockIndex      ; Cache the index of the blocks we hit
    lda player1YSpeedHi
    bne @determineOffset
        lda player1YSpeedLo
        bne @usePositiveOffset  ; Always +ve with non-zero lo and zero hi
        beq @exit               ; Skip vertical checks if not moving
@determineOffset:
    bmi :+                      ; Select offset based off velocity
@usePositiveOffset:
        lda #PLAYER_POSITIVE_COLLISION_OFFSET
        bne :++                 ; Should be guaranteed branch
:   lda #PLAYER_NEGATIVE_COLLISION_OFFSET
:   sta tempCollisionOffset     ; Keep hold of the offset we choose
    clc
    adc player1YHi
    sta tempYPos
    ldy #$01
@collisionCheckLoopStart:
    clc
    lda player1XHi
    adc PLAYER_VERTICAL_COLLISION_OFFSETS, y    ; Check left/right of player
    sta tempXPos
    jsr getLevelLayoutIndexAtPos
    cmp tempLastLayoutIndex
    beq @collisionCheckLoopEnd  ; Skip if we've already hit this block
        sta tempLastLayoutIndex
        tax
        lda levelLayout, x      ; Which block is this?
        sta tempLastBlockIndex
        beq @collisionCheckLoopEnd  ; Is there no block?
            cmp #$01                ; Is there a solid block?
            bne @setupCollisionWithSpike
                lda tempYPos
                ldx #PLAYER_POSITION_AXIS_OFFSET
                jsr resolveBlockCollision
                jmp @collisionCheckLoopEnd
@setupCollisionWithSpike:
            sec
            sbc #$02
            ; jsr
@collisionCheckLoopEnd:
    dey
    bpl @collisionCheckLoopStart
@exit:
    rts

; Call with X set to either 0 (x-axis) or the offset between y and x-axis data
; A should be set to the tested position along the given collision axis
; tempC should contain the collision offset calculated based on speed
resolveBlockCollision:
    and #$F0
    bit tempCollisionOffset     ; Find the side of the block closest to us
    bpl :+
        clc
        adc #$10
:   sec
    sbc tempCollisionOffset     ; Move outside the block
    sta player1XHi, x
    lda #$00
    sta player1XLo, x
    sta player1XSpeedHi, x
    sta player1XSpeedLo, x
    cpx #$00
    beq @exit
        bit tempCollisionOffset     ; Only count landing if falling from above
        bmi @exit
            inc player1Grounded
@exit:
    rts
.endscope

EXPORT_LABEL drawPlayerSprite
    ldy player1Facing
    lda PLAYER_OAM_ATTRIBTES, y
    sta tempA
    lda PLAYER_LEFTMOST_SPRITE_OFFSETS, y
    sta tempB
    lda PLAYER_RIGHTMOST_SPRITE_OFFSETS, y
    sta tempC

    ldx #$04
    ldy player1AnimIndex

    sec
    lda player1YHi          ; Top-left
    sbc #$09
    sta OAM_BUFFER_Y_POSITION, x
    lda PLAYER_METASPRITE_TL, y
    sta OAM_BUFFER_TILE_INDEX, x
    lda tempA
    sta OAM_BUFFER_ATTRIBUTES, x
    clc
    lda player1XHi
    adc tempB
    sta OAM_BUFFER_X_POSITION, x
    
    sec
    lda player1YHi          ; Top-right
    sbc #$09
    sta OAM_BUFFER_Y_POSITION+4, x
    lda PLAYER_METASPRITE_TR, y
    sta OAM_BUFFER_TILE_INDEX+4, x
    lda tempA
    sta OAM_BUFFER_ATTRIBUTES+4, x
    clc
    lda player1XHi
    adc tempC
    sta OAM_BUFFER_X_POSITION+4, x
    
    sec
    lda player1YHi          ; Bottom-left
    sbc #$01
    sta OAM_BUFFER_Y_POSITION+8, x
    lda PLAYER_METASPRITE_BL, y
    sta OAM_BUFFER_TILE_INDEX+8, x
    lda tempA
    sta OAM_BUFFER_ATTRIBUTES+8, x
    clc
    lda player1XHi
    adc tempB
    sta OAM_BUFFER_X_POSITION+8, x
    
    sec
    lda player1YHi          ; Bottom-right
    sbc #$01
    sta OAM_BUFFER_Y_POSITION+12, x
    lda PLAYER_METASPRITE_BR, y
    sta OAM_BUFFER_TILE_INDEX+12, x
    lda tempA
    sta OAM_BUFFER_ATTRIBUTES+12, x
    clc
    lda player1XHi
    adc tempC
    sta OAM_BUFFER_X_POSITION+12, x
    rts

; EOF
