if read1($01ED44) == $5C
autoclean read3($01ED45)
endif

ORG $01ED44
LDA $7D
BMI +

ORG $01ED70
+