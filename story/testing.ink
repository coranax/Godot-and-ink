// test story by caitlyn pinkham 2026
// it's not really a story it's lorem ipsum ;)

// note this story uses only sticky options. the player can run through the story as many times as they want. this is mainly done for ease of development (and since i have a project in mind that will work that way)

// setting names and bg images will only change per chapter in this project. this could be changed by modifying the build_setting function in the godot code to behave differently. chapters are knots.

// to change setting name, music, or song, use syntax "setting: setting name"
// the deliminator is ": " with space included

// you may want to remove the whole index and chapter end things. i mainly did that for development ease.


// this will turn true while the player is in a section that should be recorded. it will then look for the "# record: " tag to tell the game engine what is being recorded.
VAR record = false
LIST ch1_locations = ch0101, ch0102, ch0103
LIST ch2_locations = ch0201, ch0202, ch0203
LIST ch3_locations = ch0301, ch0302, ch0303
LIST non_locations = no_loc
VAR current_loc = ""


-> index

=== index ===
~ current_loc = no_loc
# setting: index # image: chinatown at night.jpg # music: kinda-chill.wav

This  is the title :) hohoho
+ [go to chapter 1] -> ch1
+ [go to chapter 2] -> ch2
+ [go to chapter 3] -> ch3
+ [go to end?] -> endstory



=== ch1 ===
~ current_loc = no_loc
# music: sad-song.wav # setting: chapter 1 # image: ocean city new jersey.jpg
Chapter 1
+ [start ch1] -> one

= one
~ current_loc = ch0101
# title: chapter 1-1 # id: 0101
This is chapter 1 part one.... page 1

+ [next]

- This is chapter 1 part one.... page 2

+ [next]

- This is chapter 1 part one.... page 3
# finish: 0101
+ [next]

-> two

= two
~ current_loc = ch0102
# title: chapter 1-2 # setting: chapter 1-2 has a new setting BOYS # id: 0102
This is chapter 1 part two.... page 1
+ [next]

- This is chapter 1 part two.... page 2

+ [next]

- This is chapter 1 part two.... page 3

# finish: 0102
+ [next]

-> three

= three
~ current_loc = ch0103
# chapter 1-3
# title: chapter 1-3 # id: 0103

This is chapter 1 part three.... page 1

+ [next]

- This is chapter 1 part three.... page 2

+ [next]

- This is chapter 1 part three.... page 3

 # finish: 0103
+ [next] -> chend
 
= chend
~ current_loc = no_loc
# chapter 1-end

End of Chapter
+ next chapter
-> ch2

+ [chapter index] -> index

-> DONE

=== ch2 ===
~ current_loc = no_loc
# setting: chapter 2 # image: philadelphia skyline.jpg # music: weird-song.wav
Chapter 2
+ [start ch2] -> one

= one
~ current_loc = ch0201
# title: chapter 2-1 # id: 0201

This is chapter 2 part one.... page 1
+ [next]
- This is chapter 2 part one.... page 2
+ [next]
- This is chapter 2 part one.... page 3
# finish: 0201
+ [next]

-> two

= two
~ current_loc = ch0202
# title: chapter 2-2 # id: 0202

This is chapter 2 part two.... page 1
+ [next]
- This is chapter 2 part two.... page 2
+ [next]
- This is chapter 2 part two.... page 3
# finish: 0202
+ [next]

-> three

= three
~ current_loc = ch0203
# title: chapter 2-3 # id: 0203

This is chapter 2 part three.... page 1
+ [next]
- This is chapter 2 part three.... page 2
+ [next]
- This is chapter 2 part three.... page 3
# finish: 0203
+ [next] -> chend

= chend
~ current_loc = no_loc
# chapter 2-end
End of Chapter
+ next chapter
-> ch3
+ [chapter index] -> index

-> DONE

=== ch3 ===
~ current_loc = no_loc
# setting: chapter 3 # image: pittsburg 3 point park.jpg # music: crazy-song.wav
Chapter 3
+ [start ch3] -> one

= one
~ current_loc = ch0301
# title: chapter 3-1 # id: 0301

This is chapter 3 part one.... page 1
+ [next]
- This is chapter 3 part one.... page 2
+ [next]
- This is chapter 3 part one.... page 3
# finish: 0301
+ [next]

-> two

= two
~ current_loc = ch0302
# title: chapter 3-2 # id: 0302

This is chapter 3 part two.... page 1
+ [next]
- This is chapter 3 part two.... page 2
+ [next]
- This is chapter 3 part two.... page 3
# finish: 0302
+ [next]

-> three

= three
~ current_loc = ch0303
# title: chapter 3-3 # id: 0303

This is chapter 3 part three.... page 1
+ [next]
- This is chapter 3 part three.... page 2
+ [next]
- This is chapter 3 part three.... page 3
# finish: 0303
+ [next] -> chend

= chend
~ current_loc = no_loc
# chapter 3-end
End of Chapter
// + next chapter -> ch2
// + [chapter index] -> index
+ [next] -> endstory

-> DONE

=== endstory ===
~ current_loc = no_loc
# end
End of Story
// + [restart?] -> index
-> END



