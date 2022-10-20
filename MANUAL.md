# Just Shapes Or Beats Manual

![Just Shapes Or Beats Logo](/images/logo.png)

Welcome to the Just Shapes Or Beats user manual! This manual will tell you how to create custom levels and hazards in the game.

## Getting Started

Before you can start creating levels, you must download the source code and install Godot, the engine used to create this game.

1. To download the .zip file containing the source code, go [here](https://github.com/TamerSoup625/just-shapes-or-beats), then click on Code-\>Download ZIP. You don't have to extract it, it will be done by the engine.
1. Download the standard version of Godot [here](https://godotengine.org/download)
1. Open Godot
1. In Godot, click on Import
1. Select the .zip file you downloaded on step 1 as the project path
1. Select an empty folder as the install path
1. Click "Import and Modify"
1. Done! Now we can start!

## Making levels

### The basics

This part will tell you how to make levels with the Godot Editor. You should be able to do it even if you can't code, but if you want to make custom hazards, go to the paragraph "Making custom hazards".
As of now, there isn't a proper level editor; it mostly relies on the Godot Editor. Making levels will be much easier if you're familiar with the Godot Editor

1. Create a new LevelStruct (Level Structure, holds all the elements of the level) resource with the FileSystem at res://resources/level_structs/songs/:
    1. Use the FileSystem dock (On the bottom-left) to go to the filepath. You can open the folders like how you would in a file explorer or use the search bar.
	1. Right click to open menu, then select "New Resource..."
	1. From there, select the LevelStruct resource from the menu by searching it in the bar at the top
	1. From the menu that appeared, name your level struct and click "Save" (It is suggested to name your level struct to the name of the song)
    Now that we have the level struct, you should see a list of options at the Inspector dock (on the right). If it disappears, you can get it back by double-clicking on the level struct you created on the FileSystem.
1. But before we do anything, we want for the level to show in the game. To do so, go to the level struct list resource at res://resources/level_structs/level_struct_list.tres (use the same procedure of before) and add both the level struct and an unique identifier
	1. Now you should have something saying "Struct List" and "Struct Uid"
	1. Click on the button near the text "Struct List"
	1. Add an element to the list by clicking on the up button on the same line as the "Size" text
	1. Drag your level struct file to the \[empty\] panel that just appeared by adding an element
	1. Click now on the button near the text "Struct Uid" and add an element to the list
	1. Write on the empty line edit an unique name
    Now if you try to run the project (Play button on the top-right) and click "Play" in the game, you should see your track. If you try to play it at the moment it will stop by an error, but now we can go create the level itself.
1. Go to the level struct via the FileSystem dock you just created and look at the Inspector dock. You will see various properties of the level script. Here is an explanation of what these do:
    + **Song**: The song itself, played when you play the level. To add the song to the level struct, add a music file (.mp3, .wav etc.) to the project folder and then add it to the song property by using the dropdown menu by clicking on the panel or by drag-and-dropping it from the FileSystem dock.
	+ **Song Name**: The name of the song that will appear when playing the level.
	+ **Song Artist**: The name(s) of the composer/remixer of the song.
	+ **Song Is Remix**: If checked, the song will be seen as a remix made by *Song Artist*.
	+ **Song Playlist**: The name of the playlist the song comes from.
	+ **Song Cover**: An image showing the cover of the playlist. You can add the song image using the same procedure for the song.
	+ **Playback Pos**: When playing the song thru the playlist, the song will start from this position in seconds and play in loop for 15 seconds. Note that it does ***not*** modify the starting position of the song when playing the level. If playing the level, the song will ***always*** start from the beginning.
	+ **Key List**: Contains the list of all the level keys of this level, ordered by time. See the paragraph "Level Keys".
	+ **Checkpoints**: Contains a list of real numbers in order, indicating the time in seconds at which checkpoints will appear. Checkpoints will make you respawn after four seconds the time they appear if you die, use this as a reference for placing checkpoints. The last checkpoints indicates the end of the level, that's why an error will be thrown if this list is empty. An error will also be thrown if the numbers are not in order.
	+ **Hazard Group List**: Contains a list of HazardGroup resources, for making hazard groups. See the paragraph "Hazard Groups".
	+ **Is Hardcore**: Indicates whether the level is normal or hardcore. See "Hardcore Variant".
	+ **Other Variant**: A path to the hardcore or normal variant of this level. See "Hardcore Variant".
1. It may happen that when changing something in the level struct, nothing changes when playing the level. This is a known bug. To make changes apply, click on the save icon on the Inspector dock at the top, then click "Save". Now the changes should apply successfully.

### Level Keys

Now that you know the basics, we can start adding hazards into the game.
Hazards and more are added by using level keys. Level keys are resources that all have a time property. When the song is at the time in seconds specified, an action in the game will happen. This action can be creating an hazard but also making a screen shake or creating some hazards in sequence.
These keys are in the *Key List* property of the level struct, ordered by time. If they are ordered incorrectly, an error will appear once you play the level.
Some level key properties accept text, while the value may require something like a number. These are *expressions*, they are explained in the "Expressions" paragraph.
Level keys inherit from the class BaseLevelKey. Here are the level keys that inherit from them, with explanation of their properties:
+ **BulletLevelKey**: Creates a bullet. Bullets are simple hazards that move with constant speed or oscillate back and forth.
	+ *Type*: Indicates the look of the bullet, also affecting its collision.
	+ *Bullet Or Floor*: Indicates whether the bullet is an actual bullet or a dance floor. A bullet appears immidieatly and will stay until it goes off-screen, a dance floor instead can warn for a certain amount of time and then stay as an hazard for a certain amount of time. Also see "Dance Floor Warn Time" and "Dance Floor Here Time"
	+ *Position X/Y*: An expression indicating where the bullet should spawn. For reference, the top-left corner is coordinate (0, 0), while the bottom-right corner is coordinate (1024, 600).
	+ *Speed X/Y*: An expression indicating the speed of the bullet, in pixel per second. For reference, the player's normal speed is 175 px/s and its dash speed is 577.5 px/s.
	+ *Size*: Expression indicating the size of the bullet in pixels.
	+ *Rotation Degrees*: Expression indicating the base rotation of the bullet in degrees.
	+ *Torque Degrees*: Expression indicating the rotation speed of the bullet in degrees per second.
	+ *Sin X/Y*: If either *Sin X* or *Sin Y* is not zero, the bullet will be spawned with an offset following the sine function and oscillate if *Sin Freq* is not zero. If both are not zero, the bullet will rather follow a circular or elliptic path. Aslo see the other *Sin \** properties.
	+ *Sin Freq*: The frequency of the oscillation or circular movement based on the *Sin X/Y* property, in Hertz/Tau (A value equal to 2\*PI will do a complete oscillation in one second.)
	+ *Sin Lifetime*: An expression indicating the offset of the oscillatory/circular movement of the *Sin \** properties.
	+ *Sin Rotates*: If checked, the oscillatory/circular movement is relative to the bullet's rotation.
	+ *Dance Floor Warn Time*: If the bullet is a dance floor, indicates the time for the dance floor to appear in seconds, giving a warning before it does. The dance floor will start its warning based on the time, and actually appear based both on the time and this property.
	+ *Dance Floor Here Time*: If the bullet is a dance floor, indicates the time the dance floor stays as an hazard in seconds, from the moment it appears and is dangerous. If this property is set to zero and the bullet is a dance floor, the dance floor wll not deal damage.
	+ *Drawing Extra*: Array that should contain only one value, adding extra info to the way the bullet is drawn. As of now, only one type of bullet requires extra info:
		+ *Square With Stripes*: Drawing Extra must be a float, indicating how many stripes the square should have. A non-integer value can be used for extra modifications. Here are some examples for understanding how this works:
			+ Drawing Extra is 1 -> Looks the same as a bullet with type Squares.
			+ Drawing Extra is 1.5 -> Bullet is made up of a pink square and a black square that is one third the size of the other one.
			+ Drawing Extra is 2 -> Bullet is made up of a pink square and a black square that is half the size of the other one.
			+ Drawing Extra is 2.5 -> Bullet is made up of a pink square, a black square that is three fifths the size of the other one, and a pink square a fifth the size of the bigger one.
			+ Drawing Extra is 3 -> Bullet is made up of a pink square, a black square that is two thirds the size of the other one, and a pink square a third the size of the bigger one.
			The way it works may seem weird, but you can understand it better by looking at the source code.
+ **NodeSpawnLevelKey**: Base class used to create BaseHazard nodes. This is an abstract class, its subclasses are actually used to create nodes.
	**Properties:**
	+ *Spawn Time Offset*: The time in seconds after which the hazard will usually actually appear and be dangerous. The hazard will start its warning based on the time property, and actually appear based both on the time and this property.
	+ *End Time Offset*: The time in seconds the hazard will usually stay as a danger, after which it disappears.
	+ *Position X/Y*: An expression indicating the position the hazard should spawn. For reference, the top-left corner is coordinate (0, 0), while the bottom-right corner is coordinate (1024, 600).
	Internally, the resource has also a `scene` and an `extras` property. The `scene` property is a PackedScene that is instanced when the key is reached, and the `extras` property is a dictionary used to modify the hazard's properties. Each key must be a string and each value must be an expression, unless the key starts with "\_\_". For each key/value pair, the property with the name of the key will be set to the value, unless the key starts with a double underscore, in which case the value is not seen as an expression, but an actual value, and the property will be set to the value. You can also use indexed path by starting the key with a colon ":". All NodeSpawnLevelKey subclasses usually have a way to access these properties.
	**SubClasses:**
	+ **BulletPulseLevelKey**: Creates a ring of bullets instantaneously, each moving in a direction with constant difference in angle. The spawn and end time offset do not modify the key's behaviour.
		+ *Base Rotation*: Expression for the starting rotation of the bullet pulse, in radians. Indipendently of the amount, a bullet will always move in this direction.
		+ *Amount*: The amount of bullets that will be created.
		+ *Bullet Type*: Indicates the fired bullets' type.
		+ *Bullet Speed*: Indicates the fired bullets' speed.
		+ *Bullet Size*: Indicates the fired bullets' size.
		+ *Bullet Extras*: A dictionary indicating the bullet's extras. The keys indicate the name of the extra, while the values are expressions indicating the value unless the key starts with a double underscore, in which case the value is a normal value. Most of them are the same of BulletLevelKey's properties, but in snake_case (lowercase letters, with underscores instead of spaces), except for *Rotation/Torque Degrees*, which is just rotation or torque, but in radians. See the source code in "res://scenes/low_level_hazards.gd" on function "create_bullet" for more.
	+ **BulletSpinnerLevelKey**: Creates a continuos certain number of spirals of moving bullets, with each bullet moving in a direction with a constant offset from the last one. The spawn and end time offset do not modify the key's behaviour.
		+ *Base Rotation*: Expression for the starting rotation of the first spinner, in radians. Indipendently of the amount and spin count, the first bullet of a spinner will always move in this direction.
		+ *Amount*: The amount of bullets each spinner will create.
		+ *Torque*: The difference of angle between a spinner's bullet and the next one, in radians. A positive value makes the spinner move clockwise, a negative one counterclockwise.
		+ *Time Offset*: The interval between a spinner's bullet being fired and the next one, in seconds. An interval of 0 or lower will fire all bullets at the same time.
		+ *Spin Count*: The amount of spinners that will be created. Each spinner creates a spiral of bullets.
		+ *Bullet Type*: Indicates the fired bullets' type.
		+ *Bullet Speed*: Indicates the fired bullets' speed.
		+ *Bullet Size*: Indicates the fired bullets' size.
		+ *Bullet Extras*: A dictionary indicating the bullet's extras. The keys indicate the name of the extra, while the values are expressions indicating the value unless the key starts with a double underscore, in which case the value is a normal value. Most of them are the same of BulletLevelKey's properties, but in snake_case (lowercase letters, with underscores instead of spaces), except for *Rotation/Torque Degrees*, which is just rotation or torque, but in radians. See the source code in "res://scenes/low_level_hazards.gd" on function "create_bullet" for more.
	+ **CustomNodeLevelKey**: Gives direct access to the `scene` and `extras` internal properties. This can be used to quickly test an hazard. See NodeSpawnLevelKey-\>end of "Properties" list.
	+ **LaserLevelKey**: Creates a common laser that goes across the whole screen. The spawn and end time offset modify the effect of the hazard. An end time offset of 0 will not damage the player when it fires.
		+ *Size*: The thickness of the laser, in pixels.
		+ *Direction Degrees*: The direction the laser will travel, in degrees. Right direction is 0° and higher values go clockwise.
		+ *Shake*: If checked, the laser will shake a little when being fired.
	+ **PulseBombLevelKey**: Creates a common pulse bomb that eases into the screen, stop, and then explode and release bullets in a circle. The spawn time offset indicates the time it takes for the pulse bomb to ease into the position to travel to and the end time offset the time it will stay in place. A spawn and end time offset of 0 can be used to create only the bullets.
		+ *Travel X/Y*: Expression indicating the relative position the pulse bomb will ease to. For reference, the top-left corner is coordinate (0, 0), while the bottom-right corner is coordinate (1024, 600).
		+ *Amount*: The amount of bullets that will be released when the pulse bomb explodes. A value of 0 can be used to fire no bullets.
		+ *Speed*: The speed of the fired bullets.
		+ *Base Rotation*: Expression for the starting rotation of the fired bullets, in radians. Independently of the amount (unless it is 0), a bullet will always fire in this direction.
		+ *Bullets Spin*: If checked, bullets will spin a little in circle on themselves.
	+ **TrackLevelKey**: Creates a common track made up of multiple dance floors, appearing sequencially, to give an effect of a moving trail. The spawn and end time offset change the dance floors' warn and here time.
		+ *Type*: The bullet type of the created dance floors.
		+ *Create Time*: The difference in time between a dance floor being created and the next one, in seconds.
		+ *Create Times*: How many dance floors are created in total. If -1, it will keep creating dance floors until it leaves the screen. Create times of -1 may create problems if the track follows a very curved trajectory, since it may never despawn or leave the screen, or it may be excepted to go off-screen and then re-enter it, while it rather reaches the despawn area and it does not.
		+ *Speed X/Y*: Expression indicating the difference of position between a dance floor and the other one, in pixels. The expression will only be executed once and then the result memorized.
		+ *Size*: The size of the dance floors, in pixels.
		+ *Rotation*: Expression indicating the direction the track will move to, in radians. Right direction is 0° and higher values go clockwise. Also modifies the dance floors' rotation.
		+ *Torque*: Expression indicating the rotation applied to the track after each dance floor, in radians. Also modifies the dance floors' rotation.
		+ *Auto Despawn*: If checked, the track will despawn automatically when going off-screen. If not checked and "Create Times" is set to -1, the track will never despawn, negatively affecting performance.
		+ *Sin X/Y*: Sets the dance floors' sin x and y properties. See BulletLevelKey-\>"Sin X/Y".
		+ *Sin Freq*: Sets the dance floors' sin frequence property. See BulletLevelKey-\>"Sin Freq".
		+ *Sin Lifetime Base*: Expression indicating the base lifetime value of the dance floors. The first dance floor will always have this as sin lifetime. See BulletLevelKey-\>"Sin Lifetime".
		+ *Sin Lifetime Multi*: Indicates the difference of sin lifetime between each dance floor. See BulletLevelKey-\>"Sin Lifetime".
		+ *Sin Rotates*: Sets the dance floors' sin rotates property. See BulletLevelKey-\>"Sin Rotates". This is useful if the track is going in a direction that's not orthogonal or has a torque.
		+ *Dna Couple*: If checked, a copy of this track with inverted sin x and y will be created when this track is created, creating a DNA effect.
	+ **WallLevelKey**: Creates a common wall, easing into the screen and showing a warning and then moving across the screen.
		+ *Size*: Expression indicating the size of the wall, in pixels.
		+ *Direction*: The direction the wall moves into the screen. If set to "Use Expression", the direction will be based on *Direction Expr*
		+ *Direction Expr*: Expression indicating the direction the wall moves into the screen, if *Direction* is set to "Use Expression". A value of 0 indicates the right direction, 1 indicates down, 2 indicates left, and 3 indicates up.
		+ *Peek Lenght*: The space the wall eases into the screen before moving across the screen, in pixels.
		+ *Show Warning*: If not ticked, the warning shown across the screen is not visibile. The wall will still ease into the screen, so the wall still warns abuot itself in a way.
	+ **CamPushLevelKey**: Pushes the camera a little towards a direction in a small amount of time. Some hazards shake the camera automatically.
		+ *Vector*: The offset the camera will reach when the movement is at its peak, in pixels. You can also see it as the direction and intensity of the push.
	+ **GroupLevelKey**: Creates a predefined hazard group. See the paragraph "Hazard Groups" for more info.
	+ **SequenceLevelKey**: Creates a sequence of hazards or other level keys. See the paragraph "Sequence of Keys" for more info.
	+ **ShakeLevelKey**: Shakes the camera for a certain amount of time.
		+ *Force*: The intensity of the shake. At the start, the camera will move in a random position inside an imaginary square of size the double of force.
		+ *Duration*: The duration of the shake, in seconds. The end of the shake may not be in sync with the music.
		+ *Decay*: If ticked, the shake will gradually lose intensity until it reaches a value of 0.
	+ **TestLevelKey**: Prints text. That's it.
		+ *Text*: The text to print.

### Music Guides

For a rhythm game, it is important the visual is in sync with the music. For this, the level editor comes with a nice pulgin for music guides.

The music guides are placed on the bottom panel, on the button named "Music Guides". Click it to open the music guides.
To set the song, drop the song file from the FlieSystem to the text saying the song path or click the "Load AudioStream..." button.
You can use the spin box on the bottom-right to set the song BPM to have more precise guides. This doesn't have to be the precise BPM, you can use a multiple or sub-multiple of it to have mid-measure guides or use a very high number to pretty much disable this feature.
Now that the song and BPM are set, you can press on the Play "\>" button and then click on the big button to add a guide. Use the pause "\|\|" button to pause the song.
After setting the guides, you can test these guides an possibly place them better using the controls at the far bottom.
Once you've done precisely setting the guides, you can copy them to the clipboard with the "Clipboard" button and clear the memorized guides with the "Clear" button.

It is suggested to first get the guides you want for a part of the level and then create part of the level itself.

### Cheats

Testing is an important part of making a level. But, to test a later part of a level, you'd normally have to play all of it, highly slowing the testing process. This is why the debug version has some cheats to speed up development time.
Here is the list of all the usuable cheats. Obviously, they can only be used with the deubg version.
+ Go to time ("G" key): Pressing it will pause the game and show a line edit on the top-left corner. Here you can type a number and, after pressing enter, the track will skip to the entered number, in seconds. Using it more than one time on the same level may break stuff.
+ Speed up (Keypad plus or Shift + P): Double the speed of the music. This can be pressed more than one time.
+ Slow down (Keypad minus or Shift + M): Halves the speed of the music. This can be pressed more than one time.
+ Normal speed (Keypad enter or Shift + N): Reverts the speed of the music back to normal.
+ Full HP ("H" key): Restore the players' health.
+ Self rescue ("R" key): Rescue the first player by himself.
+ Debug restart (BackSpace): Restart to the last checkpoint. Hold to restart from the beginning.

### Expressions

Expressions are a very useful tool for making levels. An expression is basically a mathematical expression which can be used to get an higher control about the keys' properties.
For evaluating the expressions, the game uses Godot's **Expression** class. You can search about this to know more information about how it works and what can be done with it.
A plugin is also made to evaluate these properties directly in the editor. It is the "ExpressionEval" dock, you can directly write expressions in it and it will give you the result of the expression, or an error if there's one.
An example of an expression is "20 + 10\*2 - 5/2.0". The basic operations are:
+ *Addition*: "+" Can also be used to concatenate strings and arrays.
+ *Subtraction*: "-"
+ *Multiplication*: "\*"
+ *Division*: "/" Remember the result will be an integer if both operands are considered integers. Add a zero after dot to indicate a float value (e.g. "25.0")
+ *Modulo*: "%" For integers only. Use the "fmod" or "fposmod" function for floating point modulo.

Spaces between operators are optional. Keep in mind the usual [order of operations](https://en.wikipedia.org/wiki/Order_of_operations) applies. You can use parenthesis to override the order of operations.
An expression can also do operations for any other type of values, such as booleans (true/false) or strings of text.
Sometimes, expressions can have some variables as an input. These can be accessed with the name of the variable itself (e.g. "i % 5" will give the remainder of the variable "i" divided by 5)
Expression can also contain Godot's built-in methods. You can find most of the usuable built-in methods [here](https://docs.godotengine.org/it/stable/classes/class_%40gdscript.html). Methods are called with their name followed by parenthesis and possible arguments (e.g. "rand_range(-100, 100)" or "randi()").
The most common methods are [rand_range](https://docs.godotengine.org/en/stable/classes/class_@gdscript.html#class-gdscript-method-rand-range) and [randi](https://docs.godotengine.org/en/stable/classes/class_@gdscript.html#class-gdscript-method-randi), which are very useful for making ranodmized hazards.
This game also has a custom method *if3*. It accepts three arguments: if the second value returns *true*, then the method will return the first value, or else it will return the third. This is an alias to Godot's [ternary if](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#if-else-elif).
Some common operators for booleans (true/false) are:
+ *Equal to*: "=="
+ *Greater than*: "\>"
+ *Lesser than*: "\<"
+ *Greater or equal than*: "\>="
+ *Lesser or equal than*: "\<="

Here are some of the most common expression snippets. These snippets can also be combined for more complex behaviour.
+ "rand_range(a, b)": Returns a random real number between *a* and *b*.
+ "randi() % a": Returns a random integer between 0 and (*a* - 1).
+ "a + b \* x": Considering *a* and *b* constants and *x* a variable, this snippet is very useful for placing a sequence of hazards with a constant offset with SequenceLevelKey.
+ "if3(x, c, y)": General ternary if method. If *c* is true, the snippet will give *x* as a result, else it will be *y*.
+ "true": For a property that can be checked or not, indicates the property is checked.
+ "false": For a property that can be checked or not, indicates the property is **not** checked.
+ ""a"": Indicates an actual string. Since expressions are strings and do not directly accept numbers, use this if setting a value of an expression, since it reads the actual written text on *a*.
+ "str(a)": Use this if setting a value of an expression based on variables. Rather than ""a"", the expression *a* will be executed and then turned into a string.
+ "\[a0, a1, a2, ..., an\]\[i\]": If *i* is 0, returns *a0*, if it's 1, returns *a1*, if it's 2, returns *a2* and so on. The triple dots only indicates that this pattern can repeat. An example of this is "\[2, 4, 1, 3\]\[i\]" or also "\[6, 3\]\[i\]".
+ "b \* floor(a / b)": Returns *a* decreased to the lowest multiple of *b*. Make sure *b* is a floating point value. Works great with "a % b".
+ "stepify(a, 2)": Simpler version of the snippet above. Since this rather **rounds** *a* to the closest value, it only works correctly with "2" as the second argument of the function.
+ "Vector2(x, y)": Creates a Vector2 value type, with *x* and *y* as coordinates. This can be useful as some properties use this type of value.
+ "PI": The mathematical constant pi.
+ "TAU": The lesser-known mathematical constant tau, equal to the double of pi.
+ "\[a\]": To use with BulletLevelKey's `drawing_extra`.

### Sequence of Keys

Sometimes you may want to have a bunch of keys being executed in different times with something in common. For this, the SequenceLevelKey can be used.
The key property is the level key that must be repeated in sequence. It can be any level key, even another SequenceLevelKey.
The time modifier tells the difference in time between the various level keys that will be made. It is an expression which uses the *i* variable to differientate between the various level keys that will be made. The first level will have as time the value of the expression with *i* set as 0, plus the time of this SequenceLevelKey; the second will have the same, but with *i* as 1.
Since, to the result of the expression, it is added this level key's time value, you don't have to add the time to the expression manually. Also note that, if the expression will give a negative result, the key will be executed at the time equal to this SequenceLevelKey's time property, since the level key will only create the others when it is executed and it would add a key with time lower than the current track's time.
Rather than always having to make an expression, you can check the property *Is Time Modifier Xi* and the level key will automatically multiply the result of the expression by *i*. However, if it is checked, you can't use *i* in the expression itself.
You can use the *Modifiers* property to make each generated level key different to the other. This property is a dictionary with strings as keys and mostly strings read as expressions as values.
The dictionary keys do not use the name of the property used in the inspector, but rather its raw name. It is pretty much the normal name, but in snake_case (lowercase letters, with underscores instead of spaces).
The keys of the dictionary are names of the property of the key to create in sequence, possibly starting with "\_\_" or ":".
If the dictionary key does not start with "\_\_", its corresponding value is an expression "string" which indicates the value of the property. You can use *i* to differientate between the various level keys that will be generated, it works the same way as the time modifier.
If the dictionary rather starts with "\_\_", its corresponding value is a direct value, indicating the value of the level key's property.
To use NodePaths for accessing properties, start the dictionary key with ":" (e.g. ":position:x").
The level key will work incorrectly if you use this to modify the key's time. For this, rather use *Time Modifier*
Finally, the *Times* property indicates how many level keys will be created.

### Hazard Groups

Other times, you rather want to have reuse the same configuration of hazards more times, or a sequence of the same hazards. For this, you can use the HazardGroup and GroupLevelKey resources.
You first have to make the group of keys themselves. For this, add a new HazardGroup resource as an element of the LevelStruct's *Hazard Group List* array. The HazardGroup resource is **not** a level key and can be used only inside this array.
The level keys themselves are in the *Keys* Property of the HazardGroup, here you can add any level key, even another GroupLevelKey as long as it doesn't call itself recursively.
You can add inputs to create the same hazard group, but with some differences. You first have to add the names of the input variables in the *Inputs* array, and then use the *Modifiers* array to change the keys based on the inputs.
The modifiers work simirarly to the SequenceLevelKey's *Modifiers*, however you can't use "\_\_" or ":" to modify the behaviour and you must specify which key must be modified.
The keys of the *Modifiers* dictionary are strings in the format "index.property", where *index* is the element of the *Keys* array that must be modified (The first key is 0, the second is 1 and so on. Seen as a number near the level key in the inspector) and *property* is the name of the property to modify. You can use NodePaths as well without having to add special characters, unlike SequenceLevelKey.
The values of the *Modifiers* dictionary are rather strings as expressions. The expressions will then be executed and the properties will be set to their result based on the dictionary's keys. You can use the defined *Inputs* names as variables. These will be set as the expressions' input variables when executed, so you can modify the level keys based on the inputs.
You can also use the modifiers to set the keys' time. To the keys' time, it will be always added the GroupLevelKey's time.
After creating the HazardGroup, you can create the hazard group with GroupLevelKey.
The GroupLevelKey's *Index* property indicates the HazardGroup to create. A value of 0 will get the first HazardGroup in the LevelStruct's *Hazard Group List* array, a value of 1 the second and so on.
You **must** give the HazardGroup's input variables as the *Inputs* property. For each key of the *Inputs* dictionary property, you give the input variable's name. As values, you rather give an expression indicating the value of the variable.
You can use hazard groups to share RNG between level keys. Simply give a randomized value as one of the inputs. The randomization is only called once, so it is shared on all the modifiers.

### Hardcore Variant

If you saw all the paragraphs before this one, you should be able to make levels with the pre-made hazards. But at the moment only the normal variant of the level works, trying to play the hhradcore one will result in an error. In this paragraph we will see how to make the hardcore variant of a level.
Before making the hardcore variant, it is suggested to first create the normal one and be satisfied with it. This is because, if you would want to change something on the levels, you'd have to modify both.
We first have to make a duplicate of the level struct resource. This can be done by right-clicking the level struct in the FileSystem and then clicking on "Duplicate...".
After this, you should have a window where you give a name to the duplicate. It is reccomended to give it the same name of the other level struct, but with "\_h" at the end of the name.
Now we have to link these level structs. On the normal variant, set the *Other Variant* property to the path of the hardcore one (It can be copied from the FileSystem with right click on file-\>Copy Path). On the hardcore variant, check the *Is Hardcore* property and set the *Other Variant* property to the path of the normal one.
Now you should be able to play the hardcore variant from the menu. After you did everything, you can modify the hardcore variant of the level to make it harder.

## Making Custom Hazards

If you saw all the paragraphs before this one, you should be able to make complete levels with the pre-made hazards. But at the moment there aren't many hazards. However, if you have experience with the Godot Engine, creating custom hazards should be easy.
Note that ***You should have experience with Godot Engine to create custom hazards***. If you don't have any, it is reccomended to first know how to use Godot Engine.
If you rather have at least some experience with Godot, then we can start!

### The BaseHazard class

All node-based hazards (like lasers, pulse bombs and tracks) inherit from the BaseHazard class, which extends the Node2D class. This can be used to make custom hazards as well.
Start by creating and saving a new scene with the BaseHazard class as root node. Node hazard scenes and scripts are usually saved in "/scenes/hazards".
You can create node hazards with level keys inheriting NodeSpawnLevelKey. For testing the hazard, you can use the CustomNodeLevelKey class by setting `scene` to your custom hazard's PackedScene and `extras` with expressions indicating the properties to modify. We'll see later how to create a custom NodeSpawnLevelKey resource. Also see "Level Keys"-\>NodeSpawnLevelKey and CustomNodeLevelKey.
For making the hazard warn at the start and then appear and disappear in sync with the music, you can use the overridable functions `_spawn` and `_end`.
`_spawn` will be called when the hazard should actually appear and become dangerous. This is called in sync with the music after the time in seconds indicated by the level key's spawn time offset has passed.
`_end` will be called when the hazard should disappear. This is also called in sync with the music after the time in seconds indicated by the sum of the level key's spawn time offset and end time offset has passed.
You can also get direct access to the level key's spawn and end time offset with the properties `spawn_time_offset` and `end_time_offset`. Note that they're intended to be read-only. Modifying these will not change the moment `_spawn` and `_end` are called.
The NodeSpawnLevelKey can also set the BaseHazard node's position into a place where it should spawn. If you don't want your hazard to be moved, you can set its position to `Vector2.ZERO` at the start or also read the position before doing so to have a pseudo-position the level creator can set with the level key.
For handling collisions, you can use an Area2D with the default collision layers or use the overridable method `_is_player_hit`.
This method is called for every player at every physics frame with as only argument the player it is called for and the method must return a boolean value. By default, it always returns `false`.
If `true`, the player is considered as "hit" and can get damaged if not dashing or not invincible. If `false`, the player is not considered as "hit" and is always safe.
The Player class inherits Area2D and is a shape controlled by a player. We won't go too deep with the Player class, just know you can use the `position` property of Node2D to check whether the player was hit or not.
To make the hazards feel fair, the player's collision is simplified as a point. This should also be considered when using the `_is_player_hit` method, plus it also makes collision checking easier as you only have to consider a point (for example, you can use an image for collision checking and use [built-in methods](https://docs.godotengine.org/it/stable/classes/class_sprite.html#method-descriptions) to verify if the collision happened, stuff which would be very complicated if the player's collision box was considered a circle).

### Creating bullets from code

Sometimes, you may want BaseHazard nodes to create bullets. They are not nodes that exist in the SceneTree, they are rather managed by the LowLevelHazard node.
You can access this node using the GameMethods singleton. It contains methods any Object can link their methods to.
Use the expression `GameMethods.get_lo_lev_haz` to get the LowLevelHazard node and use its function `create_bullet` to create bullets.
The function `GameMethods.create_bullet` wants five arguments and accepts an extra one.
The first argument is the type of bullet, which is an integer enum `LowLevelHazard.BULLET_*`.
The second one is a bool and tells if the bullet is a dance floor or not. If `true`, it is considered a dance floor which warns itself, appears and then disappears after a certain time. If `false`, it is considered a bullet which spawns immidieatly and despawns when it goes off-screen.
**Dance Floors require a time key in the dictionary of extras** (the last normally optional dictionary). This indicates the current song time which you can get with `GameMethods.get_current_time()`.
The third one (Vector2) indicates the position of the bullet, in global coordinates.
The fourth one (Vector2) is the speed of the bullet, in pixels per seconds.
The fifth one (float) indicates the size of the bullet, in pixels.
The last is an optional dictionary. It can be used to indicate extra properties of the bullet. Each key is any of the extra properties and its corresponding value is the value of the extra property.
Here is a list of all the extra properties:
+ `rotation` (float = 0.0): The base rotation of the bullet, in radians.
+ `torque` (float = 0.0): How fast the bullet spins on itself, in radians per seconds.
+ `sin_x` (float = 0.0): If not 0, the bullet will position itself or oscillate along the X axis following a sinusoide, with amplitude based on this extra property. You can also use `sin_y` to make the bullet follow a circular or elliptic path. Also see the other `sin_*` functions.
+ `sin_y` (float = 0.0): If not 0, the bullet will position itself or oscillate along the Y axis following a sinusoide, with amplitude based on this extra property. You can also use `sin_x` to make the bullet follow a circular or elliptic path. Also see the other `sin_*` functions.
+ `sin_freq` (float = 0.0): The frequency of the oscillation or circular movement based on the `sin_x` and `sin_y` properties, in Hertz/Tau (A value equal to `2*PI` will do a complete oscillation in one second.)
+ `sin_lifetime` (float = 0.0): Indicates the offset of the oscillatory/circular movement of the `sin_*` properties.
+ `sin_rotates` (bool = false): If `true`, the oscillatory/circular movement is relative to the bullet's rotation.
+ `auto_despawn` (bool = true): If `true`, the bullet will automatically despawn if it goes off-screen. This should be used with dance floors, as bullets can't despawn based on a timer.
+ `wind_affected` (bool = true): If `true`, the bullet is affected by wind.
+ `drawing_extra` (Variant = null): An extra value used by certain bullet types, modifying the bullet's look. See BulletLevelKey-\>Drawing Extra.
+ `animation_time` (float = 0.1): The lenght of the appear and disappear animations, in seconds.
+ `warn_time` (float = 0.0): For dance floors, the time it will spend warning about itself, in seconds. A value of 0.0 will skip the warning animation.
+ `here_time` (float = 0.0): For dance floors, the time it will spend staying as an hazard that can hit the player, in seconds. A value of 0.0 will make the dance floor unable to hit the player.
+ `time` (float, no default value): For dance floors, the current song time, in seconds. **This property must be added if the bullet is a dance floor.** You can use `GameMethods.get_current_time()` to get the current song time.

### Camera effects and screen flash

To give "juice" to the hazards, you can add effects to the camera or flash the screen.
You can add two camera effects: the push and the shake. The push moves the camera in a direction for a short time, and the shake shakes the camera for a certain amount of time.
To create these camera effects, you use the GameMethods functions `GameMethods.camera_push(vec: Vector2)` and `GameMethods.camera_shake(force: float, time: float, decay: bool = true)`.
For `GameMethods.camera_push`, the only argument indicates where and how far the camera should move, in pixels. You can also see it as both the direction and intensity of the push.
For rather `GameMethods.camera_shake`, the first argument indicates the intensity of the shake. At the start, the camera will move in a random position inside an imaginary square of size the double of force.
The second one rather indicates the lenght of the shake, in seconds.
Lastly the third optional one indicates whether the shake "decays" or not. If `true`, the intensity of the shake will decrease over time all the way to zero. If `false`, the intensity stays the same.
For rather flashing the screen, you use the method `GameMethods.screen_flash(time: float = 0.1, intensity: float = 1.0)`. When the screen flashes, it becomes all white and then fades into normal.
The first argument indicates the lenght of the flash. It is usually short.
The second indicates how "bright" the screen should become. A value of 1 colors the whole screen white, while a value of 0.6 turns the screen with a color mixed with 60% white and 40% the normal color. This effectively decreases the intensity of the flash by 40%.
Both arguments are optional. The camera effects may not happen based on accessibility settings.

### Photosensivity mode (and more accessibility settings)

It is important the game is accessible to everyone. For this, the game has a photosensivity mode.
You can check if it is active with `GameSettings.photosens_mode`. If `true`, the photosensible mode is enabled, `false` if otherwise (default).
Note that the singleton is Game***Settings*** and not Game***Methods***.
You can also check if screen shake is enabled or not with `GameSettings.screen_shake`. It is `true` if screen shake is enabled (default), `false` if otherwise.

### Proper level keys

For testing your hazard, you can use the CustomNodeLevelKey. But having to set the keys for the hazard every time you want to use the level key can be cumbersome. For this, you can create your own node level key.
Start by creating a new script which extends NodeSpawnLevelKey. Level keys' scripts are usually saved in the "res://resources/level_structs/" folder.
In your script, add a `class_name` token so you can access it from the proeprty list.
NodeSpawnLevelKey uses its internal `scene` and `extras` properties to indicate which scene to instance and the node's properties. The `scene` property is a PackedScene that is instanced when the key is reached, and the `extras` property is a dictionary used to modify the hazard's properties. Each key must be a string and each value must be an expression, unless the key starts with "\_\_". For each key/value pair, the property with the name of the key will be set to the value, unless the key starts with a double underscore, in which case the value is not seen as an expression, but an actual value, and the property will be set to the value. You can also use indexed path by starting the key with a colon ":". All NodeSpawnLevelKey subclasses usually have a way to access these properties.
The `scene` property can be set on the overridable `_init` method (of Object), but `extras` must be updated both at `_init` and when any property is updated. This can be done by using a custom method that is called both at `_init` and on every property's setter.
This is an example script of a NodeSpawnLevelKey.

```
extends NodeSpawnLevelKey
class_name MyNodeSpawnLevelKey


export var size: String = "0" setget set_size
func set_size(val):
	size = val
	update_extras()


export var rotation_degrees: float = 0 setget set_rotation_degrees
func set_rotation_degrees(val):
	rotation_degrees = val
	update_extras()


func update_extras():
	extras = {
		size = size,
		__rotation_radians = deg2rad(rotation_degrees)
	}


func _init():
	scene = preload("res://scenes/hazards/my_hazard.tscn")
	update_extras()
```

END OF MANUAL
