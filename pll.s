SYSCTL_RCC			EQU 	0x400FE060 ; Run Mode Clock Configuration
SYSCTL_RIS 			EQU 	0x400FE050 ; Raw Interrupt Status 

					AREA 	clock, CODE, READONLY
					THUMB
					EXPORT	pll_init
					
	
pll_init			PROC 
					PUSH	{LR}
					LDR 	R1,=SYSCTL_RCC 
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
					BIC 	R0,R0,#0xB000000
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
					
					POP		{LR}
					BX 		LR 
					ENDP 
					