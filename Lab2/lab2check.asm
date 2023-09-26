            .ORIG X3000
            
            and r0,r0,#0
            and r1,r1,#0
            and r2,r2,#0
            and r3,r3,#0
            and r4,r4,#0
            and r5,r5,#0
            and r6,r6,#0
            and r7,r7,#0
            
            add r0,r0,#7
r0_loop     brz r0_end
            add r1,r1,#6
r1_loop     brz r1_end
            add r2,r2,#6
r2_loop     brz r2_end
            add r3,r3,#4
r3_loop     brz r3_end
            add r4,r4,#6
r4_loop     brz r4_end
            
            lea r7 asciibuff
            ld r6 num_trans
            
            add r5,r0,#-1
            add r5,r5,r6
            str r5,r7,#0
            add r5,r1,#-1
            add r5,r5,r6
            str r5,r7,#1
            add r5,r2,#-1
            add r5,r5,r6
            str r5,r7,#2
            add r5,r3,#-1
            add r5,r5,r6
            str r5,r7,#3
            add r5,r4,#-1
            add r5,r5,r6
            str r5,r7,#4
            
            and r5,r5,#0
            add r5,r5,#5
            add r0,r0,#0
            brp if_end
            add r5,r5,#-1
            add r1,r1,#0
            brp if_end
            add r5,r5,#-1
            add r2,r2,#0
            brp if_end
            add r5,r5,#-1
            add r3,r3,#0
            brp if_end
            add r5,r5,#-1
            add r4,r4,#0
            brp if_end
            add r5,r5,#-1
            
if_end      sti r5,numbuff_addr            

            
            
            ;call convert
            
            sti r1,temp_addr          ;push
            ldi r1,sp_addr
            str r0,r1,#-1
            str r7,r1,#-2
            add r1,r1,#-2
            sti r1,sp_addr
            ldi r1,temp_addr
            
            JSR DIGCONV         ;call
            
            sti r1,temp_addr          ;pop
            ldi r1,sp_addr
            ldr r7,r1,#0
            ldr r0,r1,#1
            add r1,r1,#2
            sti r1,sp_addr
            ldi r1,temp_addr
            
            ;call hex convert
            
            sti r1,temp_addr          ;push
            ldi r1,sp_addr
            str r0,r1,#-1
            str r7,r1,#-2
            add r1,r1,#-2
            sti r1,sp_addr
            ldi r1,temp_addr
            
            JSR HEXCONV         ;call
            
            sti r1,temp_addr          ;pop
            ldi r1,sp_addr
            ldr r7,r1,#0
            ldr r0,r1,#1
            add r1,r1,#2
            sti r1,sp_addr
            ldi r1,temp_addr
            
            
            ;call output
            
            sti r1,temp_addr          ;push
            ldi r1,sp_addr
            str r0,r1,#-1
            str r7,r1,#-2
            add r1,r1,#-2
            sti r1,sp_addr
            ldi r1,temp_addr
            
            JSR output         ;call
            and r0,r0,#0
            add r0,r0,#10
            trap x21
            
            sti r1,temp_addr          ;pop
            ldi r1,sp_addr
            ldr r7,r1,#0
            ldr r0,r1,#1
            add r1,r1,#2
            sti r1,sp_addr
            ldi r1,temp_addr
            
            
            
            
            
            
            add r4,r4,#-1
            br r4_loop
r4_end      add r3,r3,#-1
            br r3_loop
r3_end      add r2,r2,#-1
            br r2_loop
r2_end      add r1,r1,#-1
            br r1_loop
r1_end      add r0,r0,#-1
            br r0_loop

r0_end            
            
            
            
            
            
            
            
            
            trap x25            ;halt
            
            
            
            
            
temp_addr   .fill   temp
sp_addr     .fill   sp
numbuff_addr .fill  numbuff

num_trans   .fill   x0030
         
;
;function digitConverge
;


DIGCONV     ld r0,sp            ;push register
            str r1,r0,#-1
            str r2,r0,#-2
            str r3,r0,#-3
            str r4,r0,#-4
            str r5,r0,#-5
            str r6,r0,#-6
            str r7,r0,#-7
            add r0,r0,#-7
            st r0,sp
            
            ;begin function
            
            lea r1 asciibuff    ;the address of asciibuff
            ld r2 numbuff
            and r7,r7,#0        ;clear r7 to store result
            add r2,r2,#0        ;check logic
conv_loop   brz conv_end
            ldr r3,r1,#0        ;get the number ascii
            add r3,r3,#-16      ;transfer ascii to digit
            add r3,r3,#-16  
            add r3,r3,#-16
            add r7,r7,r7        ; r7 = 10*r7+r3
            add r6,r7,#0
            add r7,r7,r7
            add r7,r7,r7
            add r7,r7,r6
            add r7,r7,r3
            add r1,r1,#1        ;r1++
            add r2,r2,#-1       ;r2--
            br conv_loop
