;---------mic.s---------
ADCPSSI					EQU			0X40038028
ADCRIS					EQU			0X40038004	
ADCSSFIFO3				EQU			0X400380A8	
ADCISC					EQU			0X4003800C
SRAM_BASE				EQU			0x20000400	
SRAM_SIZE				EQU			30000       ; SRAM size is 32 kB 
ADCSSMUX3				EQU			0X400380A0
	
					AREA 	routines, CODE, READONLY
					THUMB
					EXPORT 	read_mic
					EXTERN	delay_R5us
		
switch_mux_to_mic	PROC
					PUSH	{R0,R1,LR}
					LDR		R1,=ADCSSMUX3	; make input source as AIN0(PE3) for sequencer 3 
					MOV		R0,#0x00
					STR		R0,[R1]
					POP		{R0,R1,LR}
					BX		LR
					ENDP


read_sample_to_R5	PROC
					PUSH	{R0,R2,R3,R4,R6,LR}
					LDR 	R3, =ADCRIS ; interrupt address
					LDR 	R4, =ADCSSFIFO3 ; result address
					LDR 	R2, =ADCPSSI ; sample sequence initiate address
					LDR 	R6,= ADCISC ; address of interrupt status and clear register 
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

					; use R9 to count for sram

read_mic			PROC; start sampling routine
					PUSH	{LR}
					BL		switch_mux_to_mic
					MOV		R9,#0
mic_loop			BL		read_sample_to_R5
					; store r5 to sram
					LDR		R0,=SRAM_BASE
					LSR		R5,R5,#4    ; ignore the least significant 4 bits 
					STRB	R5,	[R0,R9] ; store the rest to the memory 
					ADD		R9,R9,#1
					LDR		R1,=SRAM_SIZE
					CMP		R9,R1
					BGT		mic_done
					MOV		R5,#110		; put 110us delay to adjust the sampling frequency to 8 kHz
					BL		delay_R5us
					B		mic_loop
mic_done			POP		{PC}
					ENDP
					END
