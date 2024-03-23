[img]https://i.imgur.com/uhZN9dO.png[/img]
This mod is a library used as requirement for my other mods, streamlining their maintenance and eventual code upgrades (e.g.: for config files). This is especially important considering their number has grown significantly; up until now, I've been duplicating relevant helper code for them, which has become an ever-increasing liability.
Introducing this will hopefully make maintaining them much more easy and likely to be done when, for example, future API changes from SE/Larian occur.

[b]My mods that are using Volition Cabinet[/b][b]:[/b]
[list]
[*]  [size=2][url=https://www.nexusmods.com/baldursgate3/mods/6995]Waypoint Inside Emerald Grove[/url]﻿[/size]
[*][size=2][url=https://www.nexusmods.com/baldursgate3/mods/7035]Auto Send Read Books To Camp[/url]﻿[/size]
[*][size=2][url=https://www.nexusmods.com/baldursgate3/mods/6188]Auto Lockpicking[/url]﻿[/size]
[*][size=2][url=https://www.nexusmods.com/baldursgate3/mods/5899]Smart Autosaving[/url][/size]
[*][size=2][size=2][url=https://www.nexusmods.com/baldursgate3/mods/6086]Auto Send Food To Camp[/url][/size][/size]
[*][size=2][url=https://www.nexusmods.com/baldursgate3/mods/6880]Auto Use Soap[/url][/size]
[/list]All these mods also directly benefit from Volition Cabinet, with enhancements such as auto-regeneration of config files with syntax errors, a new command to
reload settings, etc.
Even though they have been tested, since several mods were affected, please bear with me during this transition. Let me know in their
respective mod pages if you face any problems or regressions.

[b][size=4]Load order does not matter.[/size][/b]

[line]
[size=3]Note to fellow Mod Authors:[/size]
This library is essentially a [url=https://www.nexusmods.com/baldursgate3/mods/7417]Focus Core[/url] fork, adapted for my personal modding needs after I created too many mods that had the same functions all over the place.
[b]Please refrain from using this as a direct dependency for your mods[/b]. Volition Cabinet is ultimately personal code and is not designed to be a public codebase for external use as a direct dependency, even though I want to keep it as stable as possible for my own sake. However, if you find [i]any[/i] segment of the code beneficial, [b]feel free to adapt it for your needs.[/b] Just please note that in doing so, its maintenance becomes [i]your[/i] responsibility, and that I encourage you to adopt the most permissive possible permissions for your mod if you choose to utilize this resource — or even otherwise, for that matter!
Also, as requested by Focus, do not contact him for the creation, maintenance or support of anything based on this fork or his original Focus Core.

[size=3]Focus, my deep gratitude for your contributions. I wish things didn't turn out the way they did.[/size]
[center][url=https://www.nexusmods.com/baldursgate3/mods/7294][img]https://i.imgur.com/hOoJ9Yl.png[/img][/url][/center]
