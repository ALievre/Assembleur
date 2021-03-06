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





;########################################################################
; Proc�dure ????
;########################################################################
;
; Param�tre entrant  : ???
; Param�tre sortant  : ???
; Variables globales : ???
; Registres modifi�s : ???
;------------------------------------------------------------------------






;**************************************************************************
	END