;--------------------------------------------------------------------
RCGCADC				EQU			0X400FE638
RCGCGPIO			EQU			0X400FE608
GPIO_PORTE_DATA		EQU			0X400243FC
GPIO_PORTE_DIR		EQU			0X40024400	
GPIO_PORTE_AFSEL	EQU			0X40024420
GPIO_PORTE_DEN		EQU			0X4002451C
GPIO_PORTE_AMSEL	EQU			0X40024528
GPIO_PORTE_PCTL		EQU			0X4002452C
ADCACTSS			EQU			0X40038000
ADCSSCTL3			EQU			0X400380A4
ADCEMUX				EQU			0X40038014
ADCSSMUX3			EQU			0X400380A0
ADCPC				EQU			0X40038FC4
;--------------------------------------------------------------------
			AREA 	routines, CODE, READONLY
			THUMB
			EXPORT  adc_init


adc_init	PROC
			PUSH	{R0,R1,LR}
			LDR		R1,=RCGCADC			; enable ADC0 clock 
			LDR		R0,[R1]
			ORR		R0,#0X01
			STR		R0,[R1]
			NOP
			NOP
			NOP							; to stabilize the clock 
			
			LDR		R1,=RCGCGPIO		; enable clock for port E 
			ORR		R0,#0X10
			STR		R0,[R1]
			NOP
			NOP
			NOP 						
			
			LDR		R1,=GPIO_PORTE_AFSEL		; enable alternate function 
			ORR		R0,#0X08
			STR		R0,[R1]
			
			LDR		R1,=GPIO_PORTE_DEN			; disable digital 
			LDR		R0,[R1]
			BIC		R0,R0,#0X08
			STR		R0,[R1]

			LDR		R1,=GPIO_PORTE_AMSEL		; enable analog 
			LDR		R0,[R1]
			ORR		R0,R0,#0X08
			STR		R0,[R1]
			
			LDR		R1,=ADCACTSS				; disable sequencer 3 for configuration 
			LDR		R0,[R1]
			BIC		R0,R0,#0X08
			STR		R0,[R1]
			
			LDR		R1,=ADCEMUX					; make sequencer 3 software triggered 
			LDR		R0,[R1]
			BIC		R0,R0,#0XF000
			STR		R0,[R1]
			
			LDR		R1,=ADCSSMUX3				; make input source as AIN0 (PE3) for sequencer 3 
			LDR		R0,[R1]
			BIC		R0,R0,#0X0F
			STR		R0,[R1]

			LDR		R1,=ADCSSCTL3				; enable IE0 and END0 for sequencer 3 (0110)
			LDR		R0,[R1]
			ORR		R0,R0,#0X06
			STR		R0,[R1]
								
			LDR		R1,=ADCPC					; set sample rate as 125 ksps
			LDR		R0,[R1]
			ORR		R0,R0,#0X01
			STR		R0,[R1]
	
			LDR		R1,=ADCACTSS				; enable sequencer 3 
			LDR		R0,[R1]
			ORR		R0,#0X08
			STR		R0,[R1]
			
			POP		{R0,R1,LR}
			BX		LR
			ENDP