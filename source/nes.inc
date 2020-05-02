; nes.inc
; Sean Latham, 2020

.if !.defined(NES_INC)
.define NES_INC

PPUCTRL         = $2000
PPUMASK         = $2001
PPUSTATUS       = $2002
OAMADDR         = $2003
OAMDATA         = $2004
PPUSCROLL       = $2005
PPUADDR         = $2006
PPUDATA         = $2007
OAMDMA          = $4014

APUSQ1_ENV      = $4000
APUSQ1_SWEEP    = $4001
APUSQ1_LO       = $4002
APUSQ1_HI       = $4003
APUSQ2_ENV      = $4004
APUSQ2_SWEEP    = $4005
APUSQ2_LO       = $4006
APUSQ2_HI       = $4007
APUTRI_LINEAR   = $4008
; $4009 unused
APUTRI_LO       = $400A
APUTRI_HI       = $400B
APUNOI_ENV      = $400C
; $400D unused
APUNOI_PERIOD   = $400E
APUNOI_COUNT    = $400F
APUDMC_FREQ     = $4010
APUDMC_RAW      = $4011
APUDMC_SAMPADR  = $4012
APUDMC_SAMPLEN  = $4013
; $4014 used for OAM
APUCONTROL      = $4015 ; Write-only
APUSTATUS       = $4015 ; Read-only
; $4016 unused
APUFRAME        = $4017 ; Write-only

JOYPAD1         = $4016
JOYPAD2         = $4017

; Ordered the same way they are polled from the controller, MSB first
BUTTON_A        = $80
BUTTON_B        = $40
BUTTON_SELECT   = $20
BUTTON_START    = $10
BUTTON_UP       = $08
BUTTON_DOWN     = $04
BUTTON_LEFT     = $02
BUTTON_RIGHT    = $01

.endif  ; NES_INC

; EOF
