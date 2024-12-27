# Fireworks
Add festive fireworks to your server! Requires sven 5.26+. This was originally intended to release for the 2018 -> 2019 new years, whoops.

This plugin provides a couple of fireworks for your players to enjoy, with easy out of box modification to suit all server needs (see configuration section). Following optional features are supplied:
* scheduled activation & deactivation
* built in buymenu
* "gift" piles (as seen on Misfire's)

The buymenu listens to the following commands in chat: "fw", "firework(s)", "fwmenu", "firework(s)menu" with no prefix, "!" prefix, or "\\" prefix

When installed through AFB the following command is added for access level X:
```
fw_throw (type) - Throw a firework
```

### Demo:
[![Click to open demo video in Youtube](https://img.youtube.com/vi/07P6szdXyw0/0.jpg)](https://www.youtube.com/watch?v=07P6szdXyw0)

### Installation:
You can install this plugin through AFB or as a standalone plugin. Installation through both at the same time is unsupported.

#### Standalone plugin (default_plugins.txt):
```
"plugin"
{
	"name" "Fireworks"
	"script" "Fireworks_plugin"
	"concommandns" "fireworks"
}
```

#### AFB (AFBaseExpansions.as):

include: `#include "Fireworks_afb"`

call: `Fireworks_Call();`

### Configuration:
This plugin provides a few cvars for server ops to modify. Some of them only take effect during a map change, some of them take effect instantly.

```
fw_datetime <0/1/2 default:1> - Automatically constrain fireworks to specific dates only, when fireworks are not active precaches are skipped. 0:Always enabled, 1:All dates enabled, 2:Only major dates (no birthdays).

fw_potato <default:0> - Limit the amount of active fireworks on the server, may help with servers ran on potato hardware.

fw_piles <0/1 default:1> - Spawn firework piles in random locations.
fw_pile_respawn <default:10> - Amount of seconds until a pile respawns, value of zero or less disables and piles can be picked up only once.
fw_pile_count <default:12> - Amount of piles to generate on a map.

fw_menu <0/1 default:1> - Enable/disable the built in buymenu.
fw_free <0/1 default:0> - Make the fireworks built in buymenu free to use.

The following cvars are registered for cross compatibility with other buymenus:  
bm_maxmoney <default:16000> - Maximum money a player can have.
bm_moneyperscore <default:10> - Money the player will earn per score.
bm_startmoney <default:0> - Money the player will start with once he joins the server.

however if you wish to have separate behavior for the fireworks buymenu, the following cvars can be used:
fw_maxmoney <default:0> - Maximum money a player can have, if non-zero this takes precedence over bm_maxmoney.
fw_moneyperscore <default:0> - Money the player will earn per score, if non-zero this takes precedence over bm_maxmoney.
fw_startmoney <default:0> - Money the player will start with once he joins the server, if non-zero this takes precedence over bm_maxmoney.
```

### Credits
Programming: Zode

Sprites: Zode, Gauna

Modelling: Gauna, DNIO, The303

Animations: DNIO

Sound: Zode

Special thanks: KernCore (weapon code is based on ins2 throwables code).