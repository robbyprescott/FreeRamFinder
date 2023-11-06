; This little patch will make the vanilla eating blocks activate not only when Mario is touching a brown block but also when he is standing on top of them.

!sa1 = 0
!addr = $0000
!bank	= $800000
if read1($00FFD5) == $23
sa1rom
!sa1	= 1
!addr = $6000
!bank	= $000000
endif

org $0392D9|!bank
autoclean JML detect

freecode
detect:
JSL $01B44F|!bank
BCC .return
STZ $1909|!addr
.return
JML $0392DD|!bank
