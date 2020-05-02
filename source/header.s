; header.s
; Sean Latham, 2020

.segment "HEADER"

INES_MAPPER     = 0         ; 0 = NROM
INES_MIRRORING  = 1         ; 0 = horizontal, 1 = vertical
INES_REGION     = 0         ; 0 = NTSC, 1 = PAL

.byte 'N', 'E', 'S', $1A    ; NES signature
.byte $02                   ; PRG-ROM size, in 16KiB increments
.byte $01                   ; CHR-ROM size, in 8KiB increments
.byte ((INES_MAPPER & $0F) << 4) | INES_MIRRORING
.byte (INES_MAPPER & $F0)
.byte $00                   ; PRG-RAM size, in 8KiB increments
.byte INES_REGION
.byte $00, $00, $00, $00, $00, $00  ; Unused in INES

; EOF
