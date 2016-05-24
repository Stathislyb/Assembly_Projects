;;;; Briskei ti lampa se 7-8 lepta sto sugekrimeno map (step delay 1ms); 
;;;; Dinei protereotita se auta pou den exei episkefthei ;;;;;;;;;;;;;;;
;;;; Se ali periptosi akolouthei algorithmo pigenontas ;;;;;;;;;;;;;;;;;
;;;; apo deksia aristera kai kanontas U turn otan vrei empodio ;;;;;;;;;
;;;; sunexizei pano kato mexri na vrei k alo meros pou then pige ;;;;;;;


TITLE MYPROGRAM
DEDOMENA SEGMENT

 menu       DB "Press the following keys",10,13,"1",9,"Forward",10,13,"2",9,"Left",10,13,"3",9,"Right",10,13,"4",9,"Examine",10,13,"5",9,"On Lamp",10,13,"6",9,"Off Lamp",10,13,"7",9,"Autopilot",10,13,"$"
 command    DB 0     
 errormsg   DB 10,13,"ERROR",10,13,"$"
 wallmsg    DB 10,13,"Wall",10,13,"$"
 offlampmsg DB 10,13,"switched-off lamp",10,13,"$"
 onlampmsg  DB 10,13,"switched-on lamp",10,13,"$"   
 upleft     DB 0
 upright    DB 0 
 downleft   DB 0
 downright  DB 0
 rows       DB 1
 pillars    DB 1 
 direction  DB 1
 updowndir  DB 0  
 mapx1      DB 9 dup(0)
 mapx2      DB 9 dup(0)
 mapx3      DB 9 dup(0)
 mapx4      DB 9 dup(0)
 mapx5      DB 9 dup(0) 
 mapx6      DB 9 dup(0)
 blocked    DB 0  
 autopiloton DB 0
  
DEDOMENA ENDS
KODIKAS SEGMENT
ARXH: 
 MOV AX,DEDOMENA
 MOV DS,AX   
 
arxi:  
 CALL check_ready 
 
 CALL print_menu 
 
 CALL input_command 
 
 MOV AL,command
 CMP AL,7                 ; Sugrisi entolis me to 7
 JE automaticstart        ; An einai 7, pigene se eutomatic 
              
 CALL send_command             
 
JMP arxi                  ; Infinite user loop 
 
automaticstart:
 MOV autopiloton,1
automatic: 
 CALL autopilot
JMP automatic             ; Infinite autopilot loop
 
 MOV AH,4CH
 INT 21H       
 
 
;;;;;;;;;;;;;;;;;  check_ready  ;;;;;;;;;;;;;;;;;   
check_ready PROC
  PUSH AX  
     
 againcheck:
  IN AL,11                ; Diavase tin thira 11
  AND AL, 00000010b       ; an bit1 = 0, AL=0. Alios AL=2
  CMP AL,2
  JE againcheck           ; an AL=2, loop sto againcheck         
 
  POP AX
  RET
check_ready ENDP


;;;;;;;;;;;;;;;;;  print_menu  ;;;;;;;;;;;;;;;;;; 
print_menu PROC
  PUSH DX 
  PUSH AX 
     
  LEA DX, menu
  MOV AH,09
  INT 21h                 ; Emfanise to menu        
  
  POP AX
  POP DX
  RET
print_menu ENDP  


;;;;;;;;;;;;;;;;;  input_command  ;;;;;;;;;;;;;;;;;;
input_command PROC
  PUSH AX
 
 inputloop: 
  MOV AH,7
  INT 21H                  ; Pare xaraktira ston AL 

  CMP AL,031h              ; Sugrisi xaraktira me to 1
  JB inputloop             ; An einai prin apo to 1, loop
  CMP AL,037h              ; Sugrisi xaraktira me to 7
  JA inputloop             ; An einai meto apo to 7, loop
  
  SUB AL,030h              ; Metetrepse ton arithmo apo ascii se katharo   
                        
  MOV command,AL           ; Apothikeuse ton arithmo stin mnimi
 
  POP AX 
  RET   
input_command ENDP 


;;;;;;;;;;;;;;;;;  send_command  ;;;;;;;;;;;;;;;;;;
send_command PROC
  PUSH AX    
  
  CALL check_after_move_for_lamps
   
  CALL check_ready           
  MOV AL,0
  OUT 9,AL                 ; Midenise tis entoles stin thira 9 

  MOV AL,command
  CALL check_ready
  OUT 9,AL                 ; Stile tin entoli stin thira 9
  
  CALL check_command_execution 
   
  
  CMP AL,4
  JNE noexamine            ; an AL einai diaforo tou 4 prosperase to examine
  CALL examine
  
 noexamine: 
  POP AX 
  RET   
send_command ENDP


