GPIO_PORTF_DATA		EQU		 0x400253FC ; Data	
GPIO_PORTF_DIR 		EQU      0x40025400 ; Direction 
GPIO_PORTF_AFSEL	EQU      0x40025420 ; Alternate Function select
GPIO_PORTF_DEN 		EQU      0x4002551C ; Digital Enable
GPIO_PORTF_PUR      EQU      0x40025510 ; Pull-UP select 
SYSCTL_RCGCGPIO     EQU      0x400FE608 ; GPIO clock 
GPIO_PORTF_AMSEL    EQU      0x40025528 ; Analog Mode select 
GPIO_PORTF_PCTL     EQU      0x4002552C ; Port Control 
GPIO_PORTF_LOCK		EQU      0x40025520 ; Lock 
GPIO_PORTF_CR 		EQU 	 0x40025524 ; Commit 
								
					AREA 	 initialization, CODE, READONLY
					THUMB
					EXPORT	 push_button_init
					EXPORT	 push_button_check
					EXPORT 	 push_button_check_2 

push_button_check	PROC
					PUSH	{LR}
					LDR		R1,=GPIO_PORTF_DATA					
button_loop			LDR		R0,[R1]
					ANDS	R0,R0,#0x10 ; check if PF4 is cleared/SW1 is pressed  
					BNE		button_loop
					MOV 	R0,#2 
					STR 	R0,[R1] ; turn on the red LED 
					POP		{LR}
					BX		LR
					ENDP

push_button_check_2	PROC
					PUSH	{LR}
					LDR		R1,=GPIO_PORTF_DATA					
button_loop_2		LDR		R0,[R1]
					ANDS	R0,R0,#0x01 ; check if PF0 is cleared/SW2 is pressed   
					BNE		button_loop_2
					MOV 	R0,#8 
					STR 	R0,[R1] ; turn on the green LED 
					POP		{LR}
					BX		LR
					ENDP

				
push_button_init    PROC
					PUSH	 {LR}
					LDR      R1,=SYSCTL_RCGCGPIO                                      
					LDR      R0,[R1] 
					ORR      R0,R0,#0x20 ; enable clock for port F
					STR      R0,[R1] 
					NOP 
					NOP 
					NOP                     ; to stabilize the clock 

; configure PF4 and PF0 to use push buttons SW1 and SW2 on TM4C 
; configure PF1, PF2 and PF3 to use RGB LEDs on TM4C 

					LDR      R1,=GPIO_PORTF_DIR
				    LDR      R0,[R1] 
					BIC      R0,R0,#0x11 ; use PF4 and PF0 as input
					ORR 	 R0,R0,#0x0E ; use PF1, PF2 and PF3 as output 
					STR      R0,[R1] 
					
					LDR      R1,=GPIO_PORTF_LOCK   
					LDR 	 R0,=0x4C4F434B ; to unlock PF0 
					STR      R0,[R1]
					
					LDR      R1,=GPIO_PORTF_CR 
					LDR      R0,[R1]
					ORR      R0,R0,#0x1F ; commit after unlock     
					STR      R0,[R1]
					
					LDR      R1,=GPIO_PORTF_AFSEL
				    LDR      R0,[R1]
					BIC      R0,R0,#0x1F ; disable alternate function for the pins
					STR      R0,[R1] 
					
					LDR      R1,=GPIO_PORTF_PCTL
					LDR      R0,[R1]
					BIC      R0,R0,#0x1F ; configure the pins as GPIO 
					STR      R0,[R1] 
					
					LDR      R1,=GPIO_PORTF_DEN
				    LDR      R0,[R1]
					ORR      R0,R0,#0x1F ; enable digital input for the pins 
					STR      R0,[R1] 
					
					LDR      R1,=GPIO_PORTF_AMSEL
					LDR      R0,[R1]
					BIC      R0,R0,#0x1F ; disable analog functionality 
					STR      R0,[R1] 
					
					LDR      R1,=GPIO_PORTF_PUR  
					LDR      R0,[R1]
					ORR      R0,R0,#0x11 ; enable the internal pull-up resistors for PF0 and PF4 
					STR      R0,[R1]
									
					POP		 {LR}
					BX       LR 
					ENDP 
					END 