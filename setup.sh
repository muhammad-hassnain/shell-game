#!/bin/bash
# Builds the worlds for the shell discussion section:
#   village/    -- lecture demo 
#   adventure/  -- the students' game 
#
# Run with:          bash setup_world.sh
# Start over with:   bash setup_world.sh --reset

if [ "$1" = "--reset" ]; then
    rm -rf village adventure
    echo "Removed old village/ and adventure/."
fi
if [ -d village ] || [ -d adventure ]; then
    echo "village/ or adventure/ already exists here."
    echo "To start over, run:  bash setup_world.sh --reset"
    exit 1
fi
echo "Building the worlds (a few seconds)..."


#  THE VILLAGE (lecture demo)
mkdir -p village/bakery village/library village/house village/market/back_room
echo "Welcome to Shellville! Visit the bakery, library, house, and market." > village/welcome_sign.txt
printf "bread .... 2 coins\nmuffin ... 3 coins\npie ...... 5 coins\n" > village/bakery/menu.txt
cat > village/library/books.txt << 'EOF'
The Dragon Who Loved Bread
A History of Shellville
How to Train Your Goblin
The Last Dragon of the North
The Owl Who Knew Everything
Dragon Care for Beginners
Gardening in the Dark
EOF
echo "A comfy bed." > village/house/bed.txt
printf "Dear diary, nobody will see this file because its name starts with a dot.\nI hid my coins somewhere in the market.\n" > village/house/.diary.txt
echo "Apples, 1 coin each." > village/market/stall.txt
echo "Smells terrible." > village/market/old_fish1.txt
echo "Smells even worse." > village/market/old_fish2.txt
echo "10 shiny coins!" > village/market/back_room/coins.txt

#  THE ADVENTURE (game)
A=adventure
mkdir -p $A/forest/.cave $A/forest/notes $A/castle/library $A/castle/gate \
         $A/castle/treasury $A/castle/dungeon $A/inventory $A/.oracle_data
for p in $(seq 1 20); do for f in $(seq 1 10); do
    mkdir -p "$A/east/$(printf 'path%02d/fork%02d' $p $f)"
done; done
BRIDGE="$A/east/path14/fork07/bridge"
mkdir -p "$BRIDGE/basket"
for s in $(seq 1 20); do mkdir -p "$A/castle/library/$(printf 'shelf%02d' $s)"; done

cat > $A/README.txt << 'EOF'
You wake up in a dark place called adventure.
Beyond the forest lies a castle full of treasure.

THE ORACLE watches over this land and judges your quest.
From this folder, run:   bash oracle.sh
to see your quests and your score.

If you are ever stuck, ask the Oracle for help:   bash oracle.sh hint N
(where N is the quest number). The Oracle remembers who asks.

The forest hides a cave. Find it.
EOF

cat > $A/forest/.cave/map.txt << 'EOF'
You found the hidden cave! A map on the wall reads:

  Beyond this cave is the Forest of a Thousand Notes (forest/notes/).
  ONE of those 1000 notes tells you where the bridge is.
  Wolves roam this forest too. The Oracle wants to know
  how many of the notes speak of them.
EOF