;;;;;;;;;;;;;;;;;  check_command_execution  ;;;;;;;;;;;;;;;;;;
check_command_execution PROC
  PUSH AX
  PUSH DX
  
  CALL check_ready           
  IN AL,11                 ; Diavase tin thira 11
  AND AL, 00000100b        ; an bit2 = 0, AL=0. Alios AL=4 
  CMP AL,4
  JNE noerror              ; an AL diaforo tou 4, prosperase to errormsg 
    
  LEA DX, errormsg
  MOV AH,09
  INT 21h                  ; Emfanise to errormsg 
  JMP skipadjustment
  
 noerror: 
  CALL adjustments 
 
 skipadjustment:
 
  POP DX
  POP AX 
  RET   
check_command_execution ENDP 


;;;;;;;;;;;;;;;;;  examine  ;;;;;;;;;;;;;;;;;;
examine PROC
  PUSH AX
  PUSH DX
  
  MOV blocked,1
    
  CALL check_ready           
  IN AL,10                 ; Diavase tin thira 10
  CMP AL,255
  JE foundwall             ; an AL=255, emfanise to wallmsg
  CMP AL,7
  JE foundonlamp           ; an AL=7, emfanise to onlampmsg
  CMP AL,8
  JE foundofflamp          ; an AL=8, emfanise to offlampmsg
  CMP AL,0
  JE endexamine            ; an AL=0, min emfaniseis tipota 
  
 foundwall:   
  LEA DX, wallmsg
  MOV AH,09
  INT 21h                  ; Emfanise to wallmsg
  CALL point_as_visited
  JMP endexamine 
  
 foundonlamp:   
  LEA DX, onlampmsg
  MOV AH,09
  INT 21h                  ; Emfanise to onlampmsg
  CALL point_as_visited
  JMP endexamine 
  
 foundofflamp:   
  LEA DX, offlampmsg
  MOV AH,09
  INT 21h                  ; Emfanise to offlampmsg 
  CMP autopiloton,0
  JE endexamine
  CALL point_as_visited
  JMP endexamine  

 endexamine:
  MOV blocked,0
  
  POP DX
  POP AX 
  RET   
examine ENDP 



;;;;;;;;;;;;;;;;;  autopilot  ;;;;;;;;;;;;;;;;;;
autopilot PROC
  PUSH AX  
  PUSH DX
  
  
    
  CALL check_around        ; Kita guro
  
                            
  MOV command,1
  CALL send_command        ; Kinise to robot mprosta
  
   
  CALL check_for_crash     ; Diorthosi porias gia empodia 
 
  POP DX
  POP AX 
  RET   
autopilot ENDP
  
  
;;;;;;;;;;;;;;;;;  check_for_crash  ;;;;;;;;;;;;;;;;;;
check_for_crash PROC
  PUSH AX
  
 crushtestloop:
  CALL check_ready           
  MOV AL,0
  OUT 9,AL                 ; Midenise tis entoles stin thira 9 
  MOV AL,4
  CALL check_ready
  OUT 9,AL                 ; Stile tin entoli gia eksetasi stin thira 9
  
  CALL check_ready           
  IN AL,10                 ; Diavase tin thira 10
  CMP AL,0
  JE nocrash               ; an AL diaforo tou 0, exei empodio mprosta kai tha stripsei 
  
  CMP rows,6               ; Des an exei ftasei stin teleutea sira gia na paei pano
  JNE checkneedtogoup 
  
  MOV updowndir,1
  JMP endgeneraldiradj  
  
 checkneedtogoup: 
  CMP rows,1               ; Des an exei ftasei stin proti sira gia na paei kato
  JNE endgeneraldiradj
  MOV updowndir,0
  
 endgeneraldiradj: 
  
  CMP updowndir,0
  JE goingdown
             
             ;Kodikas gia na anevei pros ta pano
  MOV AL,upleft
  MOV AH,upright
  CMP direction,3                ; Sugrine poses strofes ekane deksia kai aristera
  JE turnright             ; Prospathise na eksisoropiseis tis strofes gia na min kanei kiklous
  
     
  MOV command,2
  CALL send_command        
  MOV command,1
  CALL send_command          
  MOV command,2
  CALL send_command        ; U turn aristera 
  ADD upleft,2
  JMP uturnfinished
  
 turnright:  
  MOV command,3
  CALL send_command           
  MOV command,1
  CALL send_command         
  MOV command,3
  CALL send_command        ; U turn deksia
  ADD upright,2
  JMP uturnfinished
                                   
              
              ;Kodikas gia na paei pros ta kato
 goingdown: 
  MOV AL,downleft
  MOV AH,downright
  CMP direction,3                ; Sugrine poses strofes ekane deksia kai aristera
  JE turnleft              ; Prospathise na eksisoropiseis tis strofes gia na min kanei kiklous
   
   
  MOV command,3
  CALL send_command           
  MOV command,1
  CALL send_command         
  MOV command,3
  CALL send_command        ; U turn deksia 
  ADD downright,2
  JMP uturnfinished
 turnleft: 
  
 
  MOV command,2
  CALL send_command        
  MOV command,1
  CALL send_command          
  MOV command,2
  CALL send_command        ; U turn aristera
  ADD downleft,2 
                                   
  
 uturnfinished:
  JMP crushtestloop
 
 nocrash:
  POP AX 
  RET   
