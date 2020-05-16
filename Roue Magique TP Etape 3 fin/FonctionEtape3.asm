;***************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8


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

nbrCC DCD 0	;variable stockant le nombre de cc depuis le dernier up

;**************************************************************************



;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************


Change_LED  PROC		;procedure changeant l'etat de la LED
		PUSH {R3,R5,R10}
		LDR R10,=GPIOBASEB+OffsetOutput	;R10 l'adresse du output
		MOV R5,#0x01<<10		;1 au 10 eme bit de R5
		LDR R3,[R10]
		EOR R3,R5		;ou exlusif pour changer l'etat du 10 eme bit du output
		STRH R3,[R10]	
		POP {R3,R5,R10}
		BX LR
		ENDP
			
Start_Timer4  PROC		;Timer1 CC
		PUSH {R3,R4,R10,LR}
		BL Change_LED ;on change l'etat de la led
		LDR R10,=TIM1_CNT		
		LDR R4,[R10]	;dans R4 la valeur du compteur timer1
		LSR R4,#PuissanceNbSecteur ;on shift a droite de n pour diviser par 2^n
		MOV R3,#0
		STR R3,[R10]	;on remet a 0 le compteur
		LDR R10,=TIM4_ARR	
		STR R4,[R10]	;on stocke la valeur du compteur divise par 2^n dans le reload du timer4
		LDR R10,=nbrCC
		LDR R3,[R10]	;dans R3 la valeur de nbrCC
		ADD R3,#1		;on l'augmente de 1
		STR R3,[R10]
		CMP R3,#3	;si c'est au moins le 3eme cc depuis le dernier up je lance timer 4
		BLT sautVit 
		BL Run_Timer4
sautVit	LDR R10,=TIM1_SR	
		LDR R3,[R10]
		BIC R3,#2
		STRH R3,[R10]	;on efface le bit d'acquitement de l'interruption
		POP {R3,R4,R10,LR}
		BX LR
		ENDP

Arret_Timer4 PROC ;timer_up 1
		PUSH {R3,R10,LR}
		LDR R10,=nbrCC
		MOV R3,#0
		STR R3,[R10] ;on remet a 0 nbrCC
		BL Stop_Timer4	;on stop le timer4 lorsque l'on deborde le timer1
		LDR R10,=TIM1_SR
		LDR R3,[R10]
		BIC R3,#1
		STRH R3,[R10] ;on efface le bit d'acquitement de l'interruption
		POP {R3,R10,LR}
		BX LR
		ENDP

Change_Secteur PROC	;timer 4 up
		PUSH {R3,R4,R5,R10,LR}
		LDR R10,=numSecteur	
		LDR R3,[R10]	;dans R3 le numero du secteur a afficher
		LDR R5,=mire	;dans R5 l'addresse du debut de la mire
		AND R3,#Nbsecteurs-1	;on met le numero du secteur modulo 2^n
		MOV R4,#48				;l'adresse de la barette a afficer est mire+numSecteur*48
		MLA R5,R4,R3,R5
		PUSH {R5}		;on met l'adresse en bas de la pile pour l'appel a DriverPile
		BL DriverPile	
		ADD SP,#4		;on deplace le debut de la pile en haut de l'argument donné a DriverPile
		ADD R3,#1		;on augmente de 1 le numero du secteur a afficher pour la prochaine fois
		STR R3,[R10]	
		LDR R10,=TIM4_SR	
		LDR R3,[R10]
		BIC R3,#1
		STRH R3,[R10]	;on efface le bit d'acquitement de l'interruption
		POP {R3,R4,R5,R10,LR}
		BX LR
		ENDP

DriverPile  PROC  ;adresse de barrette en haut de la pile
		PUSH {R12} 
		MOV R12,SP	;R12 l'adresse du bas de la pile(en dessous de l'argument)
		PUSH {R0-R4,LR}
		LDR R3,[R12,#4]	;R3 l'adresse de barrette (en R12+4 dans la pile)
		MOV R0,#0x01<<5	;
		BL Set	;set sclk
		
		MOV R1,#48	;R1 compteur nbLed	
b1		LDRB R4,[R3],#1	;R4 valeur courante
		LSL R4,#24	
		MOV R2,#12	;R2 compteur nbBit
b2		MOV R0,#0x01<<5
		BL Reset	;reset sclk
		LSLS R4,#1	;si le bit tout a gauche de R4 est a 1 le shift mettra le fanion c a 1
		BCC resetSin	;en decalant on passera aussi au prochain bit pour la prochaine iteration
		MOV R0,#0x01<<7
		BL Set;set sin (si bit a 1)
		B sautIF
resetSin MOV R0,#0x01<<7
		BL Reset;resetSin (si bit a 0)
sautIF	MOV R0,#0x01<<5
		BL Set	;set sclk
		SUBS R2,#1
		BNE b2
		SUBS R1,#1
		BNE b1
		MOV R0,#0x01<<5
		BL Reset	;reset sclk
		LDR R12,=DataSend
		MOV R3,#0
		STRH R0,[R12]	;on envoie 0 a l'adresse du datasend pour indiquer que des nouvelles données ont ete transmise
		
		POP {R0-R4,LR}
		POP {R12}	;les pops se font dans l'ordre inverse que les pushs
		BX LR
		ENDP


Set	PROC		;procedure pour set (avec les bits a set dans R0)
		PUSH {R10}
		LDR R10,=GPIOBASEA+OffsetSet
		STRH R0,[R10]
		POP {R10}
		BX LR
		ENDP
		
Reset	PROC	;procedure pour reset
		PUSH {R10}
		LDR R10,=GPIOBASEA+OffsetReset
		STRH R0,[R10]
		POP {R10}
		BX LR
		ENDP



	END