.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

includelib msvcrt.lib
extern exit: proc
extern printf: proc
extern scanf: proc
extern fopen: proc
extern fclose: proc
extern fscanf: proc
extern fprintf: proc
extern strcmp: proc
extern fputs: proc
extern gets: proc
extern strcpy: proc

            ;  >> CERINTA <<
  ;Sa se realizeze functii pentru operatii cu matrici patratice (de dimensiune maxima 10x10). Operatiile
;cerute sunt: A+B (adunare), aA (inmultire cu scalar), A-B (scadere). Sa se realizeze un
;program demonstrativ pentru operatii cu matrici, utilizand aceste functii. Utilizatorului i se va cere sa
;furnizeze de la tastatura o expresie cu matrici asemanatoare cu expresiile de mai sus. Programul va
;interpreta expresia si va cere calea inspre fisierul sau fisierele in care se gasesc matricile. Se va calcula
;rezultatul, care va fi scris intr-un fisier cu denumirea rezultat.txt.

;Exemplu :
;> Introduceti o operatie cu matrici:
;> A+B
;> A=
;> a.txt
;> B=
;> b.txt
;> Rezultat: rezultat.txt

.data

mesaj db "Introduceti o operatie cu matrici:" , 10, ">>> " ,0    ;; 10-inseamna linie noua
mesajCitireA db "Introduceti calea catre matricea A:" , 10, ">>> " ,0
mesajCitireB db "Introduceti calea catre matricea B:" , 10, ">>> " ,0
mesajCitireScalar db "Introduceti un scalar:", 10, ">>> ", 0

mesajEroare db "Matricile sunt de dimensiuni diferite!", 10, 0
mesajEroare2 db "Dimensiunile matricelor trebuie sa fie intre 1 si 10!", 10, 0

mesajInmulScal db "Rezultatul inmultirii cu scalar: ", 10, 0
mesajAdunare db "Rezultatul adunarii matricelor: ", 10, 0
mesajScadere db "Rezultatul scaderii matricelor: ", 10, 0
mesajInmulMat db "Rezultatul inmultirii matricelor: ", 10, 0

unu dd 1
patru dd 4

spatiu db " ", 0
linieNoua db 10, 0

mode_read_fis db "r",0
mode_write_fis db "w", 0
decimal db "%d",0
sir db "%s", 0

descriptor_a dd 0
descriptor_b dd 0
descriptor_rez dd 0

adunare db "A+B",0
scadere db "A-B", 0
inmultireMat db "A*B", 0
inmultireScalA db "aA", 0
inmultireScalB db "aB", 0


operatieCitita db 20 DUP(0)
caleA db 100 DUP(0)
caleB db 100 DUP(0)

caleRezultat db "E:\Faculta\An I\PLA\Proiect_PLA\rezultat.txt", 0


scalar dd 0
dimMatA dd 0
dimMatB dd 0
curentA dd 0
curentB dd 0
curentRez dd 0
elemcurent dd 0

sirA dd 101 DUP(0)   ;elementele matricei A puse in sir pt realizarea inmultirii cu matricea B
sirB dd 101 DUP(0)   ;------||----------- B  -------------------||--------------------------A

.code
 
  ;-FUNCTIE ELIMINARE SPATII A UNUI SIR CITIT-;
  
eliminare_spatii proc
 push EBP
 mov EBP, ESP
 ;sub ESP, 4*1
 
 mov edi,0
 
		inceput:
		 cmp operatieCitita[edi], 0
		 je sir_fara_spatii
		
		cmp operatieCitita[edi],' '
		jne continuare
		
		eliminare_spatiu:
		lea ebx, operatieCitita[edi]
		lea ecx, operatieCitita[edi+1]
		push ecx
		push ebx
		call strcpy
		add esp, 4*2
		jmp inceput
		
		continuare:
		add edi,1
		jmp inceput
		
		sir_fara_spatii:
		
 mov ESP, EBP
 pop EBP
 ret 
 
eliminare_spatii endp  ;;SFARSIT FUNCTIE

