                                        .ORIG x0200
                                        
                                        ld r6 OS_SP
                                        ld r0 USER_PSR
                                        add r6,r6,#-1
                                        str r0,r6,#0
                                        ld r0 USER_PC
                                        add r6,r6,#-1
                                        str r0,r6,#0
                                        
                                        
                                        ;allow interrupt
                                        
                                        ld r0 KBSR_Addr
                                        ld r1 KBSR_State
                                        str r1,r0,#0
                                        
                                        
                                        ;set interrupt function address
                                        ld r0 KeyboardInterTabel
                                        ld r1 KeyboardInterFun
                                        str r1,r0,#0
                                    
                                        
                                        and r0,r0,#0
                                        and r1,r1,#0
                                        rti
                                        
                                        
                                        
                                        
KBSR_Addr                               .FILL xfe00
KBSR_State                              .FILL x4000
OS_SP                                   .FILL x3000
USER_PSR                                .FILL x8002
USER_PC                                 .FILL x3000
KeyboardInterTabel                      .FILL x0180
KeyboardInterFun                        .FILL x2000


                                        .END
                                        
                                        
                                        
                                        
                                        .ORIG x2000
                                        str r7,r6,#-7
                                        str r5,r6,#-6
                                        str r4,r6,#-5
                                        str r3,r6,#-4
                                        str r2,r6,#-3
                                        str r1,r6,#-2
                                        str r0,r6,#-1
                                        add r6,r6,#-7
                                        
                                        
Read_Wait                               ldi r1, KBSR                ;read the input
                                        brzp Read_Wait
                                        ldi r0, KBDR
                                        
                                        
                                        
                                        ld r1,Enqueue_Addr
                                        jsrr r1
                                        
                                        
                                        
                                        ldr r7,r6,#0
                                        ldr r5,r6,#1
                                        ldr r4,r6,#2
                                        ldr r3,r6,#3
                                        ldr r2,r6,#4
                                        ldr r1,r6,#5
                                        ldr r0,r6,#6
                                        add r6,r6,#7
                                        rti
                                        
                                        
                                        
Enqueue_Addr                            .FILL Lpush
KBSR                                    .FILL xfe00
KBDR                                    .FILL xfe02
                                        
                                        .END
                                        








                                        .ORIG x3000
                                        
                                        
Loop                                    
                                        br Loop
                                        



;
;RegSave in the front of each function call
;
; r6 is the SP, r7 should be previously stored

RegSave                         
                                str r5,r6,#-6
                                str r4,r6,#-5
                                str r3,r6,#-4
                                str r2,r6,#-3
                                str r1,r6,#-2
                                str r0,r6,#-1
                                add r6,r6,#-6
                                ret
                                
;
;RegCov before function return 
;

RegCov                          
                                ldr r5,r6,#0
                                ldr r4,r6,#1
                                ldr r3,r6,#2
                                ldr r2,r6,#3
                                ldr r1,r6,#4
                                ldr r0,r6,#5
                                add r6,r6,#6
                                ret     
                                        
                                        
                                        
                                        
                                        
;
;data store in r0
;
;L  : front
;enqueue

Lpush                           st r7 Lpush_Temp
                                jsr RegSave
                                ld r7 Lpush_Temp
                                
                                ldi r1 FrontPtr_Addr        ;r1 is front ptr
                                add r1,r1,#-1
                                str r0,r1,#0
                                sti r1 FrontPtr_Addr
                                
                                
                                st r7 Lpush_Temp       
                                jsr RegCov
                                ld r7 Lpush_Temp
                                ret
                                
Lpush_Temp                      .BLKW 1
FrontPtr_Addr                   .FILL frontPtr


;
;data store in r0
;
;R  : back
;dequeue

Rpop                            st r7 Rpop_Temp
                                jsr RegSave
                                ld r7 Rpop_Temp
                                
                                ldi r1 FrontPtr_Addr        ;r1 is front ptr
                                ldi r2 BackPtr_Addr         ;r2 is the back ptr    
                                
                                add r0,r2,#1                ;r0 = -(back + 1)
                                not r0,r0
                                add r0,r0,#1
                                
                                add r0,r1,r0                ;r0 = front - (back + 1)
                                brz Rpop_Empty
                                
                                ldr r0,r2,#0
                                st r0, Rpop_Result
                                add r2,r2,#-1
                                br Rpop_End
                                
                                
Rpop_Empty                      and r0,r0,#0
                                add r0,r0,#-1
                                st r0, Rpop_Result
                                
                                
Rpop_End                                
                                sti r2 BackPtr_Addr
                                
                                st r7 Rpop_Temp       
                                jsr RegCov
                                ld r7 Rpop_Temp
                                ld r0 Rpop_Result
                                ret
Rpop_Temp                       .BLKW 1
Rpop_Result                     .BLKW 1
BackPtr_Addr                    .FILL backPtr


backPtr                         .FILL x9000
frontPtr                        .FILL x9001


                                .END