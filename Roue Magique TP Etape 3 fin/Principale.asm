		

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
	IMPORT Run_Timer1
	IMPORT Start_Timer4
	IMPORT Arret_Timer4
	IMPORT Change_Secteur
	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, align=9, readwrite

NouvTVI space 1024




;*******************************************************************************
	
	AREA  moncode, code, readonly
		


;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main  	PROC 
;*******************************************************************************

		
		MOV R0,#2
		BL Init_Cible
		
		LDR R0,=NouvTVI
		MOV R1,#0 ;l'adresse de l'ancienne TVI est 0
        MOV R3,#256	;on copiera 256*4 octets
bTVI 	LDR R2,[R1],#4 	;on lit l'ancienne TVI
        STR R2,[R0],#4	;on recopie dans la nouvelle 
        SUBS R3,#1
        BNE bTVI
		
		LDR R0,=NouvTVI
		LDR R2,=SCB_VTOR
		STR R0,[R2]	;on change l'adresse de la TVI 
		LDR R0,=NouvTVI+100+64	;l'interruption Timer1_CC est la 25 interruption (16*4+25*4)
		LDR R1,=Arret_Timer4
		STR R1,[R0]
		ADD R0,#8	;l'interruption Timer1_up est la 27 eme donc 8 octets plus loin
		LDR R1,=Start_Timer4
		STR R1,[R0]
		ADD R0,#12	;l'interrutpion Timer4_up est la 30 eme donc 12 octets plus loin
		LDR R1,=Change_Secteur
		STR R1,[R0]
		
		
		BL Run_Timer1
		
		

sortie 	B sortie

 


		ENDP

	END

;*******************************************************************************
