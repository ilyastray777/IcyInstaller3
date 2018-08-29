# IcyInstaller3
Icy is a lightweight DPKG-based installer for iOS.
# Credits
- https://dribbble.com/shots/3363903-Soft-Gradients-sketch-psd-xd
- https://www.behance.net/gallery/62158409/Gradients-Color-Style
- brandeps.com
- [@Even_Dev](https://twitter.com/even_dev for the tab bar icons
- [@Dashing_23](https://twitter.com/Dashing_23)
- Unsanity for completion sound (also used in original Icy project)
# What is Icy?
Icy is a **lightweight** package manager for iOS 7 - 11 (and most likely 12 when it gets jailbroken) that does **not** need APT. Yes, that throws away updating packages automatically (maybe coming in an update though) and dependency management, but this also brigns up quite some possibilities, for example, running on [jakeashacks/rootlessjb] (I'm planning to do that, too).
Icy Installer 3 is a full rewrite of the original [Icy project](https://github.com/slavikus/Icy) that was started by RipDev and later updated by WeAmDev. The original Icy Installer project used curl, but stock APIs with the same possibilities were introduced to iOS so I decided not to use it.
# Does Icy use any deprecated or private APIs?
Yes and yes. It uses UIAlertView for iOS 7 support (call me an idiot but UIAlertController **just crashes** even on iOS 8 when trying to present it for me) and NSTask for running external binary files and getting the output out of these. Originally, I was planning to use the non-private posix_spawn, but grabbing output out of it was a mess.
# I am a user. Where can I install this?
Add artikushg.github.io to Cydia and install Icy from there.
# I am a developer. Can I fork or contribute this?
Yes and yes. You can do anything the MIT license allows.
