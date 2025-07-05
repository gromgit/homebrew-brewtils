# Homebrew Utilities

My collection of Homebrew-related commands and formulae. Everything listed below is by me, unless otherwise stated.

## The Commands

* `trace-login`: traces your shell login (bash and zsh supported), often to answer one of the following questions:-
  * Where did I put that `eval "$(.../brew shellenv)"` line?
  * The Homebrew `bin` directories were in my `PATH`, but now they're not. What happened? (Spoiler: It's usually something that resets `PATH` after you set it correctly.)

### How do I use these commands?

`brew tap gromgit/brewtils` and then `brew <cmd>...`

## The Formulae

* [`taproom`](https://github.com/hzqtc/taproom) (by hzqtc): an interactive TUI for Homebrew

### How do I install these things?

`brew install gromgit/brewtils/<thing>`
