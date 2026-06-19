// test story by caitlyn pinkham 2026
// it's not really a story it's lorem ipsum ;)

// note this story uses only sticky options.

// tag notes:
    // deliminator in game is ": " space included. use after any of the below tags
    // tags don't need to be in any order, but where they are in the text DOES MATTER
    
    // can be used at top of knot or stitch:
        // setting: to change setting text label
        // image: changes the background image
        // music: changes music track, numerical, coincides w/ clips in game engine
    
    // must be used before **FIRST** choice in stitch:
        // title: for progress dictionary and timeline
        // id: for progress dictionary and timeline
    
    // must be used before **LAST** choice in stitch:
        // finished:  for progress array, dictionary, and timeline
        
        //you know, i don't like that


// index and chapter end sections are mainly for testing to navigate story at will


// why is this four lists? don't ask me i don't work here
// these tell the engine to record the body text while in one of these locations
// put them right under the string or knot name
LIST ch1_locations = ch0101, ch0102, ch0103
LIST ch2_locations = ch0201, ch0202, ch0203
LIST ch3_locations = ch0301, ch0302, ch0303
LIST non_locations = no_loc
VAR current_loc = no_loc

// story starts here

-> index

=== index ===
~ current_loc = no_loc
# setting: index # image: chinatown at night.jpg # music: 0

This  is the title :) hohoho { current_loc }
+ [go to chapter 1] -> ch1
+ [go to chapter 2] -> ch2
+ [go to chapter 3] -> ch3
+ [go to end?] -> endstory



=== ch1 ===
~ current_loc = no_loc
# setting: chapter 1 # image: ocean city new jersey.jpg  # music: 1
Chapter 1
+ [start ch1] -> one

= one
~ current_loc = ch0101
This is chapter 1 part one.... page 1

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas sem sapien, porta eu sagittis vehicula, tincidunt vitae augue. Fusce ligula libero, pretium ut magna ut, facilisis tristique mi. Nulla hendrerit nisi dolor, vitae tincidunt odio eleifend id. Integer semper, turpis quis viverra tincidunt, mauris nulla faucibus mi, nec aliquet nunc erat a neque. Maecenas eu hendrerit lacus. Pellentesque auctor suscipit eros, vitae semper enim bibendum vel. Mauris posuere tincidunt tempus. Quisque vel volutpat enim, non eleifend magna. Vestibulum tristique ullamcorper massa, eu maximus erat pellentesque in.

# title: chapter 1-1 # id: 0101
+ [next]

- This is chapter 1 part one.... page 2

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas sem sapien, porta eu sagittis vehicula, tincidunt vitae augue. Fusce ligula libero, pretium ut magna ut, facilisis tristique mi. Nulla hendrerit nisi dolor, vitae tincidunt odio eleifend id. Integer semper, turpis quis viverra tincidunt, mauris nulla faucibus mi, nec aliquet nunc erat a neque. Maecenas eu hendrerit lacus. Pellentesque auctor suscipit eros, vitae semper enim bibendum vel. Mauris posuere tincidunt tempus. Quisque vel volutpat enim, non eleifend magna. Vestibulum tristique ullamcorper massa, eu maximus erat pellentesque in.

+ [next]

- This is chapter 1 part one.... page 3

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas sem sapien, porta eu sagittis vehicula, tincidunt vitae augue. Fusce ligula libero, pretium ut magna ut, facilisis tristique mi. Nulla hendrerit nisi dolor, vitae tincidunt odio eleifend id. Integer semper, turpis quis viverra tincidunt, mauris nulla faucibus mi, nec aliquet nunc erat a neque. Maecenas eu hendrerit lacus. Pellentesque auctor suscipit eros, vitae semper enim bibendum vel. Mauris posuere tincidunt tempus. Quisque vel volutpat enim, non eleifend magna. Vestibulum tristique ullamcorper massa, eu maximus erat pellentesque in.

# finish: 0101
+ [next]

-> two

= two
~ current_loc = ch0102
# setting: chapter 1-2 has a new setting BOYS
This is chapter 1 part two.... page 1

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas sem sapien, porta eu sagittis vehicula, tincidunt vitae augue. Fusce ligula libero, pretium ut magna ut, facilisis tristique mi. Nulla hendrerit nisi dolor, vitae tincidunt odio eleifend id. Integer semper, turpis quis viverra tincidunt, mauris nulla faucibus mi, nec aliquet nunc erat a neque. Maecenas eu hendrerit lacus. Pellentesque auctor suscipit eros, vitae semper enim bibendum vel. Mauris posuere tincidunt tempus. Quisque vel volutpat enim, non eleifend magna. Vestibulum tristique ullamcorper massa, eu maximus erat pellentesque in.

