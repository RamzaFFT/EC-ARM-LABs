.equ COEF1, 3483
.equ COEF2, 11718
.equ COEF3, 1183

.text

.global rgb2gray
.global div16384
.global MediaGris
.global apply_gaussian

rgb2gray:	PUSH {R4-R10,LR}

			MOV R10,#0
			LDRB R1,[R0]
			LDRB R2,[R0,R10,LSL#1]
			LDRB R3,[R0,R10,LSL#2]

			LDR R4,=COEF1
			LDR R5,=COEF2
			LDR R6,=COEF3

			MUL R7,R1,R4
			MUL R8,R2,R5
			MUL R9,R3,R6

			ADD R0,R8,R7
			ADD R0,R0,R9

			BL div16384

			POP {R4-R10,LR}

			MOV PC,LR



div16384:
			MOV R2,#0

while:		CMP R0,#16384
			BLT fin_while // minor

			SUB R0,R0,#16384
			ADD R2,R2,#1

			B while

fin_while:	MOV R0,R2

			MOV PC,LR


apply_gaussian:

				PUSH {R4-R7,LR}

				MOV R4,#0

for_1:			CMP R4,R3 // for (i=0 ; i < height; ++i)
				BGE fin_for_1

				MOV R5,#0

				for_2:		CMP R5,R2 // for (j=0 ; j < width; ++j)
							BGE fin_for_2

							MUL R7,R4,R2 // i * width
							ADD R7,R7,R5 // (i * width) + j

							PUSH {R0-R3}

							MOV R1,R2
							MOV R2,R3
							MOV R3,R4

							PUSH {R5}

							BL gaussian
							MOV R6,R0

							ADD SP,SP,#4

							POP {R0-R3}

							STRB R6,[R1,R7]

							ADD R5,R5,#1
							B for_2
				fin_for_2:

				ADD R4,R4,#1
				MOV R5,#0
				B for_1

fin_for_1:		POP {R4-R7,LR}
				MOV PC,LR


MediaGris:
				PUSH {R4-R8,LR}

				MOV R4,#0 //R4 -> i
				MOV R6,#0 //R6 -> sum

for1:			CMP R4,R1 // for (i=0 ; i < N; ++i)
				BGE fin_1for

				MOV R6,#0
				MOV R5,#0 //R5 -> j

				for2:		CMP R5,R2 // for (j=0 ; j < M; ++j)
							BGE fin_2for

							MUL R7,R4,R2 // i * M
							ADD R7,R7,R5 // (i * M) + j

							LDRB R8, [R0, R7] //imagenGris[i*M +j]
							ADD R6, R6, R8 //sum+=imagenGris[i*M +j]
							ADD R5,R5,#1 //j++
							B for2
				fin_2for:

	whileIG:	CMP R6,R2
				BLT fin_whileIG

				SUB R6,R6,R2
				ADD R2,R2,#1

				B whileIG

	fin_whileIG: MOV R6,R2 //SUM=SUM/M
				STRB R6,[R3,R4] // imagenMedia[i] = SUM
				ADD R4,R4,#1 //i++
				MOV R5,#0//j=0
				B for1

fin_1for:		POP {R4-R8,LR}
				MOV PC,LR

			.end
