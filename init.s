GPIO_PORTF_DIR 		EQU      0x40025400 ; Direction 
GPIO_PORTF_AFSEL	EQU      0x40025420 ; Alternate Function select
GPIO_PORTF_DEN 		EQU      0x4002551C ; Digital Enable
GPIO_PORTF_PUR      EQU      0x40025510 ; Pull-Up select 
SYSCTL_RCGCGPIO     EQU      0x400FE608 ; GPIO clock 
GPIO_PORTF_AMSEL    EQU      0x40025528 ; Analog Mode select 
GPIO_PORTF_PCTL     EQU      0x4002552C ; Port Control 
GPIO_PORTF_ADCCTL   EQU 	 0x40025530 ; ADC Control 
GPIO_PORTF_IEV 		EQU 	 0x4002540C ; Interrupt Event 
GPIO_PORTF_IM 		EQU 	 0x40025410 ; Interrupt Mask 
GPIO_PORTF_ICR 		EQU 	 0x4002541C ; Interrupt Clear 

RCGCADC 			EQU 	 0x400FE638 ; ADC clock 
ADC0_ACTSS			EQU 	 0x40038000 ; Active sample sequencer 
ADC0_EMUX 			EQU 	 0x40038014 ; Trigger select
ADC0_SSMUX3 		EQU 	 0x400380A0 ; Input channel select
ADC0_SSCTL3 		EQU 	 0x400380A4 ; Sample sequence control
ADC0_PC 			EQU 	 0x40038FC4 ; Sample rate

GPIO_PORTE_DIR 		EQU 	 0x40024400 
GPIO_PORTE_DEN 		EQU 	 0x4002451C 
GPIO_PORTE_AFSEL 	EQU 	 0x40024420 
GPIO_PORTE_AMSEL 	EQU 	 0x40024528 
	
RCGCI2C 			EQU 	 0x400FE620 ; I2C clock 
I2C_MCR 			EQU 	 0x40021020 ; Master Configuration 
I2C_MTPR 		 	EQU 	 0x4002100C ; Master Timer Period 
I2C_MSA 		    EQU 	 0x40021000 ; Master Slave Address 

GPIO_PORTA_DIR 		EQU 	 0x40004400 
GPIO_PORTA_DEN 		EQU 	 0x4000451C 
GPIO_PORTA_AFSEL 	EQU 	 0x40004420 
GPIO_PORTA_AMSEL 	EQU 	 0x40004528 
GPIO_PORTA_PCTL     EQU      0x4000452C	
GPIO_PORTA_ODR 		EQU 	 0x4000450C ; Open Drain select 
					
					
					AREA 	 initialization, CODE, READONLY
					THUMB
					EXPORT	 init
					EXTERN 	 __main 
						
				
				
init         		PROC
					LDR      R1,=SYSCTL_RCGCGPIO                                      
					LDR      R0,[R1] 
					ORR      R0,R0,#0x20 ; enable clock for port F
					STR      R0,[R1] 
					NOP 
					NOP 
					NOP                     ; to stabilize the clock 


; configure PF4 to use push button SW1 on TM4C 

					LDR      R1,=GPIO_PORTF_DIR
				    LDR      R0,[R1] 
					BIC      R0,R0,#0x10 ; use PF4 for input
					STR      R0,[R1] 
					
					LDR      R1,=GPIO_PORTF_AFSEL
				    LDR      R0,[R1]
					BIC      R0,R0,#0x10 ; disable alternate function for the pin
					STR      R0,[R1] 
					
					LDR      R1,=GPIO_PORTF_PCTL
					LDR      R0,[R1]
					BIC      R0,R0,#0x10 ; configure the port as GPIO 
					STR      R0,[R1] 
					
					LDR      R1,=GPIO_PORTF_DEN
				    LDR      R0,[R1]
					ORR      R0,R0,#0x10 ; enable digital input for the pin 
					STR      R0,[R1] 
					
					LDR      R1,=GPIO_PORTF_AMSEL
					LDR      R0,[R1]
					BIC      R0,R0,#0x10 ; disable analog functionality 
					STR      R0,[R1] 
					
					LDR      R1,=GPIO_PORTF_PUR  
					LDR      R0,[R1]
					MOV      R0,#0x10 ; use the internal pull-up resistor for the pin 
					STR      R0,[R1]
					
					LDR 	 R1,=GPIO_PORTF_ADCCTL 
					LDR 	 R0,[R1] 
					ORR 	 R0,R0,#0x10 ; set bit0 to use PF4 to trigger ADC 
					STR 	 R0,[R1] 
					
					LDR 	 R1,=GPIO_PORTF_IEV 
					LDR 	 R0,[R1] 
					ORR 	 R0,R0,#0x10 ; set bit 0 for a falling edge on PF4 trigger an interrupt  
					STR 	 R0,[R1] 
					
					LDR 	 R1,=GPIO_PORTF_IM 
					LDR 	 R0,[R1] 
					ORR 	 R0,R0,#0x10 ; set bit0 to enable interrupts from PF4  
					STR 	 R0,[R1] 
					
					LDR 	 R1,=GPIO_PORTF_ICR 
					LDR 	 R0,[R1] 
					ORR 	 R0,R0,#0x10 ; clear interrupt flags on PF4
					STR 	 R0,[R1] 
					

