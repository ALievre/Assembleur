		

;************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8
;************************************************************************

	include REG_UTILES.inc


;************************************************************************
; 					IMPORT/EXPORT Système
;************************************************************************

	IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]




; IMPORT/EXPORT de procédure           

	IMPORT Init_Cible
	IMPORT Allume_LED
	IMPORT Eteint_LED
	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite

	


;*******************************************************************************
	
	AREA  moncode, code, readonly
		


;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main  	PROC 
;*******************************************************************************

		
		MOV R0,#0
		BL Init_Cible;
		LDR R8,=GPIOBASEA+OffsetInput+0x01 ;R8 addresse du capteur
boucle		LDRB R6,[R8]	;R6 la valeur du capteur
		AND R6,#1	;R6 le premier bit du capteur
		
		
		CMP R6,#1	
		BEQ allume	
		BL eteint

allume		BL Allume_LED;
		BL boucle
eteint		BL Eteint_LED			 ; boucle inifinie terminale...
		BL boucle

		ENDP

	END

;*******************************************************************************
