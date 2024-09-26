# FreeIPAClientAddUserSudo
This small script is needed as an addition to configuring FreeIPA on Linux Mint, namely... Takes users from the `ipa_sudo` group (can be reconfigured) and adds them to the local sudo user group.
This is necessary so that administrators from the `IPA` domain are visible in the graphical environment, because often shells such as `KDE`, `Cinnamon` and the like display users only from the `/etc/group` group.
I don't know who will find this useful... But if you need to prepare a clean system for the IPA domain - go ahead :)
