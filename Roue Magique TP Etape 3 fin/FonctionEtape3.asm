;***************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8

;**************************************************************************
;  Fichier Vierge.asm
; Auteur : V.MAHOUT
; Date :  12/11/2013
;**************************************************************************

;***************IMPORT/EXPORT**********************************************
	EXPORT Change_LED
	EXPORT Change_Secteur
	EXPORT Start_Timer4
	EXPORT Arret_Timer4
	IMPORT DataSend
	IMPORT Run_Timer4
	IMPORT Stop_Timer4
;**************************************************************************



;***************CONSTANTES*************************************************

	include REG_UTILES.inc
	include Lumiere.asm
		

;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite
;**************************************************************************

nbrCC DCB 0

;**************************************************************************



;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************


Change_LED  PROC
		PUSH {R3,R5,R10}
		LDR R10,=GPIOBASEB+OffsetOutput	;R10 l'adresse du output
		MOV R5,#0x01<<10		;1 au 10 eme bit de R5
		LDR R3,[R10]
		EOR R3,R5
		STRH R3,[R10]			;1 au 10 eme bit du output
		LDR R10,=TIM1_SR
		MOV R5,#0x01<<1
		LDR R3,[R10]
		BIC R3,R5
		STRH R3,[R10]	
		POP {R3,R5,R10}
		BX LR
		ENDP
			
Start_Timer4  PROC		;Timer1 CC
		PUSH {R3,R4,R5,R6,R10,LR}
		LDR R10,=TIM1_CNT
		LDR R4,[R10]
		LDR R3,=Nbsecteurs
		UDIV R4,R4,R3
		LDR R10,=TIM4_ARR
		STR R4,[R10]
		LDR R10,=TIM1_CNT
		MOV R3,#0
		STR R3,[R10]
		LDR R10,=nbrCC
		LDRB R3,[R10]
		ADD R3,#1	
		STRB R3,[R10]
		CMP R3,#3	;si c'est le 3eme cc depuis le dernier up je lance timer 4
		BLT sautVit 
		BL Run_Timer4
sautVit	LDR R10,=TIM1_SR
		MOV R5,#0x01<<1
		LDR R3,[R10]
		BIC R3,R5
		STRH R3,[R10]	
		POP {R3,R4,R5,R6,R10,LR}
		BX LR
		ENDP

Arret_Timer4 PROC ;timer_up 1
		PUSH {R3,R5,R10,LR}
		BL Stop_Timer4
		LDR R10,=TIM1_SR
		MOV R5,#1
		LDR R3,[R10]
		BIC R3,R5
		STRH R3,[R10]
		POP {R3,R5,R10,LR}
		BX LR
		ENDP

Change_Secteur PROC	;timer 4 up
		PUSH {R3,R4,R5,R10,LR}
		LDR R10,=numSecteur
		LDR R5,=mire
		LDR R3,[R10]
		AND R3,#7
		MOV R4,#48
		MLA R5,R4,R3,R5
		PUSH {R5}
		BL DriverPile
		ADD SP,#4
		ADD R3,#1
		STR R3,[R10]
		LDR R10,=TIM4_SR
		MOV R5,#1
		LDR R3,[R10]
		BIC R3,R5
		STRH R3,[R10]
		POP {R3,R4,R5,R10,LR}
		BX LR
		ENDP

DriverPile  PROC  ;adresse de barrette en haut de la pile
		PUSH {R12} 
		MOV R12,SP	;R12 l'adresse du haut de la pile(en dessous de l'argument)
		PUSH {R0-R11,LR}
		LDR R3,[R12,#4]	;R3 l'adresse de barrette
		LDR R9,=DataSend
		MOV R0,#0x01<<5
		BL Set
		
		MOV R2,#0	;R2 compteur nbLed	
b13		LDRB R4,[R3],#1	;R4 valeur courante
		LSL R4,#24	
		
		MOV R6,#0	;R6 compteur nbBit
b23		MOV R0,#0x01<<5
		BL Reset	;reset sclk
		AND R7,R4,#0x01<<31
		CMP R7,#0x01<<31
		BEQ	setSin3
		BNE resetSin3
setSin3	MOV R0,#0x01<<7
		BL Set;set sin
		B saut3
resetSin3 MOV R0,#0x01<<7
		BL Reset;resetSin
saut3	LSL R4,#1
		MOV R0,#0x01<<5
		BL Set	;set sclk
		ADD R6,#1
		CMP R6,#12
		BNE b23
		ADD R2,#1
		CMP R2,#48
		BNE b13
		MOV R0,#0x01<<5
		BL Reset	;reset sclk
		MOV R10,#0
		STRH R10,[R9]
		
		POP {R0-R11,LR}
		POP {R12}
		BX LR
		ENDP


Set	PROC
		PUSH {R10}
		LDR R10,=GPIOBASEA+OffsetSet
		STRH R0,[R10]
		POP {R10}
		BX LR
		ENDP
		
Reset	PROC
		PUSH {R10}
		LDR R10,=GPIOBASEA+OffsetReset
		STRH R0,[R10]
		POP {R10}
		BX LR
		ENDP


;########################################################################
; Procédure ????
;########################################################################
;
; Paramètre entrant  : ???
; Paramètre sortant  : ???
; Variables globales : ???
; Registres modifiés : ???
;------------------------------------------------------------------------






;**************************************************************************
	END