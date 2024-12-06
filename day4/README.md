# Day 4

For today's challenge I used Swift. An interesting day, where I actually did use ChatGPT to help debug a problem. It proved useless, and my human brain was victorious :p.

You can run today's solution on a mac by running this command from the day4 dir"ectory

```
swift day4.swift.
```

The issue I was facing was in using subscripts like `grid[x+1][y+1]`. Swiftg was complaining about not finding a matching subscript signature. (I initially had the grid just as an array of String.Subsequence instances) I had extended the String.Subsequence type with a subscript that took an int as an argument, and still got the error. ChatGPT thought the issue was that I was extending the wrong type.

The actual issue turned out to be that the return type is also considered when trying to find a matching call signature. And since my subscript call returned a Character, and I triede to add it to a String, that wouldn't match. Castring the result to a string made it work.
