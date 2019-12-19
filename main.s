SYSCTL_RCC			EQU 	0x400FE060	
SYSCTL_RIS 			EQU 	0x400FE050	
					
					
					AREA 	main, CODE, READONLY
					THUMB
					EXPORT	__main
					EXTERN 	init 
						
__main 				LDR 	R1,=SYSCTL_RCC 
					LDR 	R0,[R1] 
					ORR 	R0,R0,#0x800 ; set the BYPASS bit 
					BIC 	R0,R0,#0x400000 ; clear the USESYS bit 
					STR 	R0,[R1] 
					
					LDR 	R1,=SYSCTL_RCC 
					LDR 	R0,[R1] 
					ORR 	R0,R0,#0x4800000 ; set SYSDIV to 0x9 for 20 MHz frequency 
					ORR 	R0,R0,#0x400000 ; set the USESYS bit 
					STR 	R0,[R1] 
					
check				LDR 	R1,=SYSCTL_RIS 
					LDR 	R0,[R1] 
					ANDS 	R0,R0,#0x40 ; poll the PLLLRIS bit 
					BEQ 	check ; if PLLLRIS is not set, poll RIS register until PLL is locked 
					
					LDR 	R1,=SYSCTL_RCC 
					LDR 	R0,[R1] 
					BIC 	R0,R0,#0x800 ; clear the BYPASS bit 
					
					BL 		init 
					
					