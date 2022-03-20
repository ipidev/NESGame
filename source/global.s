; global.s
; Sean Latham, 2020

; Import/export RAM symbol macro originally by Brad Smith
.macro RESZP label, size
    .ifdef EXPORT_GLOBALS
        label: .res size
        .exportzp label
    .else
        .importzp label
    .endif
.endmacro

.macro RES label, size
    .ifdef EXPORT_GLOBALS
        label: .res size
        .export label
    .else
        .import label
    .endif
.endmacro

.segment "ZEROPAGE"

RESZP   tempA,              $01
RESZP   tempB,              $01
RESZP   tempC,              $01
RESZP   tempD,              $01
RESZP   tempE,              $01
RESZP   tempF,              $01
RESZP   tempG,              $01
RESZP   tempH,              $01
RESZP   tempPtrA,           $02
RESZP   tempPtrB,           $02
RESZP   tempPtrC,           $02
RESZP   tempPtrD,           $02

RESZP   gameLoopFlag,       $01 ; 0 while game is running, 1 while spinning
RESZP   ppuCtrlCache,       $01

RESZP   player1Buttons,     $01
RESZP   player2Buttons,     $01

; Axis-specific variables should be laid out sequentially for indirect indexing
RESZP   player1XLo,         $01
RESZP   player1XHi,         $01
RESZP   player1XSpeedLo,    $01
RESZP   player1XSpeedHi,    $01
RESZP   player1YLo,         $01
RESZP   player1YHi,         $01
RESZP   player1YSpeedLo,    $01
RESZP   player1YSpeedHi,    $01

RESZP   player1Facing,      $01 ; 0 right, 1 left, 2 down, 3 up
RESZP   player1State,       $01 ; 0 stand, 1 walking
RESZP   player1StateTimer,  $01
RESZP   player1AnimIndex,   $01
RESZP   player1Grounded,    $01
RESZP   player1JumpDebounce,$01

RESZP   scrollXLo,          $01
RESZP   scrollYLo,          $01

.segment "STACK"

.segment "OAM"

RES     oamBuffer,          $100

; Helpful aliases for accessing the OAM buffer
OAM_BUFFER_Y_POSITION = oamBuffer+0
OAM_BUFFER_TILE_INDEX = oamBuffer+1
OAM_BUFFER_ATTRIBUTES = oamBuffer+2
OAM_BUFFER_X_POSITION = oamBuffer+3

.segment "RAM"

LEVEL_LAYOUT_SIZE = 16*14
RES     levelLayout,        LEVEL_LAYOUT_SIZE

.align $100

.ifdef DEBUG
RES     debug_arrowCount,   $01
RES     debug_arrowXPos,    $04
RES     debug_arrowYPos,    $04
.endif

; EOF
