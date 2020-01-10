NVIC_EN0_INT19		EQU 0x00080000 ; Interrupt 19 enable
NVIC_EN0			EQU 0xE000E100 ; IRQ 0 to 31 Set Enable Register
NVIC_PRI4			EQU 0xE000E410 ; IRQ 16 to 19 Priority Register
	
TIMER0_CFG			EQU 0x40030000 ; Timer Configuration Register
TIMER0_TAMR			EQU 0x40030004 ; Timer A Mode Register
TIMER0_CTL			EQU 0x4003000C ; Timer Control Register 
TIMER0_IMR			EQU 0x40030018 ; Timer Interrupt Mask Register
TIMER0_RIS			EQU 0x4003001C ; Timer Raw Interrupt Status Register
TIMER0_ICR			EQU 0x40030024 ; Timer Interrupt Clear Register
TIMER0_TAILR		EQU 0x40030028 ; Timer A Interval Load Register
TIMER0_TAPR			EQU 0x40030038 ; Timer A Prescale Register 
TIMER0_TAR			EQU	0x40030048 ; Timer A Register Register
	
SYSCTL_RCGCTIMER 	EQU 0x400FE604 ; Timer Clock
ADC0_ACTSS			EQU 0x40038000 
	
					AREA 	routines, CODE, READONLY
					THUMB
					EXPORT 	My_Timer0A_Handler
					EXPORT	timer_init 
					EXTERN 	__main 
					EXTERN 	serial
	
; configure Timer0A to get timeout interrupts after 2.5 sec and disable the SS3 in the Handler to adjust the recording interval 
My_Timer0A_Handler  PROC 
					LDR R1,=ADC0_ACTSS
					LDR R0,[R1]
					BIC R0,R0,#0x08 ; clear bit 3 to disable SS3
					STR R0,[R1]		
					B 	serial 
					ENDP 
						
timer_init 			PROC 
					PUSH {R1,R2}
					LDR R1,=SYSCTL_RCGCTIMER 
					LDR R2,[R1]
					ORR R2,R2,#0x01 ; start Timer0
					STR R2,[R1]
					NOP 
					NOP
					NOP ; to stabilize the clock
					
					LDR R1,=TIMER0_CTL 
					LDR R2,[R1]
					BIC R2,R2,#0x01 ; disable timer during setup 
					STR R2,[R1]
					
					LDR R1,=TIMER0_CFG 
					MOV R2,#0x04 ; set 16 bit mode
					STR R2,[R1]
					
					LDR R1,=TIMER0_TAMR
					MOV R2,#0x01 ; set to one-shot, count down
					STR R2,[R1]
					
					LDR R1,=TIMER0_TAILR 
					MOV R2,#0x2 ;625A0 ; load this value to get timeout interrupt after 2.5 sec 
					STR R2,[R1]
					
					LDR R1,=TIMER0_TAPR
					MOV R2,#19 ; divide clock by 20 to get 1us clocks
					STR R2,[R1] 
					
					LDR R1,=TIMER0_IMR 
					MOV R2,#0x01 ; enable timeout interrupt
					STR R2,[R1]

; Configure interrupt priority, Timer0A is interrupt #19, set NVIC interrupt 19 to priority 2
					LDR R1,=NVIC_PRI4
					LDR R2,[R1]
					AND R2,R2,#0x00FFFFFF ; clear interrupt 19 priority
					ORR R2,R2,#0x40000000 ; set interrupt 19 priority to 2
					STR R2,[R1]
					LDR R1,=NVIC_EN0
					MOVT R2,#0x08 ; set bit 19 to enable interrupt 19 in NVIC 
					STR R2,[R1]
					
					LDR R1,=TIMER0_CTL
					LDR R2,[R1]
					ORR R2,R2,#0x03 ; set bit0 to enable timer and bit 1 to stall on debug 
					STR R2,[R1] 
					POP {R1,R2}
					BX  LR 
					ENDP
					END