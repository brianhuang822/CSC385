.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000 
.equ ADDR_SLIDESWITCHES, 0xFF200040
.equ Timer, 0xFF202000  # (Hint: See DESL website for documentation on LEDs/Switches)
.equ Lego, 0xFF200070
.equ ADDR_PUSHBUTTONS, 0xFF200050
.equ IRQ_PUSHBUTTONS, 0x02
.equ LEDS, 0xFF200000
.equ PERIOD, 500000000
.global main
.section .exceptions, "ax"
IHANDLER:
#wrctl ctl0, r0 #turn off PIE bit
#rdctl et, ctl4
#andi et,et,0x1 # check if interrupt pending from IRQ0 (ctl4:bit0)
#beq et,r0,IDoButtons # if not timer, try buttons
#BUTTONS  
#Free some registers to use
subi sp, sp, 20
stw r5, 0(sp)
stw r6, 4(sp)
stw r7, 8(sp)
stw r8, 12(sp)
stw r9, 16(sp)
stw r10, 20(sp)
  andi r15, r14, 2
beq r0 , r15, CHECKRIGHT
  #Timer set
ldwio r19, 8(r11)
  addi r19 ,r19, 500
  stwio r19, 8(r11)    
br COLOUR
CHECKRIGHT:
andi r15, r14, 1
beq r0 , r15, COLOUR
ldwio r19, 8(r11)
  subi r19 ,r19, 500
  blt r0, r19, COLOUR
  stwio r19, 8(r11) 
COLOUR:
movia r6, Lego
movia  r10, 0x07f557ff     # set direction for motors and sensors to output and sensor data register to inputs
   stwio  r10, 4(r6)
   
 movia r5, 0xfffffbff
   stwio  r5, 0(r6)

   WAIT:
   ldwio  r7,  0(r6)          # checking for valid data sensors
   srli   r8,r7,11          # bit 11 is valid bit for sensor 0
   andi   r8,  r8,0x1
   #bne    r0,  r8,WAIT        # wait for valid bit to be low: sensor 0 needs to be valid
 good:
   srli   r7, r7, 27          # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits
   andi   r9, r7, 0x0f        #Value of sensor 1 is r9
   
   
  movia r5, 0xffffefff
   stwio  r5, 0(r6)

    WAIT1:
   ldwio  r7,  0(r6)          # checking for valid data sensors
   srli   r8,r7,13          # bit 11 is valid bit for sensor 0
   andi   r8,  r8,0x1
  #bne    r0,  r8,WAIT        # wait for valid bit to be low: sensor 0 needs to be valid
 good1:
   srli   r7, r7, 27          # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits
   andi   r10, r7, 0x0f        #Value of sensor 0 is r10
 
# r9 and r10 have the values 
movia r5, 5 #Lower
movia r6, 10 #Upper
blt r9,r6, XNotUpper
addi r20, r20, 1
br YCHECK
XNotUpper:
blt r9, r5, XNotLower
addi r20, r20, 0
br YCHECK
XNotLower:
subi r20, r20, 1


YCHECK:
blt r10,r6, YNotUpper
addi r21, r21, 1
br ModuloTheCordsX
YNotUpper:
blt r10, r5, YNotLower
addi r21, r21, 0
br ModuloTheCordsX
YNotLower:
subi r21, r21, 1



ModuloTheCordsX:
bgt r20, r0, XNotLess
movi r20, 319
br ModuloTheCordsY
XNotLess:
movi r5, 319
blt r20, r5, ModuloTheCordsY
movi r20, 0



ModuloTheCordsY:
bgt r21, r0, YNotLess
movi r21, 239
br MULTIPLYCORDS
YNotLess:
movi r5, 239
blt r21, r5, MULTIPLYCORDS
movi r21, 0


