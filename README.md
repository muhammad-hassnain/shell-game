# The Castle Quest: A Shell Adventure

## Setup

Open a terminal (Mac: Terminal · VSCode: `` Ctrl+` `` · Windows: WSL). Go to the folder with `setup_world.sh` and run:

```
bash setup_world.sh
cd adventure
bash oracle.sh
```

## How to play

- **Work in pairs.** Discuss among yourselves and try to figure out what to do. 
- **Quests are revealed one at a time.** At the start you only know Quest 1. Each time you finish a quest, the Oracle leaves a `README.txt` somewhere in the world revealing what comes next, and tells you where to find it.
- **Main quests and side quests.** Main quests move the story forward. Side quests (counting things) are worth points but don't block your path.
- **This world has over 3,000 files.** Opening them one at a time won't get you anywhere. Think about which commands from the lecture can do the work for you. 
- **Stuck?** Look at man pages or ask the Oracle with `bash oracle.sh hint N`. It will help, but every hint is recorded on your report card.
- **Golden rule:** look before you change anything, and look again after.

## Talking to the Oracle

Run these from the `adventure/` folder.

| Command | What it does |
|---|---|
| `bash oracle.sh` | show your quests and score (and check your progress) |
| `bash oracle.sh answer N "your answer"` | answer quest N |
| `bash oracle.sh hint N` | ask for help on quest N |
| `bash oracle.sh report "Your Names"` | make your report card (at the end) |

Some quests are **answered**: you find something and tell the Oracle. Others you **do**: you change the world, then run `bash oracle.sh` and it checks your work.

## Your quest begins

```
cat README.txt
```

Good luck.

---

## Cheat sheet

| Kind | Command | What it does |
|---|---|---|
| Look | `pwd` | where am I? |
| Look | `ls`, `ls -a` | what's here (`-a` includes hidden files) |
| Look | `cat file` / `less file` | print / scroll a file (`q` quits) |
| Help | `man cmd` | manual (`/word` searches, `q` quits) |
| Search | `grep word file` | lines containing `word` |
| Search | `grep word folder/*` | search every file in a folder |
| Search | grep flags | `-i` ignore case · `-l` file names only · `-r` all subfolders · `-n` line numbers · `-c` count per file |
| Search | `find . -name "x"` | files named `x` (`-type d` folders, `-type f` files) |
| Do | `cd dir` | move (`..` up) |
| Do | `mkdir dir` / `touch file` | make folder / empty file |
| Do | `cp a b` / `mv a b` | copy / move or rename |
| Do | `rm file` / `rm -r dir` | delete forever |
| Glue | `echo "text"` | print text |
| Glue | `>` / `>>` | write / append to file |
| Glue | `A \| B` | A's output into B |
| Glue | `wc -l` | count lines |

`*` matches anything: `*.gem` = every .gem file, `*rotten*` = every name containing "rotten".

**Ctrl-C** stops a command (useful if your screen floods with text!).
