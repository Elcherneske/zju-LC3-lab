                                    .ORIG x3000
                                    ld r6 SP
                                    
                                    jsr INPUT
                                    
                                    ldi r0 Main_Num_Addr
                                    
                                    jsr EXE
                                    
                                    
                                    
                                    
                                    
                                    trap x25
                                    
                                    
                                    
                                    
                                    
                                    
                                    
SP                                  .FILL xfe00
Main_Num_Addr                       .FILL Num
                                    
                                    
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
                                ;begin function
                                
                                ;r1 for digit 
                                ;r5 for convert 
                                
                                and r1,r1,#0                ;store the number
                                trap x20
                                trap x21
                                
Input_Loop                      ld r5 Minus_NewLine          
                                add r2,r0,r5                ;input is \n
                                brz Input_Page
                                
                                add r1,r1,r1
                                add r2,r1,#0                ;store 2 * R1
                                add r1,r1,r1
                                add r1,r1,r1
                                add r1,r1,r2                ; r1 = 10 * r1
                                ld r5 digit_Conv
                                add r0,r0,r5
                                add r1,r1,r0                ; r1 = 10 * r1 + char - '0'
                                trap x20
                                trap x21
                                br Input_Loop
                                
                                
Input_Page                      sti r1 Num_Addr
                                add r4,r1,#0                ;for count
                                ld r3 Page_Addr             ;store address
                                
Input_Loop2                                
                                add r4,r4,#0                
                                brz Input_End
                                
                                and r1,r1,#0
                                
                                
                                trap x20
                                trap x21
Input_Dig1                      ld r5 Minus_Space          
                                add r2,r0,r5                ;input is space
                                brz Input_Dig1_End
                                
                                add r1,r1,r1
                                add r2,r1,#0                ;store 2 * R1
                                add r1,r1,r1
                                add r1,r1,r1
                                add r1,r1,r2                ; r1 = 10 * r1
                                ld r5 digit_Conv
                                add r0,r0,r5
                                add r1,r1,r0                ; r1 = 10 * r1 + char - '0'
                                trap x20
                                trap x21
                                br Input_Dig1
                                
Input_Dig1_End                  str r1,r3,#0              
                                add r3,r3,#1
                                
                                
                                
                                
                                and r1,r1,#0
                                trap x20
                                trap x21
Input_Dig2                      ld r5 Minus_NewLine          
                                add r2,r0,r5                ;input is space
                                brz Input_Dig2_End
                                
                                add r1,r1,r1
                                add r2,r1,#0                ;store 2 * R1
                                add r1,r1,r1
                                add r1,r1,r1
                                add r1,r1,r2                ; r1 = 10 * r1
                                ld r5 digit_Conv
                                add r0,r0,r5
                                add r1,r1,r0                ; r1 = 10 * r1 + char - '0'
                                trap x20
                                trap x21
                                br Input_Dig2
                                
Input_Dig2_End                  str r1,r3,#0              
                                add r3,r3,#1
                                
                                
                                
                                add r4,r4,#-1
                                br Input_Loop2
                                
                                
                                
Input_End
                                st r7 Input_Temp       
                                jsr RegCov
                                ld r7 Input_Temp
                                ret  
                                
Minus_NewLine                   .FILL xfff6   
digit_Conv                      .FILL xffd0
Minus_Space                     .FILL xffe0
Input_Temp                      .BLKW 1
Num_Addr                        .FILL Num
Page_Addr                       .FILL Page



;
;R0 is the rest line to check  ;initial to be num
;if R0 is 0, then check whether is legal

EXE                             str r7,r6,#-1
                                add r6,r6,#-1
                                jsr RegSave
                                ;begin function
                                add r0,r0,#0
                                brp Recursion
                                jsr CHECK
                                br Exe_Return
Recursion                                
                                ld r5 Exe_Flip_Addr                 ; r5 is the begin address of array flip
                                ldi r4 Exe_Num_Addr                 ; r4 is the number of pages
                                add r3,r0,#0
                                not r3,r3
                                add r3,r3,#1
                                add r4,r4,r3                    
                                add r5,r5,r4                    ;now r5 is the target block of flip array
                                ;begin to fill filp
                                and r4,r4,#0
                                str r4,r5,#0
                                add r0,r0,#-1
                                jsr EXE
                                add r0,r0,#1
                                and r4,r4,#0
                                add r4,r4,#1
                                str r4,r5,#-0
                                add r0,r0,#-1
                                jsr EXE
                                add r0,r0,#1
Exe_Return                                      
                                jsr RegCov
                                ldr r7,r6,#0
                                add r6,r6,#1
                                ret
Exe_Flip_Addr                   .FILL Flip
Exe_Num_Addr                    .FILL Num






;
;check function: use flip to check whether it's legal
;if legal, output and halt
;

CHECK                           str r7,r6,#-1
                                add r6,r6,#-1
                                jsr RegSave
                                ld r7 Check_Flip_Addr           ;r7 is the point to the flip
                                ldi r1 Check_Num_Addr           ;r1 to be the -number
                                not r1,r1
                                add r1,r1,#1
                                ld r5 Check_Page_Addr           ;r5 is the point to the page
                                ld r4 Check_Result_Addr         ;r4 is the point to the result map
                                and r0,r0,#0