MULTIPLYCORDS:
muli r5, r20, 2
muli r6, r21, 1024
movia r2, ADDR_VGA
 add r2, r5, r2
 add r2, r6, r2
  sthio r4,0(r2) /* r2 + 1032 pixel (4,1) is x*2 + y*1024 so (8 + 1024 = 1032) */
	
	TimerReset:
	stwio r0, 0(r11)
movia r12, 7
  stwio r12, 4(r11)                          # Start the timer without continuing or interrupts 


#IDoButtons:
 # set LEDS to values
# NOTE: must save/restore any registers used other than et
#movia r10,LEDS
#movia et, ADDR_PUSHBUTTONS
#stwio r0,12(et) #acknowledge
#ldwio et,0(et) #get button values
#stwio et,0(r10) #change LEDs

EXIT_IHANDLER:
ldw r5, 0(sp)
ldw r6, 4(sp)
ldw r7, 8(sp)
ldw r8, 12(sp)
ldw r9, 16(sp)
ldw r10, 20(sp)
addi sp, sp, 20
subi ea,ea,4 #adjust return address
eret

#Register map
# r2 VGA location
# r4 Current COLOUR
# r5 Switch Location
# r6 Switch values
# r7 RED
# r8 GREEN
# r9 BLUE
# r10 Push Buttons
# r11 Timer location
# r12 Timer temp
# r13 LEDS
# r14 Push Button values
# r15 condition checker
# r16 temp color
# r17 temp screen pointer
# r18 max 
# r19 timer
# r20 currentX
# r21 currentY
main:
movia sp, 0x50000000
mov r20, r0
mov r21, r0
  #movia r2,0x3
  movia r2,0x1
  wrctl ctl3,r2   # Enable interupts
  movia r19, 0x1DCD6500
  #Timer set
  movia r11, Timer
  stwio r19, 8(r11)                          # Set the period to be 1000 clock cycles 
  stwio r0, 12(r11)

  movui r12, 7
  stwio r12, 4(r11)                          # Start the timer without continuing or interrupts 

  
  movia r2,1
  wrctl ctl0,r2   # Enable global Interrupts on Processor 

  movia r2,ADDR_VGA
  movia r5,ADDR_SLIDESWITCHES
    #Timer
	
LOOP:
 
  ldwio r6,0(r5)                # Read switches 
  #RED
  srli r7, r6, 7 #Red
  slli r7, r7, 2 #Red shift 2 pad
  addi r7, r7, 1
  #GREEN
  srli r8, r6, 3 #Green
  andi r8, r8, 0xF #Pad it to 6 of them
  slli r8, r8, 2 #Green shift 2 pad
  addi r8, r8, 1
  #BLUE
  andi r9, r6, 0x7 # Blue Pad it to 5 of them
  slli r9, r9, 2 #Blue shift 2 pad
  addi r9, r9, 1
  #COMBINE
  mov r4, r7 #Red first
  slli r4, r4, 6 #Space for green
  add r4, r4, r8
  slli r4,r4, 5 #Space for Blue
  add r4, r4, r9
  
  #CHECK Buttons
  movia r10, ADDR_PUSHBUTTONS
  movia r13,LEDS
  ldwio r14,0(r10) #get button values
  stwio r14,0(r13) #change LEDs
  CHECKCLEAR:
  andi r15, r14, 8
  beq r0, r15, CHECKFILL
  movia r16, 0xFFFF
  br CLEARFILL
  CHECKFILL:
    andi r15, r14, 4
  beq r0, r15, LEAVE
  mov r16, r4
  br CLEARFILL
  LEAVE:
  br LOOP
  CLEARFILL:
  movia r17, ADDR_VGA
  movia r18, 0x0804B000
  CLEARFILLLOOP:
   sthio r16,0(r17) /* r2 + 1032 pixel (4,1) is x*2 + y*1024 so (8 + 1024 = 1032) */
  addi r17, r17, 1
  bgtu r17, r18, LOOP
br CLEARFILLLOOP