check_for_crash ENDP  
  
  
;;;;;;;;;;;;;;;;;  adjustments  ;;;;;;;;;;;;;;;;;;
adjustments PROC
  PUSH AX
  
  MOV AL,direction
  MOV AH,rows  
  
  
  CMP command,1
  JNE endrowpiladj         ; Des an kinite
  CALL point_as_visited
                  
  CMP AL,1
  JE fixpillarright
  CMP AL,3
  JE fixpillarleft
  CMP AL,2
  JE fixrowdown            ; Des an pigenei pano i kato
  
  SUB AH,1
  MOV rows,AH 
  JMP endadjustments       ; An paei pano, rows--
  
 fixrowdown:
  ADD AH,1
  MOV rows,AH              ; An paei kato, rows++
  JMP endadjustments
  
 fixpillarright:
  ADD pillars,1            ; An paei deksia, pillars++
  JMP endadjustments                           
  
 fixpillarleft:
  SUB pillars,1            ; An paei aristera, pillars--
  JMP endadjustments                                      
  
  
 endrowpiladj:
  CMP command,2
  JE adjdirectionleft      ; Des strivei aristera
  CMP command,3
  JE adjdirectionright     ; Des strivei deksia 
  JMP endadjustments       ; Allios teliose tis diorthoseis
                           
 adjdirectionleft:
  CMP AL,1
  JE fixleftturn           ; An dir =1, tote kane dir=4 
 
  SUB AL,1                 ; Allios dir--
  JMP endadjustments
  
 fixleftturn:
  MOV AL,4
  JMP endadjustments
 
 
 adjdirectionright:
  CMP AL,4
  JE fixrightturn          ; An dir =4, tote kane dir=1 
 
  ADD AL,1                 ; Allios dir++
  JMP endadjustments
  
 fixrightturn:
  MOV AL,1
  JMP endadjustments
  
  
 endadjustments: 
  MOV direction,AL
  MOV rows,AH 
  
  POP AX 
  RET
adjustments ENDP 
  
  
;;;;;;;;;;;;;;;;;  check_after_move_for_lamps  ;;;;;;;;;;;;;;;;;;
check_after_move_for_lamps PROC
  PUSH AX
  PUSH DX
  
  MOV AL,0
  CALL check_ready
  OUT 9,AL                 ; Midenise ta commands
  MOV AL,4
  CALL check_ready
  OUT 9,AL                 ; Eksetase mprosta
  
  CALL check_ready           
  IN AL,10                 ; Diavase tin thira 10
  CMP AL,8
  JNE noofflamp            ; Elenkse gia klisti lampa
   
  MOV AL,0  
  CALL check_ready
  OUT 9,AL                 ; Midenise ta commands
  MOV AL,5  
  CALL check_ready
  OUT 9,AL                 ; Anapse tin lampa 
  
 noofflamp: 
  POP DX
  POP AX 
  RET
check_after_move_for_lamps ENDP 


;;;;;;;;;;;;;;;;;  check_around  ;;;;;;;;;;;;;;;;;;
check_around PROC
  PUSH AX
  PUSH DX  
  
  MOV command,4
  CALL send_command        ; Kane examine mprosta
  CALL priority_visited
  
  MOV command,3
  CALL send_command        
  MOV command,4
  CALL send_command        ; Kane examine deksia
  CALL priority_visited  
  
  MOV command,3
  CALL send_command 
  MOV command,4
  CALL send_command        ; Kane examine piso 
  CALL priority_visited
         
  MOV command,3
  CALL send_command        
  MOV command,4
  CALL send_command        ; Kane examine aristera
  CALL priority_visited
  
  MOV command,3
  CALL send_command        ; Ksana gurna mprosta
                                              
                                                 
  POP DX
  POP AX 
  RET
check_around ENDP 


