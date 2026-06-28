# visual-novel-ink-test
Creating a framework for a visual novel using Godot and ink


some credits

- https://github.com/ephread/inkgd is the addon used and does the heavy lifting. was i supposed to fork this? i don't know enough to know if i'm doing this correctly... anyway, the addon was not in the AssetLib so i had to manually install it for some reason.

- all the pictures were taken by me.

- https://www.lipsum.com/ for the filler text.

- https://www.beepbox.co/ was used to make the (admittedly terrible) music.

- i followed this youtube series by Nicholas O'Brien: https://www.youtube.com/watch?v=OtTezJZTuy4

it's an older version of godot so some things didn't work. namely, the templates.
but he was kind enough to leave this link in response to a comment:
https://github.com/averyhiebert/inkgd/tree/godot4-updatetemplates/addons/inkgd/editor/templates

they didn't work out of the box, i had to create a subfolder /Nodes/ then i was able to use the them.


notes for me who comes after

keywords in comments:
- UNIQUE: variable/path will vary per project
- RESERVED: don't accidentaly use this name/var/whatever elsewhere
check the notes at the beginning of the ink for reminders on related to ink strategy

minimal work has been done on the UI on purpose, so that when this template/framework is used in a final project, it doesn't need to be picked apart and rebuilt.
as a result, the scene tree is kindof a mess. forgive me, i'm new at this.

the progress tracking has become a little convoluted. i would like to think of a better way to record how far the reader has come and specifically which passages the reader has encountered.
the issue is communicating from ink to godot where the reader is.