start:

			; CITIRE OPERATIE
			
			; afisare mesaj
			push offset mesaj
			call printf
			add esp, 4*1
			
			; citire operatie
			push offset operatieCitita
			call gets
			add esp, 4*1
			
		 ;;;ELIMINARE SPATII DIN SIRUL CITIT
			call eliminare_spatii
		
			
			 ;afisare pe ecran a operatiei citite, insa fara spatii
			push offset operatieCitita
			push offset sir
			call printf
			add esp, 4*2
			
			push offset linieNoua
			call printf
			add esp, 4*1

	
	;-------------------------------------------------------------------------------------------------------------------------------------------;
   ;------------------------------------------------------------------------------------------------------------------------------------------;
   
			
    ; COMPARARE OPERATIE CITITA
    
    adunareOp:
    
			push offset adunare
			push offset operatieCitita
			call strcmp
			add esp, 4*2
			
			cmp eax, 0
			jne scadereOp
			
			; citire cale matrice A
			
			push offset mesajCitireA
			call printf
			add esp, 4*1
			
			push offset caleA
			push offset sir
			call scanf
			add esp, 4*2
			
			; citire cale matrice B
			
			push offset mesajCitireB
			call printf
			add esp, 4*1
			
			push offset caleB
			push offset sir
			call scanf
			add esp, 4*2
			
			; deschidere fisier A
			
			push offset mode_read_fis
			push offset caleA
			call fopen
			add esp, 4*2
			mov [descriptor_a], eax ;;retine adresa de inceput a fisierului in care se gaseste matricea A
			
			; deschidere fisier B
			
			push offset mode_read_fis
			push offset caleB
			call fopen
			add esp, 4*2
			mov [descriptor_b], eax  ;;retine adresa de inceput a fisierului B
			
			; citire dimensiune matrice A
			
			push offset dimMatA
			push offset decimal
			push dword ptr[descriptor_a]
			call fscanf
			add esp, 4*3
			
			; citire dimensiune matrice B
			
			push offset dimMatB
			push offset decimal
			push dword ptr[descriptor_b]
			call fscanf
			add esp, 4*3
			
			; comparare dimensiuni matrice si mesaj de eroare in caz de neegalitate
			
			mov eax, dimMatA
			mov ebx, dimMatB
			cmp eax, ebx
			jne eroare1
			
			
			 ;;verificare daca matricele au dimensiune cuprinsa intre 1 si 10
				
			cmp eax, 1
			jl eroare2
			cmp eax, 10
			jg eroare2
			
			cmp ebx, 1
			jl eroare2
			cmp ebx, 10
			jg eroare2
			
			
			
			;;;daca se respecta toate conditiile, matricele avand dimensiune corecta, trecem la realizarea operatiei cerute
			
		adunareInstructiuni:
			
			; deschidere fisier rezultat
			 
			push offset mode_write_fis
			push offset caleRezultat
			call fopen
			add esp, 4*2
			mov [descriptor_rez], eax
			
			;mesaj in fisier cu operatia realizata
			push offset mesajAdunare 
			push descriptor_rez
            call fprintf
            add esp, 4*3
			
			push descriptor_rez
			push offset linieNoua
			call fputs
			add esp, 4*2
			
			; adunare propriu-zisa
			
			mov eax, dimMatA 
			mul dimMatA
			mov edi, eax    ;;edi-retine numarul de elemente din matrice (dim^2)
			
        eticheta1 :
			
			dec edi 
			
			;;;citim direct matricele din fisiere, le adunam si punem rezultatul obtinut in fisier
            ; citire element curent A
            
            push offset curentA
            push offset decimal
            push descriptor_a
            call fscanf
            add esp, 4*3
			
			;;;;TEST currentRez
			push curentA
			push offset decimal
			call printf
			add esp,4*2
			
			push offset spatiu
			call printf
			add esp, 4
            
            
            ; citire element curent B
            
            push offset curentB
            push offset decimal
            push descriptor_b
            call fscanf
            add esp, 4*3
			
			;;;;TEST currentRez
			push curentB
			push offset decimal
			call printf
			add esp,4*2
			
			push offset spatiu
			call printf
			add esp, 4
            
            ; calcul suma si scriere in fisier
            
            mov eax, curentA
            add eax, curentB
            mov curentRez, eax
            
            push curentRez 
			push offset decimal
			push descriptor_rez
            call fprintf
            add esp, 4*3
			
			
			;TEST currentRez
			push curentRez
			push offset decimal
			call printf
			add esp,4*2
			
			push offset spatiu
			call printf
			add esp, 4
			
			;;daca am ajuns la sfarsit de linie, trecem pe o noua linie, iar daca nu, punem spatiu
			
			mov eax, edi
			mov edx, 0
			div dimMatA
			
			cmp edx, 0
			jnz afisSpatiu1
			
			push descriptor_rez
			push offset linieNoua
			call fputs
			add esp, 4*2
			
			jmp sfarsitBucla1
			
		afisSpatiu1:
			
			push descriptor_rez
			push offset spatiu
			call fputs
			add esp, 4*2
			
		sfarsitBucla1:
			
			cmp edi, 0
			jne eticheta1
			
        jmp iesireProgram
		
        
     ;-------------------------------------------------------------------------------------------------------------------------------------------;
     ;------------------------------------------------------------------------------------------------------------------------------------------;	
		
    ; SCADERE MATRICE ;
   
   scadereOp:
    
			push offset scadere
			push offset operatieCitita
			call strcmp
			add esp, 4*2
			
			cmp eax, 0
			jne inmultireMatOp
			
			; citire cale A
			
			push offset mesajCitireA
			call printf
			add esp, 4*1
			
			push offset caleA
			push offset sir
			call scanf
			add esp, 4*2
			
			; citire cale B
			
			push offset mesajCitireB
			call printf
			add esp, 4*1
			
			push offset caleB
			push offset sir
			call scanf
			add esp, 4*2
			
			; deschidere fisier A
			
			push offset mode_read_fis
			push offset caleA
			call fopen
			add esp, 4*2
			mov [descriptor_a], eax ;;retine adresa de inceput a fisierului 
			                         ;in care se gaseste matricea A
			
			; deschidere fisier B
			
			push offset mode_read_fis
			push offset caleB
			call fopen
			add esp, 4*2
			mov [descriptor_b], eax  ;;retine adresa de inceput a fisierului B
			
			; citire dimensiune matrice A
			
			push offset dimMatA
			push offset decimal
			push dword ptr[descriptor_a]
			call fscanf
			add esp, 4*3
			
			; citire dimensiune matrice B
			
			push offset dimMatB
			push offset decimal
			push dword ptr[descriptor_b]
			call fscanf
			add esp, 4*3
			
		   ; comparare dimensiuni matrice si mesaj de eroare in caz de neegalitate
			
			mov eax, dimMatA
			mov ebx, dimMatB
			cmp eax, ebx
			jne eroare1
			
			
			 ;;verificare daca matricele au dimensiune cuprinsa intre 1 si 10
			
			cmp eax, 1
			jl eroare2
			cmp eax, 10
			jg eroare2
			
			cmp ebx, 1
			jl eroare2
			cmp ebx, 10
			jg eroare2
			
		  ; daca se respecta toate conditiile, matricele avand dimensiune corecta, 
		   ;           trecem la realizarea operatiei cerute
			
	scadereInstructiuni:
			
			; deschidere fisier rezultat
			 
			push offset mode_write_fis
			push offset caleRezultat
			call fopen
			add esp, 4*2
			mov [descriptor_rez], eax
			
			;mesaj in fisier cu operatia realizata
			push offset mesajScadere
			push descriptor_rez
            call fprintf
            add esp, 4*3
			
			push descriptor_rez
			push offset linieNoua
			call fputs
			add esp, 4*2
			
			; scadere propriu-zisa
			
			mov eax, dimMatA 
			mul dimMatA
			mov edi, eax    ;;edi-retine numarul de elemente din matrice (dim^2)
        
        eticheta2 :
			
			dec edi 
			
			;;;citim direct matricele din fisiere, le scadem si punem rezultatul obtinut in fisier
            ; citire element curent A
            
            push offset curentA
            push offset decimal
            push descriptor_a
            call fscanf
            add esp, 4*3
			
			;;;;TEST currentRez
			push curentA
			push offset decimal
			call printf
			add esp,4*2
			
			push offset spatiu
			call printf
			add esp, 4
            
            
            ; citire element curent B
            
            push offset curentB
            push offset decimal
            push descriptor_b
            call fscanf
            add esp, 4*3
			
			;;;;TEST currentRez
			push curentB
			push offset decimal
			call printf
			add esp,4*2
			
			push offset spatiu
			call printf
			add esp, 4
            
            ; calcul scadere si scriere in fisier a rezultatului
            
            mov eax, curentA
            sub eax, curentB
            mov curentRez, eax
            
            push curentRez 
			push offset decimal
			push descriptor_rez
            call fprintf
            add esp, 4*3
			
			
			;TEST currentRez
			push curentRez
			push offset decimal
			call printf
			add esp,4*2
			
			push offset spatiu
			call printf
			add esp, 4
			
			;;daca am ajuns la sfarsit de linie, trecem pe o noua linie, 
				; iar daca nu, punem spatiu
			
			mov eax, edi
			mov edx, 0
			div dimMatA
			
			cmp edx, 0
			jnz afisSpatiu2
			
			push descriptor_rez
			push offset linieNoua
			call fputs
			add esp, 4*2
			
			jmp sfarsitBucla2
			
		afisSpatiu2:
			
			push descriptor_rez
			push offset spatiu
			call fputs
			add esp, 4*2
			
		sfarsitBucla2:
			
			cmp edi, 0
			jne eticheta2
			
			
        jmp inchidereFisiere
		
		
    
    ;-------------------------------------------------------------------------------------------------------------------------------------------;
   ;------------------------------------------------------------------------------------------------------------------------------------------;
   
   ; INMULTIREA MATRICELOR ;
   
    inmultireMatOp:
        
			push offset inmultireMat
			push offset operatieCitita
			call strcmp
			add esp, 4*2
			
			cmp eax, 0
			jne inmultireScalOp
			
			; citire cale A
			
			push offset mesajCitireA
			call printf
			add esp, 4*1
			
			push offset caleA
			push offset sir
			call scanf
			add esp, 4*2
			
			; citire cale B
			
			push offset mesajCitireB
			call printf
			add esp, 4*1
			
			push offset caleB
			push offset sir
			call scanf
			add esp, 4*2
			
			
			; => deschidere fisiere
			
			; deschidere fisier A
			
			push offset mode_read_fis
			push offset caleA
			call fopen
			add esp, 4*2
			mov [descriptor_a], eax ;;retine adresa de inceput a fisierului in care se gaseste matricea A
			
			; deschidere fisier B
			
			push offset mode_read_fis
			push offset caleB
			call fopen
			add esp, 4*2
			mov [descriptor_b], eax  ;;retine adresa de inceput a fisierului B
			
			; citire dimensiune matrice A
			
			push offset dimMatA
			push offset decimal
			push dword ptr[descriptor_a]
			call fscanf
			add esp, 4*3
			
			; citire dimensiune matrice B
			
			push offset dimMatB
			push offset decimal
			push dword ptr[descriptor_b]
			call fscanf
			add esp, 4*3
			
		   ; comparare dimensiuni matrice si mesaj de eroare in caz de neegalitate
			
			mov eax, dimMatA
			mov ebx, dimMatB
			cmp eax, ebx
			jne eroare1
			
			
			 ;;verificare daca matricele au dimensiune cuprinsa intre 1 si 10
			
			cmp eax, 1
			jl eroare2
			cmp eax, 10
			jg eroare2
			
			cmp ebx, 1
			jl eroare2
			cmp ebx, 10
			jg eroare2
			
			
			;;;daca se respecta toate conditiile, matricele avand dimensiune corecta,
				;le punem in siruri
			mov esi, 0
			
			mov eax, dimMatA 
			mul dimMatA
			mov edi, eax    ;;edi-retine numarul de elemente din matrice (dim^2)
			
			
			;;;citim matricele din fisiere si le punem in siruri 
        eticheta3 :
			
			dec edi
			
            ; citire element curent A
            
            push offset curentA
            push offset decimal
            push descriptor_a
            call fscanf
            add esp, 4*3
			
			mov ebx, curentA
			mov sirA[esi], ebx

            
            ; citire element curent B
            
            push offset curentB
            push offset decimal
            push descriptor_b
            call fscanf
            add esp, 4*3
			
			mov ebx, curentB
			mov sirB[esi], ebx
			
			inc esi
			
			cmp edi, 0
			jne eticheta3

			
			; deschidere fisier rezultat
         
			push offset mode_write_fis
			push offset caleRezultat
			call fopen
			add esp, 4*2
			mov [descriptor_rez], eax
			
			;mesaj in fisier cu operatia realizata
			push offset mesajInmulMat 
			push descriptor_rez
            call fprintf
            add esp, 4*3
			
			push descriptor_rez
			push offset linieNoua
			call fputs
			add esp, 4*2
				
            ; calcul inmultire si scriere in fisier a rezultatului--
			
			
			;;lipsaaaaaaaaaaaaaa 
			
			
        jmp inchidereFisiere
		
		
		
   ;-------------------------------------------------------------------------------------------------------------------------------------------;
   ;------------------------------------------------------------------------------------------------------------------------------------------;
		
		
	; INMULTIRE MATRICE CU UN SCALAR ;	
        
    inmultireScalOp:
        
			push offset inmultireScalA
			push offset operatieCitita
			call strcmp
			add esp, 4*2
			
			cmp eax, 0
			jne inmultireScalMatB
			
			
			; citire cale A
			
			push offset mesajCitireA
			call printf
			add esp, 4*1
			
			push offset caleA
			push offset sir
			call scanf
			add esp, 4*2
			
			
			; citire scalar
		  
			push offset mesajCitireScalar
			call printf
			add esp, 4*1
			
			push offset scalar
			push offset decimal
			call scanf
			add esp, 4*2
			
			 ; deschidere fisier A
			
			push offset mode_read_fis
			push offset caleA
			call fopen
			add esp, 4*2
			mov [descriptor_a], eax ;;retine adresa de inceput a fisierului 
									; in care se gaseste matricea A
			
			
			 ; citire dimensiune matrice A
			
			push offset dimMatA
			push offset decimal
			push dword ptr[descriptor_a]
			call fscanf
			add esp, 4*3
		  
			
			 ;;verificare daca matricea are dimensiune cuprinsa intre 1 si 10 
			 
			mov eax, dimMatA
				
			cmp eax, 1
			jl eroare2
			cmp eax, 10
			jg eroare2
			
			;;;daca se respecta toate conditiile, matricea avand dimensiune corecta, 
				; trecem la realizarea operatiei cerute
			
		inmultireScalInstructiuni:
			
			; deschidere fisier rezultat
			 
			push offset mode_write_fis
			push offset caleRezultat
			call fopen
			add esp, 4*2
			mov [descriptor_rez], eax
			
			;mesaj in fisier cu operatia realizata
			push offset mesajInmulScal 
			push descriptor_rez
            call fprintf
            add esp, 4*3
			
			push descriptor_rez
			push offset linieNoua
			call fputs
			add esp, 4*2
			
			; inmultire propriu-zisa
			
			mov eax, dimMatA 
			mul dimMatA
			mov edi, eax    ;;edi-retine numarul de elemente din matrice (dim^2)
        
        eticheta4 :
			
			dec edi 
			
			;;;citim direct matricea din fisier, inmultim cu scalarul 
			;si punem rezultatul obtinut in fisier rezultat.txt
			
            ; citire element curent A
            
            push offset curentA
            push offset decimal
            push descriptor_a
            call fscanf
            add esp, 4*3
			
			;;;;TEST currentRez
			push curentA
			push offset decimal
			call printf
			add esp,4*2
			
			push offset spatiu
			call printf
			add esp, 4
            
            
            ; calcul inmultire cu scalar si scriere in fisier a rezultatului
            
            mov eax, curentA
            mul scalar
            mov curentRez, eax
            
            push curentRez 
			push offset decimal
			push descriptor_rez
            call fprintf
            add esp, 4*3
			
			
			;TEST currentRez
			push curentRez
			push offset decimal
			call printf
			add esp,4*2
			
			push offset spatiu
			call printf
			add esp, 4
			
			;;daca am ajuns la sfarsit de linie, trecem pe o noua linie, iar daca nu, punem spatiu
			
			mov eax, edi
			mov edx, 0
			div dimMatA
			
			cmp edx, 0
			jnz afisSpatiu4
			
			push descriptor_rez
			push offset linieNoua
			call fputs
			add esp, 4*2
			
			jmp sfarsitBucla4
			
		afisSpatiu4:
			
			push descriptor_rez
			push offset spatiu
			call fputs
			add esp, 4*2
			
		sfarsitBucla4:
			
			cmp edi, 0
			jne eticheta4
			
		   ; inchidere fisier rezultat
			
			push dword ptr[descriptor_rez]
			call fclose
			add esp, 4*1 		
		
			; inchidere fisier A
			
			push dword ptr[descriptor_a]
			call fclose
			add esp, 4*1 
			
			jmp iesireProgram
			
			
		
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			; in caz ca operatia citita e "aB"  ;
			
	inmultireScalMatB:
			
			push offset inmultireScalB
			push offset operatieCitita
			call strcmp
			add esp, 4*2
			
			cmp eax, 0
			jne iesireProgram
			
			; citire cale B
			
			push offset mesajCitireB
			call printf
			add esp, 4*1
			
			push offset caleB
			push offset sir
			call scanf
			add esp, 4*2
			
			; citire scalar
      
			push offset mesajCitireScalar
			call printf
			add esp, 4*1
			
			push offset scalar
			push offset decimal
			call scanf
			add esp, 4*2
			
			 ; deschidere fisier B
			
			push offset mode_read_fis
			push offset caleB
			call fopen
			add esp, 4*2
			mov [descriptor_b], eax ;;retine adresa de inceput a fisierului in care se gaseste matricea B
			
			
			 ; citire dimensiune matrice B
			
			push offset dimMatB
			push offset decimal
			push dword ptr[descriptor_b]
			call fscanf
			add esp, 4*3
		  
			
			 ;;verificare daca matricea are dimensiune cuprinsa intre 1 si 10 
			 
			mov eax, dimMatB
				
			cmp eax, 1
			jl eroare2
			cmp eax, 10
			jg eroare2
			
			;;;daca se respecta toate conditiile, matricea avand 
			;dimensiune corecta, trecem la realizarea operatiei cerute
			
	  inmultireScalInstructiuni2:
			
			; deschidere fisier rezultat
			 
			push offset mode_write_fis
			push offset caleRezultat
			call fopen
			add esp, 4*2
			mov [descriptor_rez], eax
			
			;mesaj in fisier cu operatia realizata
			push offset mesajInmulScal 
			push descriptor_rez
            call fprintf
            add esp, 4*3
			
			push descriptor_rez
			push offset linieNoua
			call fputs
			add esp, 4*2
			
		
			; inmultire propriu-zisa
			
			mov eax, dimMatB 
			mul dimMatB
			mov edi, eax    ;;edi-retine numarul de elemente din matrice (dim^2)
			
        eticheta5 :
			
			dec edi 
			
			;;;citim direct matricea din fisier, inmultim cu scalarul
			            ;si punem rezultatul obtinut in fisier rezultat.txt
			
            ; citire element curent B
            
            push offset curentB
            push offset decimal
            push descriptor_b
            call fscanf
            add esp, 4*3
			
			;;;;TEST currentRez
			push curentB
			push offset decimal
			call printf
			add esp,4*2
			
			push offset spatiu
			call printf
			add esp, 4*1
            
            
            ; calcul inmultire cu scalar si scriere in fisier a rezultatului
            
            mov eax, curentB
            mul scalar
            mov curentRez, eax
            
            push curentRez 
			push offset decimal
			push descriptor_rez
            call fprintf
            add esp, 4*3
			
			
			;TEST currentRez
			push curentRez
			push offset decimal
			call printf
			add esp,4*2
			
			push offset spatiu
			call printf
			add esp, 4
			
			;;daca am ajuns la sfarsit de linie, trecem pe o 
			;noua linie, iar daca nu, punem spatiu
			
			mov eax, edi
			mov edx, 0
			div dimMatB
			
			cmp edx, 0
			jnz afisSpatiu5
			
			push descriptor_rez
			push offset linieNoua
			call fputs
			add esp, 4*2
			
			jmp sfarsitBucla5
			
		afisSpatiu5:
			
			push descriptor_rez
			push offset spatiu
			call fputs
			add esp, 4*2
			
		sfarsitBucla5:
			
			cmp edi, 0
			jne eticheta5
			
		   ; inchidere fisier rezultat
			
			push dword ptr[descriptor_rez]
			call fclose
			add esp, 4*1 		
		
			; inchidere fisier B
			
			push dword ptr[descriptor_b]
			call fclose
			add esp, 4*1 
			
			jmp iesireProgram
        
		
		

		
		
; MESAJE EROARE + INCHIDERE FISIERE	;	
       
   eroare1:
	
		;;daca matricele nu au aceeasi dimensiune, 
		     ;dam mesaj de eroare si inchidem fiesierele deschise
        push offset mesajEroare
        call printf
        add esp, 4*1
		jmp inchidereFisiere
       
	   
   eroare2:
		
		;;cand matricile nu au dimensiuni cuprinse intre 1 si 10, dam mesaj de eroare
		push offset mesajEroare2
		call printf
		add esp, 4*1
		
        	
    inchidereFisiere:
		
		; inchidere fisier rezultat
		
        push dword ptr[descriptor_rez]
        call fclose
        add esp, 4*1 		
    
        ; inchidere fisier A
        
        push dword ptr[descriptor_a]
        call fclose
        add esp, 4*1 
        
        ; inchidere fisier B
        
        push dword ptr[descriptor_b]
        call fclose
        add esp, 4*1 
        
		
    iesireProgram:
    
    push 0
	call exit
	
end start