TITLE MYPROGRAM
DEDOMENA SEGMENT 
  afmarray      DB 9 dup(0)  
  validafm      DB 0 
  validafmmsg   DB 10,13,"To AFM einai eguro$"
  invalidafmmsg DB 10,13,"To AFM den einai eguro$" 
  promptmsg     DB "Parakalw eisagete AFM : $"
  
DEDOMENA ENDS
KODIKAS SEGMENT
ARXH: 
MOV AX,DEDOMENA
MOV DS,AX      

 CALL print_prompt 

 CALL input_afm
 
 CALL afm_verification                

 CALL printresult

MOV AH,4CH
INT 21H    

  
  
;;;;;;;;;;;;;;;;;;;;;;;; print_prompt ;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; Protepei ton xrhsth na dwsei ton ennipsifio arithmo.
print_prompt PROC
 PUSH DX
 PUSH AX     
 
 LEA DX, promptmsg
 MOV AH,09
 INT 21h              ; Zitise to AFM
 
 POP AX
 POP DX
 RET
print_prompt ENDP 



;;;;;;;;;;;;;;;;;;;;;;;; input_afm ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pernei tin eisagogi ton 9 psifiwn, vevewnei oti einai
;; arithmoi kai tous apothikeuei stin mnimi
input_afm PROC        
 PUSH DX
 PUSH AX
 PUSH SI   
                     
 MOV SI,9             ; Arxikopoihse ton SI  
 
startloop: 
 MOV AH,7
 INT 21H               

 CMP AL,48            ; Sugrisi xaraktira me to 0
 JB startloop         ; An einai mikroteros apo to 0 (se ascii) ksana pigene stin arxi tou loop  
 CMP AL,57            ; Sugrisi xaraktira me to 9
 JA startloop         ; An einai megaliteros apo to 9 (se ascii) ksana pigene stin arxi tou loop  
 
 DEC SI               
 
 MOV DL,AL
 MOV AH,2
 INT 21H             
 
 SUB AL,48            ; Metatroph apo ascii se arithmo
 MOV afmarray[SI], AL ; kai apothikeuse ton                      
  
 CMP SI,0
 JA startloop         ; An SI>0, loop  
  
endloop: 
 POP AX
 POP DX
 POP SI  
 RET   
input_afm ENDP

              
              
;;;;;;;;;;;;;;;;;;;;;;;; afm_verification ;;;;;;;;;;;;;;;;;;;;;;
;; Ektelei ton kurio algorithmo gia tin epalitheusi
;; tou enniapsifiou arithmou ws AFM              
afm_verification PROC
 PUSH DX
 PUSH AX     
 PUSH SI
 PUSH CX
 
 MOV validafm,0       ; Ypothetoume arxika oti to afm then einai egiro
                      ; Ean einai egiro tha diorthothei stin poreia
 MOV AX,0
 
 MOV SI,1             ; Gia SI apo 1 eos kai 8
sumloop:              ; kane se kathe arithmo
 MOV DX,0             ; tis antistixes metatopiseis me tin sira tou
 MOV DL,afmarray[SI]  ; stin array. Etsi petixenoume me taxitita tous
 MOV CX,SI            ; sostous pollaplasiazmous afou exoume parei
 SHL DX,CL            ; ta stoixeia anapoda (ksekinontas me to ligotero sumantiko).
 ADD AX,DX            ; Tautoxrona ta prosthetoume gia na exoume to athrisma tous ston AX
                      ; gia na einai etoima gia tin dieresi.
 INC SI
 CMP SI,9
 JB sumloop   
 
 MOV CX,11
 MOV DX,0
 DIV CX
 
 MOV AX,0
 MOV AL,afmarray[0]
 
 CMP DX,10
 JNE upolipodiaforotou10 
 CMP AX,0
 JE afmisvalid        ; Ean to upolipo einai 10 kai to ligotero sumantiko einai 0
 JMP invalidafm       ; tha sunexisei to programma dunontas sto validafm 1 (diladi to afm einai eguro)
                      ; allios tha sunexisei afinontas to validafm 0 (diladi to afm den einai eguro).
 
upolipodiaforotou10:
 CMP AX,DX            ; Ean to upolipo then einai 10 tha to sugrinei me to ligotero sumantiko 
 JNE invalidafm       ; kai ean einai idia tha to theorisei eguro, alios i arxiki upothesi
                      ; itan swsti kai tha to afisei mh eguro
afmisvalid:
 MOV validafm,1
 
 
invalidafm:
 
 POP CX
 POP SI
 POP AX
 POP DX
 RET
afm_verification ENDP
       
       
          
;;;;;;;;;;;;;;;;;;;;;;;; printresult ;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; Ektopwnei to apotelesma kai enhmerwnei ton xrhsth
;; gia tin egurotita h mh tou dothenta arithmou ws AFM         
printresult PROC      
 PUSH DX
 PUSH AX
 
 MOV AL,validafm
 CMP AL,0
 JNE printvalidafm
 
 LEA DX,invalidafmmsg
 MOV AH,09
 INT 21h              ; Ektopose oti to afm den einai egiro
 JMP endprinting
 
printvalidafm:
 LEA DX, validafmmsg
 MOV AH,09
 INT 21h              ; Ektopose oti to afm einai egiro   

endprinting:
  
 POP AX
 POP DX 
 RET     
printresult ENDP



KODIKAS ENDS

SOROS SEGMENT STACK
db 256 dup(0)
SOROS ENDS

END ARXH