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

	EXPORT DriverGlobal
	EXPORT Tempo
	EXPORT DriverReg
	EXPORT DriverPile
	IMPORT DataSend
;**************************************************************************



;***************CONSTANTES*************************************************

	include REG_UTILES.inc
	include Lumiere.asm
		

;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite
;**************************************************************************



;**************************************************************************



;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************

DriverGlobal  PROC
		PUSH {R0-R12}
		LDR R3,=Barrette1
		LDR R9,=DataSend
		MOV R0,#0x01<<5
		BL Set
		
		MOV R2,#1	;R2 compteur nbLed	
b1		LDRB R4,[R3],#1	;R4 valeur courante
		LSL R4,#24	
		
		MOV R6,#1	;R6 compteur nbBit
b2		MOV R0,#0x01<<5
		BL Reset	;reset sclk
		AND R7,R4,#0x01<<31
		CMP R7,#0x01<<31
		BEQ	setSin
		BNE resetSin
setSin	MOV R0,#0x01<<7
		BL Set;set sin
		B saut
resetSin MOV R0,#0x01<<7
		BL Reset;resetSin
saut	LSL R4,#1
		MOV R0,#0x01<<5
		BL Set	;set sclk
		ADD R6,#1
		CMP R6,#12
		BNE b2
		ADD R2,#1
		CMP R2,#48
		BNE b1
		MOV R10,#0
		STRH R10,[R9]
		
		POP {R0-R12}
		BX LR
		ENDP
			
DriverReg  PROC  ;R3 argument addresse de barrette
		PUSH {R0-R2,R4-R12,LR}
		LDR R9,=DataSend
		MOV R0,#0x01<<5
		BL Set
		
		MOV R2,#0	;R2 compteur nbLed	
b12		LDRB R4,[R3],#1	;R4 valeur courante
		LSL R4,#24	
		
		MOV R6,#0	;R6 compteur nbBit
b22		MOV R0,#0x01<<5
		BL Reset	;reset sclk
		AND R7,R4,#0x01<<31
		CMP R7,#0x01<<31
		BEQ	setSin2
		BNE resetSin2
setSin2	MOV R0,#0x01<<7
		BL Set;set sin
		B saut2
resetSin2 MOV R0,#0x01<<7
		BL Reset;resetSin
saut2	LSL R4,#1
		MOV R0,#0x01<<5
		BL Set	;set sclk
		ADD R6,#1
		CMP R6,#12
		BNE b22
		ADD R2,#1
		CMP R2,#48
		BNE b12
		MOV R10,#0
		STRH R10,[R9]
		
		POP {R0-R2,R4-R12,LR}
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

Tempo PROC
		PUSH {R1,R2}
		MOV R1,#10
		MUL R0,R1
btemp1	MOV R2,#503		
btemp2	NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		SUBS R2,#1
		BNE btemp2
		SUBS R0,#1
		BNE btemp1
		POP {R1,R2}
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