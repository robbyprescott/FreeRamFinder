;used in sprite check, where it checks if sprite shouldn't interact with sprites that can't be killed with cape or fire or both
!ConfCheck = $00

if !SprContactFire
  !ConfCheck := !ConfCheck+$10
endif

if !SprContactCape
  !ConfCheck := !ConfCheck+$20
endif