/*
 * SP ASM: Simple Processor assembler
 *
 * usage: asm
 */
#include <stdio.h>
#include <stdlib.h>

#define ADD 0
#define SUB 1
#define LSF 2
#define RSF 3
#define AND 4
#define OR  5
#define XOR 6
#define LHI 7
#define LD 8
#define ST 9
#define JLT 16
#define JLE 17
#define JEQ 18
#define JNE 19
#define JIN 20
#define HLT 24
#define DMA 30
#define POL 31

#define MEM_SIZE_BITS	(16)
#define MEM_SIZE	(1 << MEM_SIZE_BITS)
#define MEM_MASK	(MEM_SIZE - 1)
unsigned int mem[MEM_SIZE];

int pc = 0;

static void asm_cmd(int opcode, int dst, int src0, int src1, int immediate)
{
	int inst;

	inst = ((opcode & 0x1f) << 25) | ((dst & 7) << 22) | ((src0 & 7) << 19) | ((src1 & 7) << 16) | (immediate & 0xffff);
	mem[pc++] = inst;
}

static void assemble_program(char *program_name)
{
	FILE *fp;
	int addr, i, last_addr;

	for (addr = 0; addr < MEM_SIZE; addr++)
		mem[addr] = 0;

	pc = 0;

	/*
	 * Program starts here
	 */
	asm_cmd(ADD, 2, 1, 0, 200); // 0: R2 = 200
	asm_cmd(ADD, 3, 1, 0, 500); // 1: R3 = 600
    asm_cmd(DMA, 3, 1, 2, 100); // 2: Copy MEM[R2:R2+200] to MEM[R3:R3+200]
	asm_cmd(ADD, 2, 1, 0, 30); // 3: R2 = 30
	asm_cmd(ADD, 3, 1, 0, 1); // 4: R3 = 1
	asm_cmd(ADD, 4, 1, 0, 8); // 5: R4 = 8
	asm_cmd(JEQ, 0, 3, 4, 14); // 6: PC = 14 if R3 == R4
	asm_cmd(LD,  5, 0, 2, 0); // 7: R5 = MEM[R2]
	asm_cmd(ADD, 2, 2, 1, 1); // 8: R2 = R2 + 1
	asm_cmd(LD,  6, 0, 2, 0); // 9: R6 = MEM[R2]
	asm_cmd(ADD, 6, 6, 5, 0); // 10: R6 = R6 + R5
	asm_cmd(ST,  0, 6, 2, 0); // 11: MEM[R2] = R6
	asm_cmd(ADD, 3, 3, 1, 1); // 12: R3 = R3 + 1
	asm_cmd(JEQ, 0, 0, 0, 6); // 13: PC = 6
    asm_cmd(POL, 2, 0, 0, 0); // 14: R2 = 1 if DMA is running, else 0
    asm_cmd(JNE, 0, 2, 0, 14); // 15: PC = 14 if R2 != 0
	asm_cmd(HLT, 0, 0, 0, 0); // 16: HALT
	
	/* 
	 * Constants are planted into the memory somewhere after the program code:
	 */
	for (i = 0; i < 8; i++)
		mem[30+i] = i;
    
    for (i = 0; i < 300; i++)
        mem[100+i] = i;

	last_addr = 400;

	fp = fopen(program_name, "w");
	if (fp == NULL) {
		printf("couldn't open file %s\n", program_name);
		exit(1);
	}
	addr = 0;
	while (addr < last_addr) {
		fprintf(fp, "%08x\n", mem[addr]);
		addr++;
	}
}


int main(int argc, char *argv[])
{
	
	if (argc != 2){
		printf("usage: asm program_name\n");
		return -1;
	}else{
		assemble_program(argv[1]);
		printf("SP assembler generated machine code and saved it as %s\n", argv[1]);
		return 0;
	}
	
}
