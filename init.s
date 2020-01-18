			AREA 	routines, CODE, READONLY
			THUMB
			EXPORT 	init_all
			EXTERN  push_button_init
			EXTERN	mic_init
			EXTERN  delay_init
			EXTERN	adc_init
			EXTERN	pll_init
			EXTERN	dac_init	
				
				
init_all	PROC
			PUSH	{LR}
			BL		pll_init
			BL		delay_init
			BL		adc_init
			BL		push_button_init
			BL		dac_init
			POP		{LR}
			BX		LR
			ENDP				
;--------------------------------------------------------------------
		END