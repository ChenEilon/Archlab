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
	int addr, last_addr;

	for (addr = 0; addr < MEM_SIZE; addr++)
		mem[addr] = 0;

	pc = 0;

	/*
	 * Program starts here
	 */
	asm_cmd(LD, 2, 1, 0, 1000);  // 0: R2 = MEM[1000]
	asm_cmd(LD, 3, 1, 0, 1001);  // 1: R3 = MEM[1001]
      	asm_cmd(JEQ, 0, 2, 0, 23);   // 2: PC = 23 if (R2 == 0)
        asm_cmd(JEQ, 0, 3, 0, 23);   // 3: PC = 23 if (R3 == 0)
	asm_cmd(XOR, 5, 2, 3, 0);    // 4: R5 = XOR(R2,R3)
	asm_cmd(JLT, 0, 0, 3, 7);    // 5: PC = 7 (R3 > 0)
        asm_cmd(SUB, 3, 0, 3, 0);    // 6: R3 = 0-R3
        asm_cmd(JLT, 0, 0, 2, 9);    // 7: PC = 9 if (R2 > 0 )
	asm_cmd(SUB, 2, 0, 2, 0);    // 8: R2 = 0-R2
   	asm_cmd(JLT, 0, 3, 2, 19);   // 9: PC = 19 if (R2 > R3)
	asm_cmd(JEQ, 0, 2, 0, 25);   // 10: PC = 25 if (R2 == 0)
	asm_cmd(AND, 4, 2, 1, 1);    // 11: R4 = R2 AND 1
	asm_cmd(JEQ, 0, 4, 0, 16);   // 12: PC = 16 if R4 == 0
	asm_cmd(ADD, 3, 3, 3, 0);    // 13: R3 = R3 + R3
	asm_cmd(SUB, 2, 2, 1, 1);    // 14: R2 = R2 - 1
	asm_cmd(JEQ, 0, 0, 0, 10);   // 15: PC = 10
	asm_cmd(RSF, 2, 2, 1, 1);    // 16: R2 >> 1
	asm_cmd(LSF, 3, 3, 1, 1);    // 17: R3 << 1
 	asm_cmd(JEQ, 0, 0, 0, 10);   // 18: PC = 10
	asm_cmd(ADD, 4, 2, 0, 0);    // 19: R4 = R2 
	asm_cmd(ADD, 2, 3, 0, 0);    // 20: R2 = R3
	asm_cmd(ADD, 3, 4, 0, 0);    // 21: R3 = R4
	asm_cmd(JEQ, 0, 0, 0, 10);   // 22: PC = 10
	asm_cmd(ST, 0, 0, 1, 1002);  // 23: MEM[1002] = 0
	asm_cmd(HLT, 0, 0, 0, 0);    // 24: HALT
	asm_cmd(ST, 0, 3, 1, 1002);  // 25: PC =27 if (R5 >= 0)
        asm_cmd(SUB, 3, 0, 3, 0);    // 26: R3 = 0-R3
	asm_cmd(ST, 0, 3, 1, 1002);  // 27: MEM[1002] = R3
	asm_cmd(HLT, 0, 0, 0, 0);    // 28: HALT
	
	/* 
	 * Constants are planted into the memory somewhere after the program code:
	 */

        mem[1000] = 531;
	mem[1001] = 284;
	last_addr = 1003;

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
