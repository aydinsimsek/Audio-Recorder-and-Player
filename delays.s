DELAY_1US			EQU 		5 			; clock cycles for 1 us delay
NVIC_ST_CTRL_R		EQU	  		0xE000E010
NVIC_ST_RELOAD_R	EQU		  	0xE000E014
NVIC_ST_CURRENT_R	EQU			0xE000E018
	
			AREA 	routines, CODE, READONLY
			THUMB
			EXPORT 	delay_R5us
			EXPORT	delay_init
				
delay_init	PROC
			PUSH	{R0,R1,LR}
			LDR 	R0, =NVIC_ST_CTRL_R ; SYSTICK control and status register
			MOV 	R1, #0
			STR 	R1, [R0] ; stop counter to prevent interrupt triggered accidentally
			LDR 	R1, =10 ; trigger every 10 cycles for configuration 
			STR 	R1, [R0,#4] ; write reload value to reload value register
			STR 	R1, [R0,#8] ; write any value to current value
			MOV 	R1, #0x1 ; enable SYSTICK counter
			STR 	R1, [R0] ; start counter
			POP		{R0,R1,LR}
			BX 		LR
			ENDP


delay_R5us 	PROC
			PUSH 	{R0,R1,LR}
			LDR 	R0, =DELAY_1US
			MUL 	R0,R0,R5
			LDR 	R1, =NVIC_ST_RELOAD_R
			STR		R0,[R1]
			LDR 	R1, =NVIC_ST_CURRENT_R
			STR 	R0, [R1] ; any value written to CURRENT clears
			
			LDR 	R1, =NVIC_ST_CTRL_R
delay_loop	LDR 	R0, [R1] ; read status
			ANDS 	R0, R0, #0x00010000 ; bit 16 is COUNT flag
			BEQ 	delay_loop ; repeat until flag set
			POP 	{R0,R1,LR}
			BX 		LR ; flag set, so return from sub
			ENDP
			END

