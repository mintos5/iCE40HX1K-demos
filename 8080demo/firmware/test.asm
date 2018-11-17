 JMP testReading
counter DB 15h


 org 10h
testReading:
 IN 83h
 ANI 10h; chceme len spracovat ten prvy signal
 CPI 10h; 
 JZ readSymbol; musi byt 1 ak chceme citat
 JMP testReading
readSymbol:
 IN 80h
 MOV B,A

;nacitanie si o stave uartu
testSending:
 IN 83h
 ANI 01h; chceme len spracovat ten prvy signal
 CPI 01h; 
 JNZ sendSymbol
 JMP testSending
sendSymbol:
 MVI A, 04dh
 OUT 80h

testSending2:
 IN 83h
 ANI 01h; chceme len spracovat ten prvy signal
 CPI 01h; 
 JNZ sendSymbol2
 JMP testSending2
sendSymbol2:
 MVI A,043h
 OUT 80h

testSending3:
 IN 83h
 ANI 01h; chceme len spracovat ten prvy signal
 CPI 01h; 
 JNZ sendSymbol3
 JMP testSending3
sendSymbol3:
 MVI A,023h
 OUT 80h

testLoop:
 LDA counter
 DCR A
 STA counter
 CPI 00h;
 JNZ testSending
 MVI A,15h
 STA counter
 JMP testReading