awk -v A="$A" '
function rnd(n) { seed = (seed * 16807) % 2147483647; return seed % n }
BEGIN {
    seed = 20261021
    # 1000 forest notes 
    split("Birds sing in the trees.|A squirrel stares at you.|The path is muddy here.|You hear a stream nearby.|Mushrooms grow on a log.|An owl hoots somewhere.|The wind smells like rain.|Someone carved initials in a tree.|A wolf howls in the distance.|Fresh Wolf tracks cross the path.|Leaves crunch under your feet.|A deer runs away.|Moss covers the old stones.|A grey wolf watches from the shadows.|The trees grow thicker.|Fog rolls in slowly.", F, "|")
    for (i = 1; i <= 1000; i++) {
        f = sprintf("%s/forest/notes/note%04d.txt", A, i)
        printf "Note %04d\n", i > f
        if (i == 737) {
            print "The bridge lies far to the east, inside a maze of paths and forks." > f
            print "Its folder is named bridge, lost somewhere among the paths of the east." > f
        } else {
            k = 2 + rnd(3)
            for (j = 0; j < k; j++) print F[1 + rnd(16)] > f
        }
        close(f)
    }

    # 200 apples (rotten ones have "rotten" in the name) 
    for (i = 1; i <= 200; i++) {
        kind = (rnd(5) < 2) ? "rotten" : "fresh"
        f = sprintf("%s/east/path14/fork07/bridge/basket/apple_%03d_%s.txt", A, i, kind)
        print (kind == "rotten") ? "A mushy rotten apple. Ew." : "A crisp fresh apple." > f
        close(f)
    }

    # 1000 scrolls on 20 shelves 
    split("dragon|potion|torch|goblin|river|stone|candle|owl|knight|crown", W, "|")
    for (i = 1; i <= 1000; i++) {
        shelf = int((i - 1) / 50) + 1
        f = sprintf("%s/castle/library/shelf%02d/scroll%04d.scroll", A, shelf, i)
        n = 15 + rnd(30)
        special = 0
        if (i == 618) special = 1
        else if (rnd(25) == 0) special = 2
        sl = 3 + rnd(n - 4)
        for (j = 1; j <= n; j++) {
            if (j == sl && special == 1)      print "TRUE KEY = shell-wizard" > f
            else if (j == sl && special == 2) printf "FAKE KEY = %s-%s-%d\n", W[1+rnd(10)], W[1+rnd(10)], rnd(1000) > f
            else printf "the %s met the %s.\n", W[1+rnd(10)], W[1+rnd(10)] > f
        }
        close(f)
    }

    # 300 treasury items 
    split("ruby|emerald|sapphire|diamond|topaz|opal", G, "|")
    split("rock|old_boot|broken_sword|rusty_nail|moldy_bread|cracked_pot", J, "|")
    for (i = 1; i <= 300; i++) {
        r = rnd(10)
        if (r < 3)      { f = sprintf("%s/castle/treasury/%s_%03d.gem",  A, G[1+rnd(6)], i); print "A sparkling gem." > f }
        else if (r < 7) { f = sprintf("%s/castle/treasury/gold_%03d.coin", A, i);           print "A gold coin." > f }
        else            { f = sprintf("%s/castle/treasury/%s_%03d.junk", A, J[1+rnd(6)], i); print "Worthless junk." > f }
        close(f)
    }

    # 500 dungeon cells, one of them empty 
    split("Chains rattle.|A pile of bones.|Water drips from the ceiling.|Rats scurry away.|Scratches on the wall count the days.", D, "|")
    for (i = 1; i <= 500; i++) {
        f = sprintf("%s/castle/dungeon/cell_%03d.txt", A, i)
        if (i == 404) printf "" > f
        else print D[1+rnd(5)] > f
        close(f)
    }
}'

cat > $BRIDGE/troll.txt << 'EOF'
A troll blocks the bridge.

  "My basket is full of apples, and the ROTTEN ones stink!
   Throw out EVERY rotten apple, but don't you dare touch my fresh ones.
   When you're done, go tell the Oracle. If I'm happy,
   the Oracle will tell you where the castle key is hidden."
EOF
cp -r "$BRIDGE/basket" $A/.oracle_data/basket_backup

cat > $A/castle/library/README.txt << 'EOF'
The Royal Library: 1000 scrolls on 20 shelves.
Many scrolls hold a fake key. Exactly one holds the real one.
Every key line starts with the word FAKE or the word TRUE.
EOF

cat > $A/castle/gate/gate.txt << 'EOF'
A huge locked gate.

Create a file called key.txt IN THIS FOLDER containing exactly the
TRUE key (just the key itself, nothing else). Then ask the Oracle.
EOF

cat > $A/castle/treasury/orders.txt << 'EOF'
The royal treasurer left orders:

  1. Make a folder called gems and move every .gem file into it.
  2. Make a folder called coins and move every .coin file into it.
  3. Throw away every .junk file.
  4. Copy crown.txt into your inventory (adventure/inventory/).
     The original crown must stay here!

Then ask the Oracle.
EOF
echo "The royal crown." > $A/castle/treasury/crown.txt