Chech_Loop1
                                add r2,r1,r0
                                brz Check_End1
                                ldr r2,r7,#0
                                brz Flip_z
                                ldr r2,r5,#1
                                str r2,r4,#0
                                add r7,r7,#1
                                add r5,r5,#2
                                add r4,r4,#1
                                add r0,r0,#1
                                br Chech_Loop1
Flip_z                          ldr r2,r5,#0
                                str r2,r4,#0
                                add r7,r7,#1
                                add r5,r5,#2
                                add r4,r4,#1
                                add r0,r0,#1
                                br Chech_Loop1
                                ;to clean the label array
Check_End1              
                                ld r2 Check_Label_Addr
                                and r0,r0,#0
                                and r1,r1,#0
                                add r0,r0,#15
                                add r0,r0,#4
Check_Loop2                     brz Check_Map_Label
                                str r1,r2,#0
                                add r2,r2,#1
                                add r0,r0,#-1
                                br Check_Loop2
Check_Map_Label
                                ld r7 Check_Result_Addr         ;r4 is the point to the result map
                                ldi r1 Check_Num_Addr           ;r1 to be the -number
                                not r1,r1
                                add r1,r1,#1
                                and r0,r0,#0
                                and r4,r4,#0                    ;r4 to be the 1 lebal
                                add r4,r4,#1    
Chech_Loop2
                                add r2,r1,r0
                                brz Check_Label
                                ld r5 Check_Label_Addr
                                ldr r2,r7,#0                    ;read a result
                                add r5,r5,r2                    ;swift the point
                                str r4,r5,#-1
                                add r0,r0,#1
                                add r7,r7,#1
                                br Chech_Loop2
Check_Label                     
                                ld r7 Check_Label_Addr
                                ldi r1 Check_Num_Addr           ;r1 to be the -number
                                not r1,r1
                                add r1,r1,#1
                                and r0,r0,#0
Chech_Loop3
                                add r2,r1,r0
                                brz Check_Success
                                ldr r2,r7,#0
                                add r0,r0,#1
                                add r7,r7,#1
                                add r2,r2,#0
                                brz Check_Return                ;have zero, check fail
                                br  Chech_Loop3   
Check_Success                   jsr OUTPUT
                                trap x25
Check_Return                                
                                jsr RegCov
                                ldr r7,r6,#0
                                add r6,r6,#1
                                ret
Check_Flip_Addr                 .FILL Flip
Check_Num_Addr                  .FILL Num
Check_Page_Addr                 .FILL Page
Check_Label_Addr                .FILL Label
Check_Result_Addr               .FILL Result



OUTPUT                          str r7,r6,#-1
                                add r6,r6,#-1
                                jsr RegSave
                                
                                ;initialization
                                and r1,r1,#0                        ;the count
                                ld r7 Output_Result_Addr            ;result_address
                                ld r5 Output_Digit_Conv             ;'0'
                                ldi r2,Output_Num_Addr              ;-number
                                not r2,r2
                                add r2,r2,#1

Output_Loop                                
                                add r3,r2,r1
                                brz Output_Return
                                
                                ldr r0,r7,#0
                                
                                add r3,r0,#-10
                                brzp Output_double_digit
                                
                                add r1,r1,#0
                                brz Output_Single_Digit_Single
                                add r4,r0,#0
                                ld r0 Output_Space
                                trap x21                                ;output space
                                add r0,r4,#0
                                add r0,r0,r5                            ;transfer to ascii
                                trap x21                                ;output single digit
                                add r1,r1,#1
                                add r7,r7,#1
                                br Output_Loop
                                
                                
                                
Output_Single_Digit_Single      add r0,r0,r5                            ;output without space
                                trap x21
                                add r1,r1,#1
                                add r7,r7,#1
                                br Output_Loop
                                
                                
                                
                                
Output_double_digit                                
                                add r1,r1,#0
                                brz Output_Double_Digit_Single
                                ld r0 Output_Space
                                trap x21
                                add r0,r5,#1                            ;get '1'
                                trap x21
                                add r0,r3,#0                            ;r3 is result-10
                                add r0,r0,r5
                                trap x21
                                add r1,r1,#1
                                add r7,r7,#1
                                br Output_Loop
                                
                                
                                
Output_Double_Digit_Single      add r0,r5,#1                            ;get '1'
                                trap x21
                                add r0,r3,#0                            ;r3 is result-10
                                add r0,r0,r5
                                trap x21
                                add r1,r1,#1
                                add r7,r7,#1
                                br Output_Loop    
                                    
                                
                                
                                
                                
Output_Return                                
                                jsr RegCov
                                ldr r7,r6,#0
                                add r6,r6,#1
                                ret
                                
                                
Output_Num_Addr                 .FILL Num     
Output_Result_Addr              .FILL Result
Output_Space                    .FILL x0020
Output_Digit_Conv               .FILL x0030
                                    
                                    
                                    
                                    
Num                             .BLKW 1                 ;the number of chapter   
Label                           .BLKW 20                ;label for check
Result                          .BLKW 20                ;store the result
Flip                            .BLKW 20                ;whether to flip
Page                            .BLKW 40                ;the pages                    
                                    
                                    
                                    
                                    
                                    
                                .END    
                                    