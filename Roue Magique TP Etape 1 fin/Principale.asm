		

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

OldEtat DCB 1


;*******************************************************************************
	
	AREA  moncode, code, readonly
		


;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main  	PROC 
;*******************************************************************************

		
		MOV R0,#0
		BL Init_Cible;
		LDR R8,=GPIOBASEA+OffsetInput+0x01 	;R8 adresse du capteur
		LDR R9,=GPIOBASEB+OffsetOutput		;R9 adresse du output
		
		LDR R2,=OldEtat ;R2 l'adresse de Oldetat
		LDR R6,=OldEtat
		MOV R4,#2		;on initialise le compteur a 2
		
boucle	STRB R6,[R2]		;memorise l'ancien etat dans R2
		LDRB R6,[R8]	;R6 le nouvel etat du capteur
		AND R6,#1	;R6 le premier bit du capteur
		LDRB R5,[R2] ;on met l'ancien etat dans R5 pour comparer
					;pour un front montant on cherche ancien etat a 0 et nouvel etat a 1
		CMP R5,#0	;compare ancien etat avec 0
		BNE boucle
		CMP R6,#1 	;compare nouvel etat avec 1
		BNE boucle
		
		LDR R3,[R9]	;on recupere l'etat actuel de la LED
		AND R3,#0x01<<10	;on garde seulement le 10 eme bit
		SUBS R4,#1			;on reduit le compteur de 1
		BEQ allume			;si le compteur est a 0 on allume la LED
		
		CMP R3,#0x01<<10	;on regarde si la LED est allume ou eteinte
		BEQ eteint	
		BNE allume

allume		BL Allume_LED;
		CMP R4,#0	;si le compteur est a 0 on sort
		BEQ sortie
		BL boucle
eteint		BL Eteint_LED			 
		BL boucle

sortie 	B sortie

 


		ENDP

	END

;*******************************************************************************
