Here's a Q&A!

Q: What is "assets/engine"?
A: This folder will be "assets" after compiling

Q: What is order of loading assets?
A: "mods/<modFolder>/" => "mods/" => "assets/<currentLevel>/" => "assets/shared/" => "assets/"
(for example: if "mods/<modFolder>/" not found, game will try load from "mods/" and etc)

Q: Where should I put my charts?
A: "assets/shared/data/"

Q: Where should I put my songs?
A: "assets/shared/songs/"

Q: Where should images, characters, weeks, stages, sounds and other JSONs files go?
A: You can put them in "assets/shared/" or "assets/shared/week_assets/your-week-folder/"! Really depends on your preference.

Q: I don't want base game assets in my mod! What should I do??
A: Go back to the main folder and open Project.xml, then delete the entire line with "BASE_GAME_FILES",
You can safely delete the "assets/base_game/" folder after that if you want to, but virtually it won't have any effect when you compile.

Q: What's the "translations" folder for?
A: This is where I've put the Portuguese translation in, you can also set up other languages inside it easily,
You can turn off languages by deleting the line with "TRANSLATIONS_ALLOWED" inside Project.xml

Q: How can i see a assets structure?
A: You can go to "assets/shared" folder and see how assets structure is working,
"assets/base_game" and "assets" has the same structure!