#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>

#define MEM_LEN			65536
#define OPCODE_MASK		0X1f
#define IMM_SHIFT		16
#define REG_MASK		0x7
#define OPCODE_SHIFT	25
#define DST_SHIFT		22
#define SRC0_SHIFT		19
#define SRC1_SHIFT		16
#define REG_NUM			8
#define TRC_INST_SIZE	200
#define OUTPUT_MEM_FILE		"sram_out.txt"
#define OUTPUT_TRACE_FILE	"trace.txt"

typedef int32_t INT32;
typedef uint32_t DWORD;

typedef struct _instruction {
	DWORD inst;
	DWORD opcode;
	DWORD dst;
	DWORD src0;
	DWORD src1;
	INT32 imm;
} Instruction;

typedef enum _opcode {
	ADD = 0,
	SUB = 1,
	LSF = 2,
	RSF = 3,
	AND = 4,
	OR = 5,
	XOR = 6,
	LHI = 7,
	LD = 8,
	ST = 9,
	JLT = 16,
	JLE = 17,
	JEQ = 18,
	JNE = 19,
	JIN = 20,
	HLT = 24,
} Opcode;

static const char *opcodeStrings[] = {
	"ADD",
	"SUB",
	"LSF",
	"RSF",
	"AND",
	"OR",
	"XOR",
	"LHI",
	"LD",
	"ST",
	"",
	"",
	"",
	"",
	"",
	"",
	"JLT",
	"JLE",
	"JEQ",
	"JNE",
	"JIN",
	"",
	"",
	"",
	"HLT"};

static Instruction currentInst;
static INT32 registerBlk[REG_NUM];
static INT32 pc;
static DWORD mem[MEM_LEN];
static INT32 instructionNumber;

/****************************************************************/
/************************ Monitor functions *********************/
/****************************************************************/

void printError() {
	printf("Error: %s\n", strerror(errno));
}

static void parseInst(DWORD inst) {
	memset(&currentInst, 0, sizeof(Instruction));
	currentInst.inst = inst;
	currentInst.opcode = (inst >> OPCODE_SHIFT) & OPCODE_MASK;
	currentInst.dst = (inst >> DST_SHIFT) & REG_MASK;
	currentInst.src0 = (inst >> SRC0_SHIFT) & REG_MASK;
	currentInst.src1 = (inst >> SRC1_SHIFT) & REG_MASK;
	currentInst.imm = (inst << IMM_SHIFT) >> IMM_SHIFT;  //maintain imm sign
}

static void cleanup() {
	memset(&currentInst, 0, sizeof(Instruction));
	memset(registerBlk, 0, sizeof(INT32) * REG_NUM);
	memset(mem, 0, sizeof(DWORD) * MEM_LEN);
	pc = 0;
	instructionNumber = 0;
}

static INT32 getNum(int reg) {
	if (reg == 1)
		return currentInst.imm;
	return registerBlk[reg];
}

static void performJump(INT32 newPc) {
	registerBlk[7] = pc;
	pc = newPc;
	//TODO - add R7 to stack and update R6?
}

static int traceInstruction(bool validInstruction){
	FILE *fp;

	if (instructionNumber == 1) {
		fp = fopen(OUTPUT_TRACE_FILE, "w");
	} else {
		fp = fopen(OUTPUT_TRACE_FILE, "a");
	}
	if (fp == NULL) {
		printError();
		return -1;
	}

	if (validInstruction) {
		fprintf(
			fp,
			"--- instruction %d (%04d) @ PC %d (%04d) -----------------------------------------------------------\n\
pc = %04d, inst = %08x, opcode = %d (%s), dst = %d, src0 = %d, src1 = %d, immediate = %08x\n\
r[0] = %08x r[1] = %08x r[2] = %08x r[3] = %08x\nr[4] = %08x r[5] = %08x r[6] = %08x r[7] = %08x\n\n",
			instructionNumber,
			instructionNumber,
			pc,
			pc,
			pc,
			currentInst.inst,
			currentInst.opcode,
			opcodeStrings[currentInst.opcode],
			currentInst.dst, currentInst.src0,
			currentInst.src1,
			currentInst.imm,
			registerBlk[0],
			registerBlk[1],
			registerBlk[2],
			registerBlk[3],
			registerBlk[4],
			registerBlk[5],
			registerBlk[6],
			registerBlk[7]);
	} else {
		fprintf(
			fp,
			"--- instruction %d (%04d) @ PC %d (%04d) -------------------------------------\
		----------------------\npc = %04d, inst = %08x\n INVALID INSTRUCTION!",
			instructionNumber,
			instructionNumber,
			pc,
			pc,
			pc,
			currentInst.inst);
	}

	fclose(fp);

	return 0;
}