# title: chapter 1-2 # id: 0102 
+ [next]

- This is chapter 1 part two.... page 2

+ [next]

- This is chapter 1 part two.... page 3

# finish: 0102
+ [next]

-> three

= three
~ current_loc = ch0103

This is chapter 1 part three.... page 1

# title: chapter 1-3 # id: 0103
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
# setting: chapter 2 # image: philadelphia skyline.jpg  # music: 2
Chapter 2
+ [start ch2] -> one

= one
~ current_loc = ch0201

This is chapter 2 part one.... page 1

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas sem sapien, porta eu sagittis vehicula, tincidunt vitae augue. Fusce ligula libero, pretium ut magna ut, facilisis tristique mi. Nulla hendrerit nisi dolor, vitae tincidunt odio eleifend id. Integer semper, turpis quis viverra tincidunt, mauris nulla faucibus mi, nec aliquet nunc erat a neque. Maecenas eu hendrerit lacus. Pellentesque auctor suscipit eros, vitae semper enim bibendum vel. Mauris posuere tincidunt tempus. Quisque vel volutpat enim, non eleifend magna. Vestibulum tristique ullamcorper massa, eu maximus erat pellentesque in.
# title: chapter 2-1 # id: 0201
+ [next]
- This is chapter 2 part one.... page 2

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas sem sapien, porta eu sagittis vehicula, tincidunt vitae augue. Fusce ligula libero, pretium ut magna ut, facilisis tristique mi. Nulla hendrerit nisi dolor, vitae tincidunt odio eleifend id. Integer semper, turpis quis viverra tincidunt, mauris nulla faucibus mi, nec aliquet nunc erat a neque. Maecenas eu hendrerit lacus. Pellentesque auctor suscipit eros, vitae semper enim bibendum vel. Mauris posuere tincidunt tempus. Quisque vel volutpat enim, non eleifend magna. Vestibulum tristique ullamcorper massa, eu maximus erat pellentesque in.
+ [next]
- This is chapter 2 part one.... page 3

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas sem sapien, porta eu sagittis vehicula, tincidunt vitae augue. Fusce ligula libero, pretium ut magna ut, facilisis tristique mi. Nulla hendrerit nisi dolor, vitae tincidunt odio eleifend id. Integer semper, turpis quis viverra tincidunt, mauris nulla faucibus mi, nec aliquet nunc erat a neque. Maecenas eu hendrerit lacus. Pellentesque auctor suscipit eros, vitae semper enim bibendum vel. Mauris posuere tincidunt tempus. Quisque vel volutpat enim, non eleifend magna. Vestibulum tristique ullamcorper massa, eu maximus erat pellentesque in.
# finish: 0201
+ [next]

-> two

= two
~ current_loc = ch0202

This is chapter 2 part two.... page 1
# title: chapter 2-2 # id: 0202
+ [next]
- This is chapter 2 part two.... page 2
+ [next]
- This is chapter 2 part two.... page 3
# finish: 0202
+ [next]

-> three

= three
~ current_loc = ch0203

This is chapter 2 part three.... page 1
# title: chapter 2-3 # id: 0203
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
# setting: chapter 3 # image: pittsburg 3 point park.jpg # music: 3
Chapter 3
+ [start ch3] -> one

= one
~ current_loc = ch0301

This is chapter 3 part one.... page 1
# title: chapter 3-1 # id: 0301
+ [next]
- This is chapter 3 part one.... page 2
+ [next]
- This is chapter 3 part one.... page 3
# finish: 0301
+ [next]

-> two

= two
~ current_loc = ch0302

This is chapter 3 part two.... page 1
# title: chapter 3-2 # id: 0302
+ [next]
- This is chapter 3 part two.... page 2
+ [next]
- This is chapter 3 part two.... page 3
# finish: 0302
+ [next]

-> three

= three
~ current_loc = ch0303

This is chapter 3 part three.... page 1
# title: chapter 3-3 # id: 0303
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



