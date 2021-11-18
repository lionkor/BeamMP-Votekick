[![](https://img.shields.io/badge/Support%20my%20Work-Patreon-%23ff424d)](https://patreon.com/lion_kor) 
[![](https://img.shields.io/badge/Support%20my%20Work-PayPal-%230079c1%20)](https://www.paypal.com/donate?hosted_button_id=BHWMH7GDX35QS)

# BeamMP-Votekick

An implementation of a votekick system for [BeamMP](https://beammp.com).

Also a test of the v2.4.0 BeamMP-Server Lua API, which I developed.

Please read and edit `votekick.cfg` for configuration.

## How to use

Move this folder into `Resources/Server` so that it looks like this:
```
BeamMP-Server.exe
ServerConfig.toml
Resources
    |
    + Server 
        |
        + BeamMP-Votekick
            |
            + README.md <- this is the file you're currently reading
```

Then just write `/votekick <player_name>` in chat, like `/votekick LionKor`.


## Rules

For rules like "how many people are needed to kick" and similar, check out `votekick.cfg`.
