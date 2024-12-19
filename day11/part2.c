#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>


struct Stone {
    unsigned long value;
    struct Stone* next;
};

struct Stone *readInput() {
    struct Stone *head = NULL;

    FILE *file = fopen("input.txt", "r");
    if (file == NULL) {
        printf("Error opening file\n");
        exit(1);
    }
    fseek(file, 0L, SEEK_END);
    unsigned long sz = ftell(file) + 1;
    rewind(file);
    
    char line[sz];
    fgets(line, sz, file);
    printf("Read: %s\n", line);
    fclose(file);

    char *token = strtok(line, " ");
    while (token != NULL) {
        struct Stone *newStone = malloc(sizeof(struct Stone));
        newStone->value = atoi(token);
        newStone->next = head;
        head = newStone;
        token = strtok(NULL, " ");
    }
    return head;    
}

unsigned long numDigits(unsigned long value) {
    double logValue = log10(value);
    return (unsigned long)logValue + 1;
}

struct outcome {
    unsigned long value;
    unsigned long nstones;
    struct outcome *next;
};

struct outcome *outcomeCache[75];

void addOutcome(int nsteps, unsigned long value, unsigned long nstones) {
    struct outcome *newOutcome = malloc(sizeof(struct outcome));
    newOutcome->value = value;
    newOutcome->nstones = nstones;
    newOutcome->next = outcomeCache[nsteps];
    outcomeCache[nsteps] = newOutcome;
}

long findOutcome(int nsteps, unsigned long value) {
    struct outcome *outcome = outcomeCache[nsteps];
    while (outcome != NULL) {
        if (outcome->value == value) {
            return outcome->nstones;
        }
        outcome = outcome->next;
    }
    return -1;
}

unsigned long splitStone(unsigned long value, unsigned long nd, int nsteps);

unsigned long applySteps(unsigned long value, int nsteps) {
    if (nsteps == 0) {
        return 1;
    }
    long cached = findOutcome(nsteps, value);
    if (cached != -1) {
        return cached;
    }

    unsigned long result;
    if (value == 0) {
        result = applySteps(1, nsteps - 1);
    } else if (numDigits(value) % 2 == 0) {
        result = splitStone(value, numDigits(value), nsteps - 1);
    } else {
        result = applySteps(value * 2024, nsteps - 1);
    }
    addOutcome(nsteps, value, result);
    return result;
}

unsigned long splitStone(unsigned long value, unsigned long nd, int nsteps) {
    unsigned long half = nd / 2;
    unsigned long firstHalf = value / pow(10, half);
    unsigned long secondHalf = value % (unsigned long)pow(10, half);
    return applySteps(firstHalf, nsteps) + applySteps(secondHalf, nsteps);
}

void part2() {
    struct Stone *head = readInput();
    unsigned long nstones = 0;
    while (head != NULL) {
        nstones += applySteps(head->value, 75);
        head = head->next;
    }

    printf("Part 2: %lu\n", nstones);
}

int main() {
    part2();
    return 0;
}