#  Compute the expected answers from the world itself, and store only
#  their checksums in the Oracle (so reading oracle.sh doesn't reveal them).
h() { printf '%s' "$1" | cksum | cut -d' ' -f1; }
WOLF=$(grep -il wolf $A/forest/notes/* | wc -l | tr -d ' ')
FAKE=$(grep -r "FAKE KEY" $A/castle/library | wc -l | tr -d ' ')
FRESH=$(ls $BRIDGE/basket | grep -c fresh)
ROTTEN=$(ls $BRIDGE/basket | grep -c rotten)
GEMS=$(ls $A/castle/treasury/*.gem | wc -l | tr -d ' ')
COINS=$(ls $A/castle/treasury/*.coin | wc -l | tr -d ' ')
SALT=$(h "$WOLF-$FAKE-$COINS-oracle")

cat > $A/oracle.sh << 'ORACLE'
#!/bin/bash
# ============================================================
#  THE ORACLE -- grades your quest.
#    bash oracle.sh                     show quests and score
#    bash oracle.sh answer N "text"     answer quest N
#    bash oracle.sh hint N              ask for help on quest N
#    bash oracle.sh report "Names"      write your report card
#    bash oracle.sh restore-basket      undo damage to the troll's basket
#
#  Quests unlock one by one. When a quest is completed, the Oracle
#  leaves a README.txt somewhere in the world revealing what's next.
# ============================================================
cd "$(dirname "$0")"
DATA=.oracle_data
[ -s $DATA/answers ] || echo "# answers" > $DATA/answers
[ -s $DATA/attempts ] || echo "# attempts" > $DATA/attempts
[ -s $DATA/hints ] || echo "# hints" > $DATA/hints

H1=__H1__; H2=__H2__; H3=__H3__; H5=__H5__; H8=__H8__; H10=__H10__; HKEY=__HKEY__
FRESH=__FRESH__; ROTTEN=__ROTTEN__; GEMS=__GEMS__; COINS=__COINS__; SALT=__SALT__

TITLE=("" "The Hidden Cave" "The Note About the Bridge" "SIDE: Counting Wolves" "The Troll's Basket"
       "SIDE: Counting Fake Keys" "The Castle Gate" "The Treasury" "SIDE: Counting Coins" "The Legend" "BONUS: The Ghost")
POINTS=(0 5 10 10 15 10 15 15 5 15 5)
KIND=("" answer answer answer task answer task task answer task answer)
# Which quests each quest reveals when it's completed
UNLOCKS=("" "2" "3 4" "" "5 6" "" "7" "8 9" "" "10" "")
TASK=("" "The forest hides a cave. What is the exact name of its folder?"
      "Which note (file name) tells you where the bridge is?"
      "How many of the 1000 notes mention a wolf (any capitalization)?"
      "Find the bridge and give the troll what he wants."
      "How many fake-key lines are in the library scrolls?"
      "Put the TRUE key in castle/gate/key.txt."
      "Follow the treasurer's orders in castle/treasury/orders.txt."
      "After sorting the treasury: how many coins are there?"
      "Write adventure/legend.txt: at least 3 lines, and mention the troll."
      "Which dungeon cell (file name) is completely empty?")
HINT=("" "ls has a flag that shows ALL files, even hidden ones. Try: ls -a forest"
      "grep can search many files at once: grep bridge forest/notes/*"
      "grep -i ignores capitalization, grep -l prints only file NAMES. Then count the lines with | wc -l"
      "First find the bridge: find . -type d -name bridge. Then LOOK at what a pattern matches (ls basket/*rotten*) before you rm it."
      "grep -r searches a folder and all its subfolders (search castle/library). Fake keys start with the word FAKE. Pipe into wc -l to count."
      "Use grep -r on castle/library with the two words TRUE and KEY together in quotes. Then: echo \"the-key\" > castle/gate/key.txt"
      "mkdir gems coins, then mv *.gem gems/ ... Use ls *.junk before rm *.junk. Use cp (not mv) for the crown."
      "ls castle/treasury/coins | wc -l"
      "echo \"some text\" > legend.txt creates it; >> adds more lines."
      "find has a flag for empty files. Look in: man find")

h() { printf '%s' "$1" | cksum | cut -d' ' -f1; }
norm() { printf '%s' "$1" | tr 'A-Z' 'a-z' | tr -d ' \t\r\n' | sed 's|/*$||; s|.*/||; s|\.txt$||'; }
saved() { grep "^$1|" $DATA/answers | tail -1 | cut -d'|' -f2-; }
tries() { grep -c "^$1$" $DATA/attempts; }
hints() { grep -c "^$1$" $DATA/hints; }
unlocked() { [ "$1" = 1 ] || [ -f $DATA/unlocked$1 ]; }

passed() {   # is the quest's work actually done? (ignores locking)
    case $1 in
        1|2|3|5|8|10) eval "want=\$H$1"; [ -n "$(saved $1)" ] && [ "$(h "$(norm "$(saved $1)")")" = "$want" ] ;;
        4) b=$(find east -type d -name bridge 2>/dev/null | head -1)
           [ -n "$b" ] && [ "$(find "$b/basket" -name '*rotten*' | wc -l | tr -d ' ')" = 0 ] \
                       && [ "$(find "$b/basket" -name '*fresh*' | wc -l | tr -d ' ')" = "$FRESH" ] ;;
        6) [ -f castle/gate/key.txt ] && [ "$(h "$(tr -d ' \t\r\n' < castle/gate/key.txt)")" = "$HKEY" ] ;;
        7) t=castle/treasury
           [ "$(ls $t/gems 2>/dev/null | grep -c '\.gem$')" = "$GEMS" ] && [ "$(ls $t/coins 2>/dev/null | grep -c '\.coin$')" = "$COINS" ] \
           && [ "$(find $t -maxdepth 1 \( -name '*.gem' -o -name '*.coin' \) | wc -l | tr -d ' ')" = 0 ] \
           && [ "$(find $t -name '*.junk' | wc -l | tr -d ' ')" = 0 ] && [ -f $t/crown.txt ] && [ -f inventory/crown.txt ] ;;
        9) [ -f legend.txt ] && [ "$(wc -l < legend.txt | tr -d ' ')" -ge 3 ] && grep -qi troll legend.txt ;;
    esac
}
done_q() { unlocked $1 && passed $1; }

