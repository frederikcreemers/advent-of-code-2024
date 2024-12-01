lines = open('input.txt').read().split('\n')
l1 = []
l2 = []
for line in lines:
    id1, id2 = line.split('   ')
    l1.append(int(id1))
    l2.append(int(id2))

s = 0
for id in l1:
    s += id * l2.count(id)

    print(s)

