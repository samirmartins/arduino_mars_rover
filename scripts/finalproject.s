 # Final Project - pde file
 # EE260 - Embedded Systems
 #
 # Group:
 #        Abdi Musse
 #        Samir Martins
 # Start date: 11/10/2010
 # Finish date: / / 2010
 #

  
#
# Constants
#
      ; AD Converter
      .set ADCL,0x0078
      .set ADCH,0x0079
      .set ADCSRA,0x007A
      .set ADCSRB,0x007B
      .set ADMUX,0x007C
      .set DIDR0,0x007E
      .set PORTC,0x08
      .set DDIRC,0x07
      
      ; Moving the car
      ; portB setup
      .set PORTB,0x05
      .set DDIRB,0x04
      .set MOTDATA,0
      .set MOTLATCH,4
      .set PWM2A,3
      .set BLED, 5
      
      ; portD setup
      .set PORTD,0x0B
      .set DDIRD,0x0A
      .set MOTCLOCK,4
      .set PWM2B,3
      .set PWM0A,6
      .set PWM0B,5
      
     
#
# Program code
#            
      .text
      
      .global led_on
led_on: 
      ; Turning a LED on
      ldi r25, 0x20
      out 0x04, r25
      out 0x05, r25
      call delay2s
      ; Turning the LED off
      ldi r25, 0x00
      out 0x04, r25
      out 0x05, r25
      ret

      .global initAD
initAD:

      ; Initializing
      ldi r22, 0x3f
      ldi r23,0x00      
      out PORTC, r22 
      out DDIRC, r23 ; output port
      ldi r20, 0b00111111
      sts DIDR0, r20
      ldi r20, 0b01100000
      sts ADMUX, r20
      ldi r20, 0b11000111
      sts ADCSRA, r20  
      ret
      
      .global readAD
readAD:

      ldi r19, 0b01100000
      or r19, r24
      sts ADMUX, r19
      
loop1:
      ldi r18, 10
      ldi r20, 0b11000111
      sts ADCSRA, r20
      lds r18, ADCSRA
      andi r18, 0b01000000
      dec r18
      breq loop1
            
done:
      lds r24, ADCH 

      ret
      
      .global go_forward
go_forward:
      ldi r20, 0xff ; Setting the PORTB and PORTD as output ports
      out DDIRB, r20
      out DDIRD, r20
      
      ; go forward
      ldi r24, 0b11011000  ;Setting the direction of the motors
      call sendMotorByte
      call delay1
      call delay025s
      
      ; sending zero to the car
      ldi r24, 0b00000000  ;Setting the direction of the motors
      call sendMotorByte
      call delay1
      
      ret
      
      .global go_backward
go_backward:
      ldi r20, 0xff ; Setting the PORTB and PORTD as output ports
      out DDIRB, r20
      out DDIRD, r20
      
      ; go backward
      ldi r24, 0b00100111  ;Setting the direction of the motors
      call sendMotorByte
      call delay1
      call delay025s
      
      ; sending zero to the car
      ldi r24, 0b00000000  ;Setting the direction of the motors
      call sendMotorByte
      call delay1
                
      ret
      
      .global turn_right
turn_right:
      ldi r20, 0xff ; Setting the PORTB and PORTD as output ports
      out DDIRB, r20
      out DDIRD, r20
      
      ; turn right
      ldi r24, 0b10000000  ;Setting the direction of the motors
      call sendMotorByte
      call delay1
      call delay_45_degree
      
      ; sending zero to the car
      ldi r24, 0b00000000  ;Setting the direction of the motors
      call sendMotorByte
      call delay1
      
      ret
      
      .global turn_left
turn_left:
      ldi r20, 0xff ; Setting the PORTB and PORTD as output ports
      out DDIRB, r20
      out DDIRD, r20

      ; turn left
      ldi r24, 0b01000000  ;Setting the direction of the motors
      call sendMotorByte
      call delay1
      call delay_45_degree
      
      ; sending zero to the car
      ldi r24, 0b00000000  ;Setting the direction of the motors
      call sendMotorByte
      call delay1

      ret
        
      
delay_45_degree:
      push r20
      push r24
      ldi   r22, 0xD2 ; 45 degree => 210ms
      ldi   r23, 0x00
      ldi   r24, 0
      ldi   r25, 0
      call  delay
      pop r24
      pop r20
      ret     
      
      
delay1:
      push r20
      push r24
      ldi   r22, 0x01
      ldi   r23, 0x00
      ldi   r24, 0
      ldi   r25, 0
      call  delay
      pop r24
      pop r20
      ret

delay2s:
      push r20
      push r24
      ldi   r22, 0xD0
      ldi   r23, 0x07
      ldi   r24, 0
      ldi   r25, 0
      call  delay
      pop r24
      pop r20
      ret

delay025s:
      push r20
      push r24
      ldi   r22, 0xfa ;0.25s
      ldi   r23, 0x00
      ldi   r24, 0
      ldi   r25, 0
      call  delay
      pop r24
      pop r20
      ret
      
#  1 bit transmission
sendOneBit:
      cbi PORTB, MOTLATCH
      sbi PORTB, MOTDATA
      sbi PORTD, MOTCLOCK
      cbi PORTD, MOTCLOCK
      cbi PORTB, MOTDATA
      call delay1

      ret

# 0 bit transmission
sendZeroBit:
      cbi PORTB, MOTLATCH
      cbi PORTB, MOTDATA
      sbi PORTD, MOTCLOCK
      cbi PORTD, MOTCLOCK
      cbi PORTB, MOTDATA
      call delay1
      ret

#
# latch now should be enabled (one) in order to release 
# the control pattern to the motor driver chips 
#
latchData:
      sbi PORTB, MOTLATCH
      sbi PORTB, PWM2A
      sbi PORTD, PWM2B
      sbi PORTD, PWM0A
      sbi PORTD, PWM0B
      cbi PORTB, MOTLATCH
      ret

# latch should be zero in order to sent the control 
# pattern to shift register    
latchReset: 
      cbi   PORTB,MOTLATCH
      call  delay1
      ret

#
# Send a motor control byte to motor shield
#
sendMotorByte:
      push  r15
      push  r16
      mov   r15, r24
      call  latchReset
      ldi   r16, 8
smbloop:
      lsl   r15
      brcs  smbone
      call  sendZeroBit   
      rjmp  smbdone
smbone:
      call  sendOneBit
smbdone:
      dec   r16
      brne  smbloop
      call  latchData
      call  latchReset
      pop   r16
      pop   r15
      ret
