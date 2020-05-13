		

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
	IMPORT Change_LED
	IMPORT Start_Timer4
	IMPORT Arret_Timer4
	IMPORT Change_Secteur
	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, align=9, readwrite

NouvTVI space 1024
OldEtat DCB 1




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
        ;LDR R2,=SCB_VTOR
		;LDR R1,[R2]
		MOV R1,#0
        MOV R3,#256
bTVI 	LDR R2,[R1],#4
        STR R2,[R0],#4
        SUBS R3,#1
        BNE bTVI
		
		LDR R0,=NouvTVI
		LDR R2,=SCB_VTOR
		STR R0,[R2]
		LDR R0,=NouvTVI+100+64
		LDR R1,=Arret_Timer4
		STR R1,[R0]
		ADD R0,#8
		LDR R1,=Start_Timer4
		STR R1,[R0]
		ADD R0,#12
		LDR R1,=Change_Secteur
		STR R1,[R0]
		
		
		BL Run_Timer1
		
		

sortie 	B sortie

 


		ENDP

	END

;*******************************************************************************
