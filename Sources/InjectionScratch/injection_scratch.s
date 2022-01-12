
.align 14
.global _injection_scratch
_injection_scratch:
    .rept 16*1024*1024
    nop
    .endr
.global _injection_scratch_end
_injection_scratch_end:
    nop
