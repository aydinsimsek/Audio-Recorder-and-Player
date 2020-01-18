SYSCTL_RCGCGPIO		EQU		 0x400FE608	; GPIO Clock
RCGCI2C 			EQU 	 0x400FE620 ; I2C clock 
GPIO_PORTA_DIR 		EQU 	 0x40004400 
GPIO_PORTA_DEN 		EQU 	 0x4000451C 
GPIO_PORTA_AFSEL 	EQU 	 0x40004420 
GPIO_PORTA_AMSEL 	EQU 	 0x40004528 
GPIO_PORTA_PCTL     EQU      0x4000452C	
GPIO_PORTA_ODR 		EQU 	 0x4000450C ; Open Drain select 
I2C_MCR 			EQU 	 0x40021020 ; Master Configuration 
I2C_MTPR 		 	EQU 	 0x4002100C ; Master Timer Period 
I2C_MSA 		    EQU 	 0x40021000 ; Master Slave Address 
I2C_MDR 		    EQU 	 0x40021008 ; Master Data Address 
I2C_MCS		    	EQU 	 0x40021004 ; Master Control/Status Address 
SRAM_BASE			EQU		 0x20000400	
SRAM_SIZE			EQU		 30000

					AREA 	i2c, CODE, READONLY
					THUMB
					EXTERN	delay_R5us
					EXPORT	dac_init
					EXPORT  dac_write
					
; configure I2C module 1 

dac_init			PROC
					PUSH	{R0,R1,LR}
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
					ORR 	 R0,R0,#0x02 ; set TPR field to 0x2 for 333 kbps SCL clock speed 	
					STR 	 R0,[R1] 
					
					LDR 	 R1,=I2C_MSA
					LDR 	 R0,[R1] 
					ORR 	 R0,R0,#0xC4 ; set slave address to 62 and next operation is a Transmit 
					STR 	 R0,[R1] 
					POP		{R0,R1,LR}				
					BX       LR 
					ENDP 

dac_send			PROC
					PUSH	{R0,R1,LR}
					
					LDR 	R1,=I2C_MDR 
					MOV		R0,R5
					LSR		R0,R0,#4
					STRB 	R0,[R1] ; write data to I2C_MDR
					
					LDR 	R1,=I2C_MCS 
bus_busy2			LDR 	R0,[R1] ; read I2C_MCS 
					ANDS 	R0,R0,#0x40 ; check if BUSBSY bit is 0 
					BNE     bus_busy2 ; if it's 1 read I2C_MCS again 
					
					LDR		R0,[R1]
					BIC		R0,R0,#0x14
					ORR 	R0,R0,#0x03 
					STR 	R0,[R1] ; set the START and RUN bits when the first data byte is transmitted 
					
read2				LDR 	R0,[R1] ; read I2C_MCS 
bb					ANDS 	R0,R0,#0x01 ; check if BUSY bit is 0 
					BNE 	read2 ; if it's 1 read I2C_MCS again 
					
					ANDS 	R0,R0,#0x02 ; check if ERROR bit is 0 
					BNE 	done ; if it's 1 end the transmission 
					
					LDR 	R1,=I2C_MDR
					MOV		R0,R5
					LSL		R0,R0,#4
					STRB 	R5,[R1] ; write data to I2C_MDR    
					LDR 	R1,=I2C_MCS 
					LDR		R0,[R1]
					BIC		R0,R0,#0x12
					ORR 	R0,R0,#0x05 
					STR 	R0,[R1] ; set STOP and RUN bit when the first data byte is transmitted 	
					
read				LDR 	R0,[R1] ; read I2C_MCS 	
busy				ANDS 	R0,R0,#0x01 ; check if BUSY bit is 0 
					BNE 	read ; if it's 1 read I2C_MCS again 
					
done				LDR		R0,[R1]
					BIC		R0,R0,#0x13
					ORR 	R0,R0,#0x04 
					STR 	R0,[R1] ; set the STOP bit  
					POP		{R0,R1,LR}
					BX		LR
					ENDP


dac_write			PROC				 ; start sampling routine
					PUSH	{LR}
					MOV		R9,#0
dac_loop			LDR		R0,=SRAM_BASE
					LDRB	R5,	[R0,R9]
					ADD		R9,R9,#1
					BL		dac_send
					LDR		R1,=SRAM_SIZE
					CMP		R9,R1
					BGT		dac_done
					MOV 	R11,#4095    ; delay = 100*(pot value/4095)+25 to get vocal effects during playing of the recording    
					UDIV 	R10,R10,R11
					MOV 	R11,#100
					MUL 	R10,R10,R11
					ADD 	R10,R10,#25
					MOV		R5,R10 		
					BL		delay_R5us
					B		dac_loop
dac_done			POP		{PC}
					ENDP
					END

