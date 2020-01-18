GPIO_PORTF_DATA		EQU		    0x400253FC ; Data				
			
					AREA    	main, READONLY, CODE
					THUMB
		
					EXTERN		init_all
					EXTERN		read_mic
					EXTERN		push_button_check
					EXTERN 		push_button_check_2 
					EXTERN		read_pot
					EXTERN		dac_write
					EXPORT  	__main
				

__main
					BL			init_all
main_loop			LDR 		R1,=GPIO_PORTF_DATA
					MOV 		R0,#4 
					STR 		R0,[R1] ; turn on the blue LED when the system is in idle state 
					BL			push_button_check
					BL			read_pot
					BL			read_mic
					LDR 		R1,=GPIO_PORTF_DATA
					MOV 		R0,#4 
					STR 		R0,[R1] ; turn on the blue LED when the system is in idle state 
					BL 			push_button_check_2
					BL			dac_write 
					B			main_loop
					ALIGN
					END