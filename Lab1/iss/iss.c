#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define MEM_LEN 65536

typedef int32_t INT32;
typedef uint32_t DWORD;

void printError(int err) {
	printf("Error: %d", err);
}

int loadMemory(DWORD *buffer, size_t bufferLen, char *filePath) {
	int err;
	size_t i;
	FILE *fp;

	err = fopen_s(&fp, filePath, "r");
	if (err != 0) {
		printError(err);
		return -1;
	}

	for (i = 0; i < bufferLen; i++) {
		buffer[i] = 0;
	}

	i = 0;
	while (fscanf_s(fp, "%x", buffer + i++) != EOF && i < bufferLen) {
	}

	err = fclose(fp);
	if (err != 0) {
		printError(err);
		return -1;
	}

	return 0;
}

int dumpMemory(DWORD *buffer, size_t bufferLen, char *filePath) {
	int err;
	size_t i;
	FILE *fp;

	err = fopen_s(&fp, filePath, "w");
	if (err != 0) {
		printError(err);
		return -1;
	}

	for (i = 0; i < bufferLen; i++) {
		fprintf(fp, "%08x\n", buffer[i]);
	}

	err = fclose(fp);
	if (err != 0) {
		printError(err);
		return -1;
	}

	return 0;
}

int main() {
	DWORD mem[MEM_LEN];
	int x = loadMemory(mem, MEM_LEN, "C:\\Users\\t-cheilo\\Documents\\temp.txt");
	mem[1]++;
	dumpMemory(mem, MEM_LEN, "C:\\Users\\t-cheilo\\Documents\\temp2.txt");
	return 0;
}
