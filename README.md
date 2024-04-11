# gromgit's Homebrew Utilities

## The Commands

* `trace-login`: traces your shell login (bash and zsh supported), often to answer one of the following questions:-
  * Where did I put that `eval "$(.../brew shellenv)"` line?
  * The Homebrew `bin` directories were in my `PATH`, but now they're not. What happened? (Spoiler: It's usually something that resets `PATH` after you set it correctly.)

## How do I use these commands?

`brew tap gromgit/brewtils` and then `brew <cmd>...`
