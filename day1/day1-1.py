import itertools

lines = open('input.txt').read().split('\n')
l1 = []
l2 = []
for line in lines:
    id1, id2 = line.split('   ')
    l1.append(int(id1))
    l2.append(int(id2))

l1.sort()
l2.sort()

sum = 0
for n1, n2 in itertools.zip_longest(l1, l2):
    sum += abs(n1 - n2)

print(sum)

