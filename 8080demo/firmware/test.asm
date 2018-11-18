 JMP testReading
counter DB 5h


 org 10h
testReading:
 IN 83h
 ANI 10h; chceme len spracovat ten prvy signal
 CPI 10h; 
 JZ readSymbol; musi byt 1 ak chceme citat
 JMP testReading
readSymbol:
 IN 80h
 CPI 31h
 JZ changeToPLL
 CPI 32h
 JZ changeToCLK
 CPI 33h
 JZ changeToDIV
 JNZ testSending


changeToPLL:
 MVI A,40h
 OUT 90h
pllSending:
 IN 83h
 ANI 01h; chceme len spracovat ten prvy signal
 CPI 01h; 
 JNZ pllSendSymbol
 JMP pllSending
pllSendSymbol:
 MVI A, 31h
 OUT 80h
 JMP newLineSending

changeToCLK:
 MVI A,41h
 OUT 90h
clkSending:
 IN 83h
 ANI 01h; chceme len spracovat ten prvy signal
 CPI 01h; 
 JNZ clkSendSymbol
 JMP clkSending
clkSendSymbol:
 MVI A, 32h
 OUT 80h
 JMP newLineSending


changeToDIV:
 MVI A,43h
 OUT 90h
divSending:
 IN 83h
 ANI 01h; chceme len spracovat ten prvy signal
 CPI 01h; 
 JNZ divSendSymbol
 JMP divSending
divSendSymbol:
 MVI A, 33h
 OUT 80h 

newLineSending:
 IN 83h
 ANI 01h; chceme len spracovat ten prvy signal
 CPI 01h; 
 JNZ newLineSendSymbol
 JMP newLineSending
newLineSendSymbol:
 MVI A, 0dh
 OUT 80h
newLineSending2:
 IN 83h
 ANI 01h; chceme len spracovat ten prvy signal
 CPI 01h; 
 JNZ newLineSendSymbol2
 JMP newLineSending2
newLineSendSymbol2:
 MVI A, 0ah
 OUT 80h
 JMP testReading

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
 MVI A,053h
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
 MVI A,5h
 STA counter
 JMP newLineSending