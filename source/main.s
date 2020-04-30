; main.s
; Sean Latham, 2020

.include "nes.inc"
.include "global.s"

.segment "TEXT"

APU_INIT_VALUES:
	.byte $30, $08, $00, $00
	.byte $30, $08, $00, $00
	.byte $80, $00, $00, $00
	.byte $30, $00, $00, $00
	.byte $00, $00, $00
	
TEST_PALETTES:
	.byte $0D, $02, $12, $32
	.byte $0D, $03, $13, $33
	.byte $0D, $04, $14, $34
	.byte $0D, $07, $17, $37
	.byte $0D, $04, $36, $30
	.byte $0D, $03, $13, $33
	.byte $0D, $04, $14, $34
	.byte $0D, $07, $17, $37

.segment "CODE"

; RESET vector
reset:
	sei				; Ignore interrupts
	cld				; Disable decimal mode (not present on NES)
	ldx #$40
	stx APUFRAME	; Disable APU frame counter interrupts
	ldx #$FF
	txs				; Setup stack
	inx				; Now X = 0
	stx PPUCTRL		; Disable NMI
	stx PPUMASK		; Disable rendering
	stx APUDMC_FREQ	; Disable DMC interrupts
	
	bit PPUSTATUS	; Read PPUSTATUS to clear bit 7 (v-blank hit)	
@vblankWait1:
		bit PPUSTATUS
		bpl @vblankWait1	; Spin until v-blank has been hit once

	; We now have 30,000 cycles to burn...
@clearRAM:
		lda #$00
		sta $0000,x
		sta $0100,x
		sta $0300,x
		sta $0400,x
		sta $0500,x
		sta $0600,x
		sta $0700,x
		lda #$FE
		sta $0200,x		; Initialise OAM buffer with non-zero value
		inx
		bne @clearRAM

	; Silence APU
	ldy #$13
@silenceAPU:
		lda APU_INIT_VALUES,y
		sta $4000,y
		dey
		bpl @silenceAPU
	lda #$0F		; Need to skip over OAMDMA and JOYPAD2
	sta APUCONTROL
	lda #$40
	sta APUFRAME

@vblankWait2:
		bit PPUSTATUS
		bpl @vblankWait2

	; Now we can start doing interesting stuff...
	lda PPUSTATUS	; Reset PPUADDR latch
	lda #>$3F00
	sta PPUADDR
	lda #<$3F00
	sta PPUADDR
	ldx #$00
@loadTestPalettes:
	lda TEST_PALETTES,x
	sta PPUDATA
	inx
	cpx #$20
	bne @loadTestPalettes
	
	lda #%10001100
	sta PPUCTRL		; Enable PPU NMI, sprites use pattern table 1
	lda #%00011110
	sta PPUMASK		; Show sprites and background
	cli				; Enable interrupts

gameLoop:
readJoypads:			; Adapated from wiki.nesdev.com
	lda #$01
	sta JOYPAD1			; Set strobe bit
	sta player2Buttons	; Use Player 2's buttons as a ring counter
	lsr	a				; Now A = 0
	sta JOYPAD1			; Clear strobe bit - joypad's shift registers now set
@loop:
	lda JOYPAD1
	lsr a				; Bit 0 -> carry
	rol player1Buttons	; Carry -> bit 0, bit 7 -> carry
	lda JOYPAD2
	lsr a
	rol player2Buttons
	bcc @loop			; Exit once the initial $01 we set has been shifted out

tempScrollingSprite:	; Not optimal, could shift right and check carry flag
	lda player1Buttons
	and #BUTTON_LEFT
	beq @checkRight
		lda tempC
		sbc #$01
		sta tempC
@checkRight:
	lda player1Buttons
	and #BUTTON_RIGHT
	beq @checkUp
		lda tempC
		adc #$01
		sta tempC
@checkUp:
	lda player1Buttons
	and #BUTTON_UP
	beq @checkDown
		lda tempD
		sbc #$01
		sta tempD
@checkDown:
	lda player1Buttons
	and #BUTTON_DOWN
	beq @drawSprite
		lda tempD
		adc #$01
		sta tempD
@drawSprite:
	lda tempD		; Scrolling sprite test, top-left
	sta oamBuffer+0
	lda #$00
	sta oamBuffer+1
	sta oamBuffer+2
	lda tempC
	sta oamBuffer+3
	
	lda tempD		; Scrolling sprite test, top-right
	sta oamBuffer+4
	lda #$01
	sta oamBuffer+5
	lda #$00
	sta oamBuffer+6
	lda tempC
	adc #$08
	sta oamBuffer+7
	
	lda tempD		; Scrolling sprite test, bottom-left
	adc #$08
	sta oamBuffer+8
	lda #$02
	sta oamBuffer+9
	lda #$00
	sta oamBuffer+10
	lda tempC
	sta oamBuffer+11
	
	lda tempD		; Scrolling sprite test, top-right
	adc #$08
	sta oamBuffer+12
	lda #$03
	sta oamBuffer+13
	lda #$00
	sta oamBuffer+14
	lda tempC
	adc #$08
	sta oamBuffer+15

@gameLoopComplete:
	lda #$01
	sta gameLoopFlag
@spin:
	lda gameLoopFlag
	bne @spin
	jmp gameLoop

; NMI vector
nmi:
	php		; Push all registers onto the stack
	pha
	txa
	pha
	tya
	pha
	
	lda gameLoopFlag
	beq @exitNMI	; Exit immediately if game loop has not finished yet
	
	lda #$00		; Perform OAM buffer transfer
	sta OAMADDR
	lda #>oamBuffer
	sta OAMDMA
	
	lda #$00	; Reset game loop flag
	sta gameLoopFlag
	
@exitNMI:
	pla		; Pull all registers from the stack (in reverse order)
	tay
	pla
	tax
	pla
	plp
	rti
	
irq:
@spin:
	jmp @spin

.segment "VECTORS"
	.word nmi	; NMI vector
	.word reset	; RESET vector
	.word irq	; IRQ vector

; EOF
