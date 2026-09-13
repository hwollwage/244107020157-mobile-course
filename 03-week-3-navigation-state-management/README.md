# MOBILE PROGRAMMING 2026
# WEEK 03 - STATE MANAGEMENT W/ GoRouter & Riverpod

# REFLECTION
****
## When is setState still enough, and when should state be lifted into Riverpod?

> **setState is enough for simple state used by 1 widget. Use riverpod when state needs to be shared between multiple widgets or screen**

## What is the difference between context.go and context.push, and when should each be used?
> **.go moves directly to another page, while .push add new page on top so we can go back**

## How does AsyncValue prevent bugs compared with three separate booleans?
>**asyncvalue handle loading, error, and data in 1 state, making code easier and safer than using multiple bool**

## Which part of the AI output did you fix, and why?
>**unit test, because provider has 30% failure chance, test should be deterministic so it gave same result every time, thats why my claude.ai help me with that, claude.ai really precise with it**