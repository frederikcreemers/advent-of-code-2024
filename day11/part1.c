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

void splitStone(struct Stone *stone, unsigned long nd) {
    unsigned long half = nd / 2;
    unsigned long firstHalf = stone->value / pow(10, half);
    unsigned long secondHalf = stone->value % (unsigned long)pow(10, half);
    stone->value = firstHalf;
    struct Stone *newStone = malloc(sizeof(struct Stone));
    newStone->value = secondHalf;
    newStone->next = stone->next;
    stone->next = newStone;
}

bool applyRules(struct Stone *stone) {
    unsigned long nd = numDigits(stone->value);

    if (stone->value == 0) {
        stone->value = 1;
        return false;
    } else if (nd % 2 == 0) {
        splitStone(stone, nd);
        return true;
    } else {
        stone->value = stone->value * 2024;
        return false;
    }
}

unsigned long countStones(struct Stone *head) {
    unsigned long count = 0;
    struct Stone *current = head;
    while (current != NULL) {
        count++;
        current = current->next;
    }
    return count;
}  

unsigned long simmulate(int blinks) {
    struct Stone *head = readInput();

    for (int i = 0; i < blinks; i++) {
        struct Stone *current = head;
        while (current != NULL) {
            if (applyRules(current)) {
                // skip the next stone, created when we split a stone
                //printf("%d ", current->value);
                current = current->next;
            }
            //printf("%d ", current->value);
            current = current->next;
        }
        //printf("\n");
    }

    return countStones(head);
}

int main() {
    printf("part 1: %lu\n", simmulate(25));
    return 0;
}