feedback() {   # explain what's still wrong with a "do it" quest
    case $1 in
        4) b=$(find east -type d -name bridge 2>/dev/null | head -1); [ -z "$b" ] && return
           r=$(find "$b/basket" -name '*rotten*' | wc -l | tr -d ' '); f=$(find "$b/basket" -name '*fresh*' | wc -l | tr -d ' ')
           if [ "$f" != "$FRESH" ]; then echo "        TROLL: \"You threw out my FRESH apples!\"  Fix it: bash oracle.sh restore-basket"
           elif [ "$r" != 0 ] && [ "$r" != "$ROTTEN" ]; then echo "        TROLL: \"There are still $r rotten apples in my basket!\""; fi ;;
        6) [ -f castle/gate/key.txt ] && echo "        The gate does not budge. That is not the true key." ;;
        7) t=castle/treasury; [ -d $t/gems ] || [ -d $t/coins ] || [ -f inventory/crown.txt ] || return
           [ "$(ls $t/gems 2>/dev/null | grep -c '\.gem$')" = "$GEMS" ] || echo "        - gems/ should hold all $GEMS gems"
           [ "$(ls $t/coins 2>/dev/null | grep -c '\.coin$')" = "$COINS" ] || echo "        - coins/ should hold all the coins"
           [ "$(find $t -name '*.junk' | wc -l | tr -d ' ')" = 0 ] || echo "        - there is still junk in the treasury"
           [ -f $t/crown.txt ] || echo "        - the original crown.txt must stay in the treasury"
           [ -f inventory/crown.txt ] || echo "        - inventory/ has no crown.txt yet" ;;
        9) [ -f legend.txt ] || return
           [ "$(wc -l < legend.txt | tr -d ' ')" -ge 3 ] || echo "        - legend.txt needs at least 3 lines"
           grep -qi troll legend.txt || echo "        - your legend never mentions the troll" ;;
    esac
}

# the messages the Oracle leaves in the world 
leave_message() {   # leave_message <quest that was just completed>
    case $1 in
    1) f=forest/README.txt
       cat > $f << 'MSG'
=== A message from the Oracle ===

You found the cave. Well done.

QUEST 2: The Note About the Bridge
  To reach the castle you must cross a bridge,
  but no one remembers where it is.
  One of the thousand notes in forest/notes/ knows.
  Find that note, and tell me its name.
MSG
       ;;
    2) f="east/README.txt and forest/README.txt"
       cat > east/README.txt << 'MSG'
