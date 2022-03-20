; chr.s
; Sean Latham, 2020

.segment "PATTERN0"
    .incbin "graphics/level.bin"

    .align $100
    .incbin "graphics/font.bin"

.segment "PATTERN1"
    .incbin "graphics/player.bin"

.ifdef DEBUG
    .align $100
    .incbin "graphics/debug.bin"
.endif

; EOF