; PE3 will be used to receive the analog signal

					LDR 	 R1,=RCGCADC  
					LDR 	 R0,[R1]
					ORR		 R0,R0,#0x01 ; enable ADC0 clock 
					STR 	 R0,[R1] 
					NOP 
					NOP 
					NOP 
					
					LDR 	 R1,=SYSCTL_RCGCGPIO
					LDR      R0,[R1] 
					ORR      R0,R0,#0x10 ; enable clock for port E
					STR      R0,[R1] 
					NOP 
					NOP 
					NOP                     ; to stabilize the clock 
					
					LDR 	 R1,=GPIO_PORTE_DIR 
					LDR 	 R0,[R1]
					BIC 	 R0,R0,#0x08 ; clear bit 3 to make PE3 input 
					STR 	 R0,[R1] 
					
					LDR 	 R1,=GPIO_PORTE_AFSEL
					LDR 	 R0,[R1]
					ORR 	 R0,R0,#0x08 ; set bit 3 to enable alternate functions on PE3
					STR 	 R0,[R1]		
					
					LDR 	 R1,=GPIO_PORTE_DEN
					LDR 	 R0,[R1]
					BIC 	 R0,R0,#0x08 ; clear bit 3 to disable digital on PE3
					STR 	 R0,[R1]		
					
					LDR 	 R1,=GPIO_PORTE_AMSEL
					LDR 	 R0,[R1]
					ORR 	 R0,R0,#0x08 ; set bit 3 to enable analog on PE3
					STR 	 R0,[R1]			
					
					LDR 	 R1,=ADC0_ACTSS
					LDR 	 R0,[R1]
					BIC 	 R0,R0,#0x08 ; clear bit 3 to disable SS3
					STR 	 R0,[R1]		
					
					LDR 	 R1,=ADC0_EMUX
					LDR 	 R0,[R1]
					ORR 	 R0,R0,#0x4000 ; set bits 15:12 to 0x4 to select GPIO trigger 
					STR 	 R0,[R1]			
					
					LDR 	 R1,=ADC0_SSMUX3
					LDR 	 R0,[R1]
					BIC 	 R0,R0,#0x000F ; clear bits 3:0 to select AIN0
					STR 	 R0,[R1]			
					
					LDR 	 R1,=ADC0_SSCTL3
					LDR 	 R0,[R1]
					ORR 	 R0,R0,#0x06 ; set bits 2:1 (IE0, END0)
					STR 	 R0,[R1]		
					
					LDR 	 R1,=ADC0_PC
					LDR 	 R0,[R1] 
					ORR 	 R0,R0,#0x01 ; set bits 3:0 to 1 for 125k sps             
					STR 	 R0,[R1]		
					
					LDR 	 R1,=ADC0_ACTSS
					LDR 	 R0,[R1]
					ORR 	 R0,R0,#0x08 ; set bit 3 to enable SS3
					STR 	 R0,[R1] 
					
					
; configure I2C module 1 

				    LDR 	 R1,=RCGCI2C 
					LDR 	 R0,[R1]
					ORR 	 R0,R0,#0x02 ; set bit 1 to enable clock for I2C module 1 
					STR 	 R0,[R1] 
					NOP 
					NOP 
					NOP                  ; to stabilize the clock 
						
						
				    LDR      R1,=SYSCTL_RCGCGPIO                                      
					LDR      R0,[R1] 
					ORR      R0,R0,#0x01 ; enable clock for port A
					STR      R0,[R1] 
					NOP 
					NOP 
					NOP                     ; to stabilize the clock 
					
					
					LDR 	 R1,=GPIO_PORTA_DEN 
					LDR 	 R0,[R1] 
					ORR 	 R0,R0,#0xC0 ; enable digital on PA7 and PA6 
					STR 	 R0,[R1] 
					
					LDR 	 R1,=GPIO_PORTA_AMSEL  
					LDR 	 R0,[R1] 
					BIC  	 R0,R0,#0xC0 ; disable analog on PA7 and PA6 
					STR 	 R0,[R1] 
					
					
					LDR      R1,=GPIO_PORTA_AFSEL 
					LDR 	 R0,[R1] 
					ORR 	 R0,R0,#0xC0 ; enable alternate functions on PA7 and PA6 
					STR 	 R0,[R1] 
					
					
					LDR 	 R1,=GPIO_PORTA_ODR 
					LDR 	 R0,[R1] 
					ORR 	 R0,R0,#0x80 ; enable PA7 for open drain operation 
					STR  	 R0,[R1]

					LDR      R1,=GPIO_PORTA_PCTL 
					LDR 	 R0,[R1] 
					BIC 	 R0,R0,#0xFF000000 
					ORR 	 R0,R0,#0x33000000 ; set bits [31:28] to 0x3 to select I2C1SDA on PA7 
											   ; and set bits [27:24] to 0x3 to select I2C1SCL on PA6 
					STR 	 R0,[R1] 
						
					LDR 	 R1,=I2C_MCR 
					LDR 	 R0,[R1] 
					ORR 	 R0,R0,#0x10 ; enable master function 
					STR 	 R0,[R1] 
					
					LDR 	 R1,=I2C_MTPR
					LDR 	 R0,[R1] 
					ORR 	 R0,R0,#0x09 ; set TPR field to 0x9 for 100 kbps SCL clock speed 
					STR 	 R0,[R1] 
					
					LDR 	 R1,=I2C_MSA
					LDR 	 R0,[R1] 
					ORR 	 R0,R0,#0x78 ; set slave address to 60 and next operation is a Transmit 
					STR 	 R0,[R1] 
					
					
					
					
					
					BX       LR 
					
					ENDP 
					END 
						

			
					
					
					
					
					
					
					
					