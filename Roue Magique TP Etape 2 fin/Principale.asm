		

;************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8
;************************************************************************

	include REG_UTILES.inc
	include Lumiere.asm
	

;************************************************************************
; 					IMPORT/EXPORT Système
;************************************************************************

	IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]




; IMPORT/EXPORT de procédure           

	IMPORT Init_Cible
	IMPORT DriverGlobal
	IMPORT Tempo
	IMPORT DriverReg
	IMPORT DriverPile
	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite

OldEtat DCB 1


;*******************************************************************************
	
	AREA  moncode, code, readonly
		


;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main  	PROC 
;*******************************************************************************

		
		MOV R0,#1
		BL Init_Cible;
		
		LDR R8,=GPIOBASEA+OffsetInput+0x01 ;R8 addresse capteur
		MOV R4,#4 ;R4=M compteur
while 	AND R5,R4,#1	;R5=1 si compteur impair
		CMP R5,#1	
		BEQ bar1
		BNE bar2
bar1	LDR R3,=Barrette1 ;quand R4 impair
		BL driv
bar2	LDR R3,=Barrette2 ;quand R4 pair
driv	PUSH {R3}		;on met l'adresse de la barrette dans la pile 
		BL DriverPile
		ADD SP,#4	;on deplace le debut de la pile en haut de R3
		LDRB R6,[R8] ;R6 valeur du capteur
		AND R6,#1	;R6 le premier bit du capteur  
		SUBS R4,#1	;si le compteur est a 0
		BEQ sortie
		CMP R6,#1	;si le capteur est a 1 (comparer avec 0 en reel)
		BEQ sortie
		MOV R0,#20
		BL Tempo
		BL while

sortie 	B sortie

 


		ENDP

	END

;*******************************************************************************
