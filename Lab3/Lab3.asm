                                .ORIG x3000
                                
                                ld r6 SP
                                jsr INPUT
                                
                                jsr EXE
                                
                                trap x25
                                
SP                              .FILL xfe00

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
                                
                                
                                
INPUT                           st r7 Input_Temp
                                jsr RegSave
                                ld r7 Input_Temp
                                
                                
                                ld r5 Input_InputBuff_Addr          ;store the addr of inputbuff
                                trap x20
                                trap x21
input_loop                      add r1,r0,#-10                      ;not \n
                                brz input_end
                                str r0,r5,#0                        ;store the input
                                add r5,r5,#1
                                trap x20                            ;next one
                                trap x21
                                br input_loop
                                
                                
input_end                       st r7 Input_Temp       
                                jsr RegCov
                                ld r7 Input_Temp
                                ret
                                
Input_Temp                      .BLKW 1
Input_InputBuff_Addr            .FILL inputBuff



EXE                             st r7 Exe_Temp
                                jsr RegSave
                                ld r7 Exe_Temp

                                ld r1 Input_InputBuff_Addr          ;r1 point to inputbuff
                                
Exe_Loop                        ldr r2,r1,#0                        ;read a character into r2
                                brz Exe_End                         ;no characters remain
                                
                                ld r3 Left_Add                      ;check the character
                                add r0,r2,r3
                                brz Exe_Lpush
                                
                                ld r3 Left_Sub
                                add r0,r2,r3
                                brz Exe_Lpop
                                
                                ld r3 Right_Add
                                add r0,r2,r3
                                brz Exe_Rpush
                                
                                ld r3 Right_Sub
                                add r0,r2,r3
                                brz Exe_Rpop
                                
                                
Exe_Lpush                       ldr r0,r1,#1                         ;read the immediate character
                                st r7 Exe_Temp
                                jsr Lpush
                                ld r7 Exe_Temp
                                add r1,r1,#2
                                br Exe_Loop
                                
                                
                                
Exe_Rpush                       ldr r0,r1,#1                         ;read the immediate character
                                st r7 Exe_Temp
                                jsr Rpush
                                ld r7 Exe_Temp
                                add r1,r1,#2
                                br Exe_Loop
                                
Exe_Lpop                        st r7 Exe_Temp
                                jsr Lpop
                                ld r7 Exe_Temp
                                add r1,r1,#1
                                br Exe_Loop
                                
Exe_Rpop                        st r7 Exe_Temp
                                jsr Rpop
                                ld r7 Exe_Temp
                                add r1,r1,#1
                                br Exe_Loop



Exe_End                         st r7 Exe_Temp       
                                jsr RegCov
                                ld r7 Exe_Temp
                                ret
                                
Exe_Temp                        .BLKW 1
Left_Add                        .FILL xffd5
Left_Sub                        .FILL xffd3
Right_Add                       .FILL xffa5
Right_Sub                       .FILL xffa3

;
;data store in r0
;
;L  : front

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

Lpop                            st r7 Lpop_Temp
                                jsr RegSave
                                ld r7 Lpop_Temp
                                
                                ldi r1 FrontPtr_Addr        ;r1 is front ptr
                                ldi r2 BackPtr_Addr         ;r2 is the back ptr    
                                
                                add r0,r2,#1                ;r0 = -(back + 1)
                                not r0,r0
                                add r0,r0,#1
                                
                                add r0,r1,r0                ;r0 = front - (back + 1)
                                brz Lpop_Empty
                                
                                ldr r0,r1,#0
                                trap x21
                                add r1,r1,#1
                                br Lpop_End
                                
                                
Lpop_Empty                      ld r0 SubLine
                                trap x21
                                
Lpop_End                                
                                sti r1 FrontPtr_Addr
                                
                                st r7 Lpop_Temp       
                                jsr RegCov
                                ld r7 Lpop_Temp
                                ret
Lpop_Temp                       .BLKW 1


;
;data store in r0
;
;R  : back


Rpush                           st r7 Rpush_Temp
                                jsr RegSave
                                ld r7 Rpush_Temp
                                
                                ldi r1 BackPtr_Addr  ;r1 is front ptr
                                add r1,r1,#1
                                str r0,r1,#0
                                sti r1 BackPtr_Addr
                                
                                
                                st r7 Rpush_Temp       
                                jsr RegCov
                                ld r7 Rpush_Temp
                                ret
                                
Rpush_Temp                      .BLKW 1
BackPtr_Addr                    .FILL backPtr

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
                                trap x21
                                add r2,r2,#-1
                                br Rpop_End
                                
                                
Rpop_Empty                      ld r0 SubLine
                                trap x21
                                
Rpop_End                                
                                sti r2 BackPtr_Addr
                                
                                st r7 Rpop_Temp       
                                jsr RegCov
                                ld r7 Rpop_Temp
                                ret
Rpop_Temp                       .BLKW 1


backPtr                         .FILL x9000
frontPtr                        .FILL x9001
SubLine                         .FILL x005f
inputBuff                       .BLKW x250                  ; more than operator number
                                
                                
                                .END
                                
                                
                                
                                
                                