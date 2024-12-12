global guard
global rot
global move
global lines
global walls

text = fileread("./input.txt");
lines = strsplit(text, "\n");

walls = [];

for i=1:size(lines, 2)-1
  line = lines{1,i};
  res = strfind(line, '#');
  for j=1:size(res, 2);
    idx = res(j);
    walls = vertcat(walls, [i, idx]);
  endfor
  maybeGuard = strfind(line, "^");
  if size(maybeGuard, 2) > 0
    guard = [i, maybeGuard];
  endif
endfor


move = [-1, 0];
% If you se move as a vector, rotating it by the rot matrix rotates that vector 90% clockwise around the origin
rot = [0, -1; 1, 0];

function solve()
  global guard
  global walls
  global rot
  global move
  global lines
  global line
  global walls
  visited = [];
  cyclers = []
  boundary = [size(lines, 2)-1, size(lines{1}, 2)];
  i = 0
  while guard >= [1, 1] & guard <= boundary
    i += 1
    disp(i)

    beenhere = hasPair(visited, guard);
    if !beenhere
      visited = vertcat(visited, guard);
    endif

    [nextg, move] = getNextPos(guard, move, walls, [-1, -1]);
    isKnownCycler = hasPair(cyclers, nextg);
    beenThere = hasPair(visited, nextg);
    if !isKnownCycler && !beenThere
      isCycler = willGuardCycle(guard, move, walls, nextg);
      if isCycler
        cyclers = vertcat(cyclers, nextg);
      endif
    endif
    guard = nextg
  endwhile
  disp("Part 1")
  disp(size(visited, 1))
  disp("Part 2")
  disp(size(cyclers, 1))
end

function value = hasPair(collection, pair)
  value = any(ismember(collection, pair, 'rows'));
end

function [ng, mv] = getNextPos(guard, move, walls, addedWall)
    global rot;
    nextg = guard + move;
    while hasPair(walls, nextg) || nextg == addedWall
      move = move * rot;
      nextg = guard + move;
    endwhile
    ng = nextg;
    mv = move;
end

function wc = willGuardCycle(guard, move, walls, addedWall)
  global lines
  visited = [];
  while 1
    visited = vertcat(visited, [guard, move]);
    [guard, move] = getNextPos(guard, move, walls, addedWall);
    boundary = [size(lines, 2)-1, size(lines{1}, 2)];
    if any(guard < [1, 1]) || any(guard > boundary)
      wc = 0;
      break
    endif
    beenHere = hasPair(visited, [guard, move]);
    if beenHere
      wc = 1;
      break
    endif
  endwhile
end

solve()