conv_end    lea r1 digitbuff  
            str r7,r1,#0
            

            ld r0,sp            ;pop register
            ldr r7,r0,#0
            ldr r6,r0,#1
            ldr r5,r0,#2
            ldr r4,r0,#3
            ldr r3,r0,#4
            ldr r2,r0,#5
            ldr r1,r0,#6
            add r0,r0,#7
            st r0,sp
            
            ret                 ;return





;
;function hex conversion
;


HEXCONV     ld r0,sp            ;push register
            str r1,r0,#-1
            str r2,r0,#-2
            str r3,r0,#-3
            str r4,r0,#-4
            str r5,r0,#-5
            str r6,r0,#-6
            str r7,r0,#-7
            add r0,r0,#-7
            st r0,sp
            
            ;begin function
            
            
            ld r0,digitbuff     ;r0 dividen
            and r1,r1,#0
            add r1,r1,#-16      ;r1 = 16 divisor
            and r2,r2,#0        ;r2 quotient
            and r3,r3,#0        ;r3 remainder
            lea r7 hexbuff
            add r7,r7,#3
            and r4,r4,#0        ;r4 = 4 divide time
            add r4,r4,#4 
            
            add r0,r0,#0        ;check r0
            brn hex_neg
            
            add r4,r4,#0        ;check r4
hex_loop1   brz hex_out

hex_loop2   add r0,r0,r1
            brn hex_end2
            add r2,r2,#1
            br hex_loop2
            
hex_end2    add r3,r0,#15
            add r3,r3,#1
        
            str r3,r7,#0
            add r7,r7,#-1
            
            add r0,r2,#0
            and r2,r2,#0
            
            add r4,r4,#-1
            br hex_loop1








hex_neg     ld r5,neg_max
            add r0,r0,r5        ;remove the first 1
            
hex_loop3   add r0,r0,r1        ;subtract by 16
            brn hex_end3
            add r2,r2,#1
            br hex_loop3
hex_end3    add r2,r2,#1
            ld r5,pos_max       ;add x7fff and x0001 back
            add r0,r0,r5
            add r0,r0,#1
hex_loop4   add r0,r0,r1        ;continue to subtract
            brn hex_end4
            add r2,r2,#1
            br hex_loop4
            
hex_end4    add r3,r0,#15       ;get remain
            add r3,r3,#1
        
            str r3,r7,#0        ;store remain
            add r7,r7,#-1       ;shift MAR
            
            add r0,r2,#0        ;prepare for next
            and r2,r2,#0
            
            add r4,r4,#-1
            

hex_loop5   brz hex_out

hex_loop6   add r0,r0,r1
            brn hex_end6
            add r2,r2,#1
            br hex_loop6
            
hex_end6    add r3,r0,#15
            add r3,r3,#1
        
            str r3,r7,#0
            add r7,r7,#-1
            
            add r0,r2,#0
            and r2,r2,#0
            
            add r4,r4,#-1
            br hex_loop5

           


hex_out     ld r0,sp            ;pop register
            ldr r7,r0,#0
            ldr r6,r0,#1
            ldr r5,r0,#2
            ldr r4,r0,#3
            ldr r3,r0,#4
            ldr r2,r0,#5
            ldr r1,r0,#6
            add r0,r0,#7
            st r0,sp
            
            ret                 ;return
            
            
            
asciibuff   .BLKW   6            
            

;
;function output
;



output      ld r0,sp            ;push register
            str r1,r0,#-1
            str r2,r0,#-2
            str r3,r0,#-3
            str r4,r0,#-4
            str r5,r0,#-5
            str r6,r0,#-6
            str r7,r0,#-7
            add r0,r0,#-7
            st r0,sp
            
            ;begin function          
    
            
            lea r7 hexbuff
            ldr r0,r7,#0
            and r1,r1,#0        ;r1 = 4
            add r1,r1,#4
out_loop    brz out_end
            
            add r0,r0,#-10
            brn out_less
            ld r6 charascii
            add r0,r0,r6
            
            trap x21
            
            add r7,r7,#1
            ldr r0,r7,#0
            add r1,r1,#-1
            br out_loop
            
            
            
out_less    add r0,r0,#10
            ld r6 digitascii
            add r0,r0,r6
            
            trap x21
            
            add r7,r7,#1
            ldr r0,r7,#0
            add r1,r1,#-1
            br out_loop
 
 
 
            
            
out_end     ld r0,sp            ;pop register
            ldr r7,r0,#0
            ldr r6,r0,#1
            ldr r5,r0,#2
            ldr r4,r0,#3
            ldr r3,r0,#4
            ldr r2,r0,#5
            ldr r1,r0,#6
            add r0,r0,#7
            st r0,sp
            
            ret                 ;return




numbuff     .BLKW   1
digitbuff   .BLKW   1
hexbuff     .BLKW   4
sp          .fill   x4000
empty       .fill   xc000
MAX         .fill   xc100   ;assuem stack has x0100size
neg_max     .fill   x8000
pos_max     .fill   x7fff
digitascii  .fill   x0030
charascii   .fill   x0041
temp        .BLKW   1





            .END