static bool excuteCurrentInstruction() {
	bool validInstruction = true;
	bool keepGoing = true;
	bool error = (currentInst.dst > (REG_NUM - 1) || currentInst.src0 > (REG_NUM - 1) || currentInst.src1 > (REG_NUM - 1)) || (currentInst.dst <= 1 && currentInst.opcode <= 7);
	if (error) {  /*checks if register numbers are valid and if arithmetic command has illegal dst*/
		validInstruction = false;
		instructionNumber++;
		traceInstruction(validInstruction);
		return keepGoing;
	}
	
	INT32 num0 = getNum(currentInst.src0);
	INT32 num1 = getNum(currentInst.src1);

	switch (currentInst.opcode) {
		case ADD:
			registerBlk[currentInst.dst] = num0 + num1;
			pc = pc + 1;
			break;
		case SUB:
			registerBlk[currentInst.dst] = num0 - num1;
			pc = pc + 1;
			break;
		case LSF:
			registerBlk[currentInst.dst] = num0 << num1;
			pc = pc + 1;
			break;
		case RSF:
			registerBlk[currentInst.dst] = num0 >> num1; /*arithmetic shift when done on signed int*/
			pc = pc + 1;
			break;
		case AND:
			registerBlk[currentInst.dst] = num0 & num1;
			pc = pc + 1;
			break;
		case OR:
			registerBlk[currentInst.dst] = num0 | num1;
			pc = pc + 1;
			break;
		case XOR:
			registerBlk[currentInst.dst] = num0 ^ num1;
			pc = pc + 1;
			break;
		case LHI:
			registerBlk[currentInst.dst] = currentInst.imm << IMM_SHIFT;
			pc = pc + 1;
			break;
		case LD:
			registerBlk[currentInst.dst] = mem[num1];
			pc = pc + 1;
			break;
		case ST:
			mem[num1] = num0;
			pc = pc + 1;
			break;
		case JLT:
			if (num0 < num1)
				pc = currentInst.imm;
			else
				pc = pc + 1;
			break;
		case JLE:
			if (num0 <= num1)
				performJump(currentInst.imm);
			else
				pc = pc + 1;
			break;
		case JEQ:
			if (num0 == num1)
				performJump(currentInst.imm);
			else
				pc = pc + 1;
			break;
		case JNE:
			if (num0 != num1)
				performJump(currentInst.imm);
			else
				pc = pc + 1;
			break;
		case JIN:
			performJump(num0);
			break;
		case HLT:
			keepGoing = false;
			break;
		default:
			validInstruction = false;
			break;
	}
	instructionNumber++; 
	traceInstruction(validInstruction);
	return keepGoing;
}

int loadMemory(DWORD *buffer, size_t bufferLen, char *filePath) {
	size_t i;
	FILE *fp;

	fp = fopen(filePath, "r");
	if (fp == NULL) {
		printError();
		return -1;
	}

	for (i = 0; i < bufferLen; i++) {
		buffer[i] = 0;
	}

	i = 0;
	while (i < bufferLen) {
		fscanf(fp, "%x", buffer + i++);
	}

	fclose(fp);

	return 0;
}

int dumpMemory(DWORD *buffer, size_t bufferLen, char *filePath) {
	size_t i;
	FILE *fp;

	fp = fopen(filePath, "w");
	if (fp == NULL) {
		printError();
		return -1;
	}

	for (i = 0; i < bufferLen; i++) {
		fprintf(fp, "%08x\n", buffer[i]);
	}

	fclose(fp);

	return 0;
}

/****************************************************************/
/**************************** Tests *****************************/
/****************************************************************/

//static bool testParseInst() {
//	DWORD a = 0x0088000f;
//	parseInst(a);
//	if ((Opcode)currentInst.opcode != ADD || currentInst.dst != 2 || currentInst.src0 != 1 || currentInst.src1 != 0 || currentInst.imm != 15)
//		return false;
//	a = 0x241c000b;
//	parseInst(a);
//	if ((Opcode)currentInst.opcode != JEQ || currentInst.dst != 0 || currentInst.src0 != 3 || currentInst.src1 != 4 || currentInst.imm != 11)
//		return false;
//	a = 0x11420000;
//	parseInst(a);
//	if ((Opcode)currentInst.opcode != LD || currentInst.dst != 5 || currentInst.src0 != 0 || currentInst.src1 != 2 || currentInst.imm != 0)
//		return false;
//	a = 0x30000000;
//	parseInst(a);
//	if ((Opcode)currentInst.opcode != HLT || currentInst.dst != 0 || currentInst.src0 != 0 || currentInst.src1 != 0 || currentInst.imm != 0)
//		return false;
//	return true;
//}

/****************************************************************/
/**************************** Main flow *************************/
/****************************************************************/

int main(int argc, char *argv[]) {
	if (argc < 2) {
		printf("Usage: %s <input_file>", argv[0]);
		return 0;
	}

	/* init */
	cleanup();
	loadMemory(mem, MEM_LEN, argv[1]);
	DWORD inst;
	bool keepRunning = true;

	/* execute program*/
	while (keepRunning) {
		inst = mem[pc]; //Get next instruction
		parseInst(inst);
		keepRunning = excuteCurrentInstruction();
	}

	// finish 
	dumpMemory(mem, MEM_LEN, OUTPUT_MEM_FILE);

	return 0;
}
