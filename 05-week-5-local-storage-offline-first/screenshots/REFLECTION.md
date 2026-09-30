# reflection & others
## - theme preference -> SharedPreference (simple key-value , no query / relations needed)
## - notes (1000+) -> drift (needs sql queries, native .watch() streams, compilte-time safety)
## - full comp. table schema for 1 table, reactive query example, & trade-offs for all 4 options
***
# reflection
## - it stores everything as 1 serialize blob, so every single edit means reading, deserializing, modifiying, & rewriting the entire list
##  - cache-first works when slghtly stale data is acceptable & offline access matter more than freshness, net first needed when correctness now matter than availablity, e.g. stock price, seat availablity,etc
## - writes update the local row & set isDirty = true immidately, so the ui reads local data & never waits on the network
## - the build_runner code overhead for drift is understated for a small team's timeline or that Hive deserved a 2nd look for the notes table given its lower setup cost, if raw sql querying isnt actually a hard requirement for our app berseri later, where the server is Flask based server rather than managing all data in user