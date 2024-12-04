# Day 3

Day 3's challenges could be nicely solved with regexes. I always hear Perl enthoussiasts talk about how great the language was for working with text, so I gate it a go. You can run the code with macos's pre-installed version of perl by running:

```
perl day1-1.py
perl day1-2.py
```

Part 2 generates some warnings, about using uninitialized variables. I assume because named matching groups that don't get matched also don't initialize their associated entry in the hash, but I get the right output, and that's all I care about here.