=== A message from the Oracle ===

So the bridge is in the east. But these paths twist and fork
in every direction, and a troll is said to guard the bridge.

QUEST 4: The Troll's Basket
  Find the bridge. Read what the troll wants.
  Give him exactly that, and nothing more.
MSG
       cat > forest/README.txt << 'MSG'
=== A message from the Oracle ===

SIDE QUEST 3: Counting the Howlers
  At night, something howls in this forest.
  Many of the notes speak of it. I want to know
  exactly how many notes do. Run bash oracle.sh for my question.
MSG
       ;;
    4) f=castle/README.txt
       cat > castle/README.txt << 'MSG'
=== A message from the Oracle ===

The troll let you pass. You stand before the castle.

QUEST 6: The Castle Gate
  The gate (castle/gate/) opens only with the true key.
  The key is written in one of the thousand scrolls
  of the royal library (castle/library/). But beware:
  many scrolls hold false keys.

SIDE QUEST 5: Counting the Fakes
  Before you go: tell me how many fake ones are in the library.
MSG
       ;;
    6) f=castle/treasury/README.txt
       cat > castle/treasury/README.txt << 'MSG'
=== A message from the Oracle ===

The gate is open! Behind it lies the royal treasury,
and it is a complete mess.

QUEST 7: The Treasury
  The treasurer left orders in orders.txt. Carry them out.
MSG
       ;;
    7) f=inventory/README.txt
       cat > inventory/README.txt << 'MSG'
=== A message from the Oracle ===

The treasurer bows. The crown is yours.

QUEST 9: The Legend
  Every great quest deserves a legend. Write yours in
  adventure/legend.txt. Remember the troll.

SIDE QUEST 8: Counting Coins
  And tell me: how many coins does the treasury hold now?
MSG
       ;;
    9) f=castle/dungeon/README.txt
       cat > castle/dungeon/README.txt << 'MSG'
=== A message from the Oracle ===

Your legend will be told for ages. But one mystery remains.

BONUS QUEST 10: The Ghost
  Far below the castle are 500 dungeon cells.
  A ghost hides in the one that is completely empty.
  Tell me which cell it is.
MSG
       ;;
    *) f="" ;;
    esac
    echo " >> Quest $1 complete! (+${POINTS[$1]} points)"
    [ -n "$f" ] && echo " >> The Oracle has left a message for you in: $f"
}

reveal() {   # check for newly completed quests, unlock what comes next
    changed=1
    while [ $changed = 1 ]; do
        changed=0
        for q in 1 2 3 4 5 6 7 8 9 10; do
            if [ ! -f $DATA/revealed$q ] && done_q $q; then
                echo done > $DATA/revealed$q
                for n in ${UNLOCKS[q]}; do echo open > $DATA/unlocked$n; done
                echo; leave_message $q
                changed=1
            fi
        done
    done
}

score() { s=0; for q in 1 2 3 4 5 6 7 8 9 10; do done_q $q && s=$((s + POINTS[q])); done; echo $s; }
rank() {
    if   [ $1 -ge 100 ]; then echo "SHELL WIZARD"
    elif [ $1 -ge 70 ];  then echo "Adventurer"
    elif [ $1 -ge 40 ];  then echo "Apprentice"
    else                      echo "Wanderer"; fi
}

status() {
    echo
    echo "================== THE ORACLE =================="
    for q in 1 2 3 4 5 6 7 8 9 10; do
        if done_q $q; then
            printf " [x] %2d. %-27s %2d/%-2d pts\n" $q "${TITLE[q]}" ${POINTS[q]} ${POINTS[q]}
        elif unlocked $q; then
            printf " [ ] %2d. %-27s  0/%-2d pts\n" $q "${TITLE[q]}" ${POINTS[q]}
            echo "        ${TASK[q]}"
            if [ "${KIND[q]}" = answer ]; then echo "        (answer with: bash oracle.sh answer $q \"your answer\")"; else feedback $q; fi
        else
            printf " [?] %2d. %-27s  ?/%-2d pts\n" $q "(not yet revealed)" ${POINTS[q]}
        fi
    done
    s=$(score)
    echo "------------------------------------------------"
    echo " Score: $s / 100  (quest 10 is +5 bonus)   Rank: $(rank $s)"
    echo " Stuck? Ask for help:  bash oracle.sh hint N"
    echo "================================================"
}

