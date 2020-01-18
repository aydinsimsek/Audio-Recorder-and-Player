;---------pot.s---------
ADCPSSI					EQU			0X40038028
ADCRIS					EQU			0X40038004	
ADCSSFIFO3				EQU			0X400380A8	
ADCISC					EQU			0X4003800C
SRAM_BASE				EQU			0x20000400	
SRAM_SIZE				EQU			30000
ADCSSMUX3				EQU			0X400380A0	
;------------------------
		AREA 	routines, CODE, READONLY
		THUMB
		EXPORT 	read_pot
			
switch_mux_to_pot	PROC
					PUSH	{R0,R1,LR}
					LDR		R1,=ADCSSMUX3				; make input source as AIN1(PE2) for sequencer 3 
					MOV		R0,#0x01					; select AIN1
					STR		R0,[R1]
					POP		{R0,R1,LR}
					BX		LR
					ENDP

read_sample_to_R5	PROC
					PUSH	{R0,R2,R3,R4,R6,LR}
					LDR 	R3, =ADCRIS ; interrupt address
					LDR 	R4, =ADCSSFIFO3 ; result address
					LDR 	R2, =ADCPSSI ; sample sequence initiate address
					LDR 	R6,= ADCISC
					; initiate sampling by enabling sequencer 3 in ADC0_PSSI
Smpl 				LDR 	R0, [R2]
					ORR 	R0, R0, #0x08 ; set bit 3 for SS3
					STR 	R0, [R2]
					; check for sample complete (bit 3 of ADC0_RIS set)
Cont 				LDR 	R0, [R3]
					ANDS 	R0, R0, #8
					BEQ 	Cont
					;branch fails if the flag is set so data can be read and flag is cleared
					LDR 	R5, [R4] ;store the data
					MOV 	R0, #8
					STR 	R0, [R6] ; clear flag
					POP		{R0,R2,R3,R4,R6,LR}
					BX		LR
					ENDP

read_pot 			PROC; start sampling routine
					PUSH	{LR}
					BL		switch_mux_to_pot
					BL		read_sample_to_R5
					; store r5 to sram
					MOV		R10,R5
done				POP		{PC}
					ENDP
					END