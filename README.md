# AutomaticDesktopSetup (Home)
This small script is for setting up a home PC on the Linux Mint system to the KDE desktop environment with one of the good graphical themes. There are two variables inside the script - INSTALL_PKGS and REMOVE_PKGS. They are needed to select what will be installed in the system and what will be removed. It does not make any significant changes to the system, except for graphical ones, but only helps to set up a clean system from scratch.

# AutomaticDesktopSetup (Corporate/Business)
All the same as for `Home`, only this script significantly changes the system for corporate use of `Linux Mint`, namely `XRDP (x11vnc)` and `openssh-server` are installed and configured, as well as packages for working with the `FreeIPA` domain, `Microsoft Base` fonts, `Libre Office` office suite, OnlyOffice (In the future)`.
What has been changed?
* `XRDP` uses `x11vnc` to display and work with the local session, x11vnc itself listens only to `localhost`, when trying to connect and/or disconnect, all sessions will be blocked - this is the responsibility of the `x11vnc-connection-watcher.sh` script and the `systemd` service `x11vnc-connection-watcher.service`, which checks port 3389 every second and, if a connection is detected, blocks all sessions and raises `x11vnc-temp.service`, which is responsible for the operation of `x11vnc` itself. The `x11vnc` arguments prohibit the two-way buffer and any other clipboard for security purposes (Can be fixed by editing the `x11vnc-temp.service` service). The local password `/etc/vncpasswd` is generally not particularly important when the `KDE`/`SDDM` shell itself protects the session. * An `OpenSSH` server is configured on port `22522`, with password and `root` access disabled, that is, to use the `OpenSSH` server you need to either install a private key for the system user `demon.system` (It can also be used, for example, for `Ansible`), or change the configuration to allow passwords.
* A system user `demon.system` is added, which does not have a password, but also does not have the ability to log in with a password, since it is disabled.
* `ipa-client-add-user-sudo.service` is configured with the execution of the `ipa-client-add-user-sudo.sh` script, which you can read more about in a separate section.

# Service ipa-client-add-user-sudo.service
This small script is needed as an addition to configuring FreeIPA on Linux Mint, Ubuntu. Debian etc., namely... Takes users from the `ipa_sudo` group (can be reconfigured) and adds them to the local `sudo` user group.
This is necessary so that administrators from the `IPA` domain are visible in the graphical environment, since often such shells as `KDE`, `Cinnamon` and the like display users only from the `/etc/group` group.
I don't know who will find this useful... But if you need to prepare a clean system for the IPA domain - go ahead :)
~~There are 5 variables in the script, most likely you will only need `nameIPAGroup` and `nameDefaultUser`.
Insert here the name of the user group in the IPA domain, which should be sudo and local for the system, and also insert the name of the local user in `nameDefaultUser`
Otherwise, this is a script for `auto-configuring` the system in the `IPA environment`. I think the script can be easily adapted for other package managers, not only `apt`...~~~

# How to use
~~Place the file anywhere, but preferably in `/root`, then edit the file, namely specify `user group from the IPA domain that will have sudo rights in the system`, and also change the variable `$nameDefaultUser` to your local user... And run the file from sudo.
Oh yeah, and don't forget to write: `hostnamectl set-hostname client.domain.name` before running the script.~~
<br>
<br>
You need to take the script version from the `Environments` folder, then run the script as `root` and specify the archive located next to the script as the first argument (Required), then wait a while and follow the instructions on the screen.

If you are asked for `lightDM` or `SDDM`, it is recommended to choose `SDDM`, since it works best with `KDE` and the script is oriented towards this display manager.

# About the script
If you want to know more about the script, it works as follows: </br>
- First, the system is updated and the necessary packages are installed.
- Then, a sh file is created, which will be executed by the future `service` and is located at: `/usr/local/bin/ipa-client-add-user-sudo.sh` The path is also described in the variable: `fileNameBash`
- Next, the `service` file itself is created, which will be executed only at system startup or when manually called. The file is located at: `/etc/systemd/system/ipa-client-add-user-sudo.service` The path is also described in the variable: `fileNameService`
- Then, the `service` is `unmasked`, `enabled` and `started`, and after the service is executed or fails, its `status` is displayed.
- That's it...
## Now the ipa-client-add-user-sudo.sh file itself:
- First it determines which users are in the `sudo` group and `$nameIPAGroup`.
- Then there is a 10 second delay for the request timeout.
- Then in the first loop `ALL` users from the sudo group are removed.
- Then the system user is added back to the `sudo` group (In my case it is sysadm, in your case it is a local user. Be careful at this stage and it is advisable to specify the user yourself in the `$nameDefaultUser` variable!).
- Now finally in the second loop all users found in the `ipa_sudo` group (can be changed) are added to the local `sudo` and the script ends.
</br>
</br>
</br>
</br>
P.S.> I will improve the script later... Really... Really :>