;;;;;;;;;;;;;;;;;  point_as_visited  ;;;;;;;;;;;;;;;;;;
point_as_visited PROC
  PUSH AX 
  PUSH SI 
  
  MOV AX,0
  MOV AL,pillars
  SUB AL,1
  MOV SI,AX 
  
  CMP blocked,1
  JE blockedpath
   
  CMP rows,1
  JE firstrow
  CMP rows,2
  JE secondrow
  CMP rows,3
  JE thirdrow
  CMP rows,4
  JE forthrow
  CMP rows,5
  JE fifthrow
  CMP rows,6
  JE sixthrow 
      
  
 blockedpath:
  CMP direction,1
  JE blockedright
  CMP direction,3
  JE blockedleft
  CMP direction,4
  JE blockedup
  CMP direction,2
  JE blockeddown
  
 blockeddown:
  CMP rows,1
  JE secondrow
  CMP rows,2
  JE thirdrow
  CMP rows,3
  JE forthrow
  CMP rows,4
  JE fifthrow
  CMP rows,5
  JE sixthrow
  JMP endpointingvisited
 
 blockedup:
  CMP rows,2
  JE endpointingvisited
  CMP rows,3
  JE secondrow
  CMP rows,4
  JE thirdrow
  CMP rows,5
  JE forthrow
  CMP rows,6
  JE fifthrow
  JMP endpointingvisited 
  
 
 blockedright:
  CMP SI,8
  JE endpointingvisited
  ADD SI,1
  JMP blockedsides
  
 blockedleft:
  CMP SI,0
  JE endpointingvisited
  SUB SI,1
  JMP blockedsides
  
 blockedsides:
  CMP rows,1
  JE firstrow
  CMP rows,2
  JE secondrow
  CMP rows,3
  JE thirdrow
  CMP rows,4
  JE forthrow
  CMP rows,5
  JE fifthrow
  CMP rows,6
  JE sixthrow 
  
 firstrow:
  MOV mapx1[SI],1
  JMP endpointingvisited
 secondrow:
  MOV mapx2[SI],1
  JMP endpointingvisited
 thirdrow:
  MOV mapx3[SI],1
  JMP endpointingvisited
 forthrow:
  MOV mapx4[SI],1
  JMP endpointingvisited
 fifthrow:
  MOV mapx5[SI],1
  JMP endpointingvisited
 sixthrow:
  MOV mapx6[SI],1
  JMP endpointingvisited                                        
 
 endpointingvisited: 
  POP SI                                               
  POP AX 
  RET
point_as_visited ENDP 


;;;;;;;;;;;;;;;;;  priority_visited  ;;;;;;;;;;;;;;;;;;
priority_visited PROC
  PUSH AX 
  PUSH SI 
  
  MOV AX,0
  MOV AL,pillars
  SUB AL,1
  MOV SI,AX 
  
  CMP direction,1
  JE priorityfront
  CMP direction,3
  JE priorityback
  CMP direction,2
  JE prioritydown
  CMP direction,4
  JE priorityup
  
 priorityfront:
  CMP SI,8
  JE endpriority
  ADD SI,1
  JMP frontbackprior
  
 priorityback:
  CMP SI,1
  JE endpriority
  SUB SI,1
  JMP frontbackprior
  
 prioritydown:
  CMP rows,1
  JE secondrowprior
  CMP rows,2
  JE thirdrowprior
  CMP rows,3
  JE forthrowprior
  CMP rows,4
  JE fifthrowprior
  CMP rows,5
  JE sixthrowprior
  JMP endpriority 
  
 priorityup:
  CMP rows,2
  JE firstrowprior
  CMP rows,3
  JE secondrowprior
  CMP rows,4
  JE thirdrowprior
  CMP rows,5
  JE forthrowprior
  CMP rows,6
  JE fifthrow prior
  JMP endpriority
  
 frontbackprior:  
  CMP rows,1
  JE firstrowprior
  CMP rows,2
  JE secondrowprior
  CMP rows,3
  JE thirdrowprior
  CMP rows,4
  JE forthrowprior
  CMP rows,5
  JE fifthrowprior
  CMP rows,6
  JE sixthrowprior
  JMP endpriority    

  
 firstrowprior:
  CMP mapx1[SI],0 
  JNE endpriority
  MOV command,1
  CALL send_command
  JMP endpriority
 secondrowprior:
  CMP mapx2[SI],0
  JNE endpriority
  MOV command,1
  CALL send_command
  JMP endpriority
 thirdrowprior:
 CMP mapx3[SI],0
 JNE endpriority
  MOV command,1
  CALL send_command
  JMP endpriority
 forthrowprior:
  CMP mapx4[SI],0 
  JNE endpriority
  MOV command,1
  CALL send_command
  JMP endpriority
 fifthrowprior:
  CMP mapx5[SI],0
  JNE endpriority
  MOV command,1
  CALL send_command
  JMP endpriority
 sixthrowprior:
  CMP mapx6[SI],0
  JNE endpriority
  MOV command,1
  CALL send_command
  JMP endpriority                                        
 
 endpriority: 
  POP SI                                               
  POP AX 
  RET
priority_visited ENDP


KODIKAS ENDS      

SOROS SEGMENT STACK
 DB 256 dup(0)
SOROS ENDS 

END ARXH