case "$1" in
    ""|status) news=$(reveal); status; [ -n "$news" ] && echo "$news"; echo ;;
    answer)
        q=$2; a=$3
        if [ -z "$q" ] || [ -z "$a" ]; then echo "Usage: bash oracle.sh answer N \"your answer\""; exit 1; fi
        if [ -z "${KIND[q]}" ] 2>/dev/null; then echo "There is no quest $q."; exit 1; fi
        if ! unlocked $q; then echo "The Oracle doesn't know what you mean. Quest $q has not been revealed yet."; exit 1; fi
        if [ "${KIND[q]}" != answer ]; then
            echo "Quest $q isn't answered with words: you have to DO it. Run bash oracle.sh to check your progress."; exit 1; fi
        echo "$q" >> $DATA/attempts
        if [ "$(h "$(norm "$a")")" = "$(eval echo \$H$q)" ]; then
            echo "$q|$a" >> $DATA/answers
            echo "The Oracle nods. That is correct."
            reveal
        else
            echo "The Oracle frowns. That is not the answer to quest $q. (attempt $(tries $q))"
        fi ;;
    hint)
        q=$2; [ -z "${HINT[q]}" ] && { echo "Usage: bash oracle.sh hint N   (N = 1 to 10)"; exit 1; }
        if ! unlocked $q; then echo "Quest $q has not been revealed yet."; exit 1; fi
        echo "$q" >> $DATA/hints
        echo "Hint for quest $q: ${HINT[q]}" ;;
    restore-basket)
        b=$(find east -type d -name bridge | head -1)
        rm -rf "$b/basket" && cp -r $DATA/basket_backup "$b/basket" && echo "The troll's basket is back to how it started." ;;
    report)
        names=$2; [ -z "$names" ] && { echo "Usage: bash oracle.sh report \"Name1 and Name2\""; exit 1; }
        reveal >/dev/null
        s=$(score); total=$(grep -vc '^#' $DATA/attempts)
        code=$(h "$names|$s|$SALT")
        {
            echo "=========== QUEST REPORT CARD ==========="
            echo " Adventurers: $names"
            echo " Date:        $(date)"
            echo "-----------------------------------------"
            for q in 1 2 3 4 5 6 7 8 9 10; do
                if done_q $q; then m="[x]"; else m="[ ]"; fi
                extra=""; [ "${KIND[q]}" = answer ] && extra="tries: $(tries $q)  "
                extra="${extra}hints: $(hints $q)"
                printf " %s %2d. %-27s %s\n" "$m" $q "${TITLE[q]}" "$extra"
            done
            echo "-----------------------------------------"
            echo " SCORE: $s / 100     RANK: $(rank $s)"
            echo " Answers submitted: $total     Hints used: $(grep -vc '^#' $DATA/hints)"
            echo " Verification code: $code"
            echo "========================================="
        } > report_card.txt
        cat report_card.txt
        echo "(Saved to report_card.txt)" ;;
    verify)   # for the TA:  bash oracle.sh verify "Names" SCORE CODE
        if [ "$(h "$2|$3|$SALT")" = "$4" ]; then echo "VALID report card."; else echo "INVALID: names, score, or code don't match."; fi ;;
    *) echo "Commands: (nothing) | answer N \"text\" | hint N | report \"Names\" | restore-basket" ;;
esac
ORACLE

sed -i.bak -e "s|__H1__|$(h .cave)|" -e "s|__H2__|$(h note0737)|" -e "s|__H3__|$(h $WOLF)|" \
    -e "s|__H5__|$(h $FAKE)|" -e "s|__H8__|$(h $COINS)|" -e "s|__H10__|$(h cell_404)|" \
    -e "s|__HKEY__|$(h shell-wizard)|" -e "s|__FRESH__|$FRESH|" -e "s|__ROTTEN__|$ROTTEN|" -e "s|__GEMS__|$GEMS|" \
    -e "s|__COINS__|$COINS|" -e "s|__SALT__|$SALT|" $A/oracle.sh && rm -f $A/oracle.sh.bak

echo "Done! village/ is for the lecture. adventure/ is the game: cd adventure && bash oracle.sh"