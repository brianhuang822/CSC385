.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000 
.equ ADDR_SLIDESWITCHES, 0xFF200040
.equ Timer, 0xFF202000  # (Hint: See DESL website for documentation on LEDs/Switches)
.equ Lego, 0xFF200060
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
#COLOUR:
  sthio r4,0(r2) /* r2 + 1032 pixel (4,1) is x*2 + y*1024 so (8 + 1024 = 1032) */
  addi r2, r2, 1
    movia r18, 0x0804B000
	bgtu r18, r2, TimerReset
	#RESET
	movia r2, ADDR_VGA
	TimerReset:
	stwio r0, 0(r11)
movia r12, 7
  stwio r12, 4(r11)                          # Start the timer without continuing or interrupts 

#br EXIT_IHANDLER
#IDoButtons:
 # set LEDS to values
# NOTE: must save/restore any registers used other than et
#movia r10,LEDS
#movia et, ADDR_PUSHBUTTONS
#stwio r0,12(et) #acknowledge
#ldwio et,0(et) #get button values
#stwio et,0(r10) #change LEDs

EXIT_IHANDLER:
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
main:
  #movia r2,0x3
  movia r2,0x1
  wrctl ctl3,r2   # Enable interupts

  #Timer set
  movia r11, Timer
  movui r12, %lo(PERIOD)
  stwio r12, 8(r11)                          # Set the period to be 1000 clock cycles 
  movui r12, %hi(PERIOD)
  stwio r0, 12(r11)

  movui r12, 5
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
  beq r0, r15, CHECKLEFT
  mov r16, r4
  br CLEARFILL
  CHECKLEFT:
  br LOOP
  CLEARFILL:
  movia r17, ADDR_VGA
  movia r18, 0x0804B000
  CLEARFILLLOOP:
   sthio r16,0(r17) /* r2 + 1032 pixel (4,1) is x*2 + y*1024 so (8 + 1024 = 1032) */
  addi r17, r17, 1
  bgtu r17, r18, LOOP
br CLEARFILLLOOP