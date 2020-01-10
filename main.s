SYSCTL_RCC			EQU 	0x400FE060 ; Run Mode Clock Configuration
SYSCTL_RIS 			EQU 	0x400FE050 ; Raw Interrupt Status 
ADC0_RIS 			EQU 	0x40038004 ; ADC0 Raw Interrupt Status 
ADC0_SSFIFO3		EQU 	0x400380A8 ; ADC0 SS Result FIFO 
ADC0_ISC 			EQU 	0x4003800C ; ADC0 Interrupt Status and Clear 
STCTRL 				EQU 	0xE000E010 ; SysTick Control and Status 
I2C_MDR 			EQU 	0x40021008 ; I2C Master Data 
I2C_MCS 			EQU 	0x40021004 ; I2C Master Control/Status 
	
SRAM_BASE_ADDRESS 	EQU 	0x20000000
					
					
					AREA 	main, CODE, READONLY
					THUMB
					EXPORT	__main
					EXPORT	serial
					EXTERN 	init 
					EXTERN 	timer_init 
						
__main 				LDR 	R1,=SYSCTL_RCC 
					LDR 	R0,[R1] 
					ORR 	R0,R0,#0x800 ; set the BYPASS bit 
					STR 	R0,[R1] 
					LDR 	R1,=SYSCTL_RCC 
					LDR 	R0,[R1]
					BIC 	R0,R0,#0x400000 ; clear the USESYS bit 
					STR 	R0,[R1] 
					
					LDR 	R1,=SYSCTL_RCC 
					LDR 	R0,[R1] 
					BIC 	R0,R0,#0x2000 ; clear the PWRDN bit to power and enable the PLL 
					STR 	R0,[R1] 
					
					LDR 	R1,=SYSCTL_RCC 
					LDR 	R0,[R1] 
					ORR 	R0,R0,#0x4800000 ; set SYSDIV to 0x9 for 20 MHz frequency 
					STR 	R0,[R1] 
					LDR 	R1,=SYSCTL_RCC 
					LDR 	R0,[R1] 
					ORR 	R0,R0,#0x400000 ; set the USESYS bit then system clock divider is the source for system clock  
					STR 	R0,[R1] 
					
					LDR 	R1,=SYSCTL_RIS 
lock				LDR 	R0,[R1] 
					ANDS 	R0,R0,#0x40 ; poll the PLLLRIS bit 
					BEQ 	lock ; if PLLLRIS is not set, poll RIS register until PLL is locked 
					
					LDR 	R1,=SYSCTL_RCC 
					LDR 	R0,[R1] 
					BIC 	R0,R0,#0x800 ; clear the BYPASS bit to use PLL 
					STR		R0,[R1] 
					
					BL 		init 
					LDR 	R2,=0x20000000 ; R2 holds starting address of the SRAM  
					
loop				LDR 	R1,=ADC0_RIS 
check				LDR 	R0,[R1]
					ANDS 	R0,R0,#8 ; check if sampling is complete 
					BEQ 	check
	
	
; put 100 ns delay with SysTick and then read the sample value to get 8 kHz sampling frequency 	
					LDR 	R1,=STCTRL
					MOV 	R0,#0 
					STR 	R0,[R1] ; disable SysTick 
					MOV 	R0,#1 
					STR 	R0,[R1,#4] ; load 1 to STRELOAD for 100 ns delay    
					STR 	R0,[R1,#8] ; load 1 to STCURRENT to clear COUNT flag
					MOV 	R0,#5 
					STR 	R0,[R1] ; enable SysTick, use system clock as clock source, no interrupt 
					
count				LDR 	R0,[R1] 
					ANDS 	R0,R0,#0x10000 ; poll the COUNT bit 
					BEQ 	count 
					
					LDR 	R1,=ADC0_SSFIFO3 
					LDR 	R0,[R1] ; R0 holds the result of the sampling  			
				    STR 	R0,[R2],#2 ; preserve the recording in the memory        

					LDR 	R1,=ADC0_ISC
					MOV 	R0,#8
					STR 	R0,[R1] ; clear flag
					
					BL 		timer_init 
					B 		loop ; take another sample 
					

serial 				LDR 	R0,[R2,#-2]! ; get data from the memory 
					LDR 	R1,=I2C_MDR 
					STR 	R0,[R1] ; write data to I2C_MDR                      // POST-INDEX KONULACAK MI ????          
					
					
					LDR 	R1,=I2C_MCS 
bus_busy			LDR 	R0,[R1] ; read I2C_MCS 
					ANDS 	R0,R0,#0x40 ; check if BUSBSY bit is 0 
					BNE     bus_busy
					
					MOV 	R0,#0x03 
					STR 	R0,[R1] ; set the START and RUN bits when the first data byte is transmitted 
					
read				LDR 	R0,[R1] ; read I2C_MCS 
busy				ANDS 	R0,R0,#0x01 ; check if BUSY bit is 0 
					BNE 	read 
					
					ANDS 	R0,R0,#0x02 ; check if ERROR bit is 0 
					BNE     arbitration 
					
					LDR 	R0,[R2,#-2]! ; get data from the memory 
					LDR 	R1,=I2C_MDR 
					STR 	R0,[R1] ; write data to I2C_MDR  

					LDR 	R3,=SRAM_BASE_ADDRESS
					CMP 	R2,R3
					BNE     again ; if all voice is not played read I2C_MCS again 
					
					LDR 	R1,=I2C_MCS 
					MOV 	R0,#0x05 ; set STOP and RUN bit if all voice data is played 
					STR 	R0,[R1] 
					
busy_2				LDR 	R0,[R1] 
					ANDS 	R0,R0,#0x01 ; check if BUSY bit is 0 
					BNE 	busy_2 
					
					ANDS 	R0,R0,#0x02 ; check if ERROR bit is 0 
					BEQ 	done					
					B 		error_service 
								
arbitration 		LDR 	R1,=I2C_MCS 
					LDR 	R0,[R1] ; read I2C_MCS 
					ANDS 	R0,R0,#0x10 ; check if ARBLST bit is 1
					BNE 	error_service 
					
					MOV 	R0,#0x04 
					STR 	R0,[R1] ; set the STOP bit 
								
error_service 		B 		error_service											;BURADA NE YAPACAZ ????? 	

again  				LDR 	R1,=I2C_MCS 
					MOV 	R0,#0x01 ; set RUN bit if all voice data is not played 
					STR 	R0,[R1] 
					B 		read 
						
done 				B 		done 				
					
					END