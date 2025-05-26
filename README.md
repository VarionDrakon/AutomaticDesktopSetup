# AutomaticDesktopSetup (Home)
This small script is for setting up a home PC on the Linux Mint system to the KDE desktop environment with one of the good graphical themes. There are two variables inside the script - INSTALL_PKGS and REMOVE_PKGS. They are needed to select what will be installed in the system and what will be removed. It does not make any significant changes to the system, except for graphical ones, but only helps to set up a clean system from scratch.

# AutomaticDesktopSetup (Enterprise)
All the same as for `Home`, only this script significantly changes the system for corporate use of `Linux Mint`, namely `XRDP (x11vnc)` and `openssh-server` are installed and configured, as well as packages for working with the `FreeIPA` domain, `Microsoft Base` fonts, the `Libre Office` office suite, OnlyOffice (In the future)`.
What has been changed?
* `XRDP` uses `x11vnc` to display and work with the local session, x11vnc itself listens only to `localhost`, when trying to connect and/or disconnect, all sessions will be blocked - this is the responsibility of the `x11vnc-connection-watcher.sh` script and the `systemd` service `x11vnc-connection-watcher.service`, which checks port 3389 every second and, if a connection is detected, blocks all sessions and raises `x11vnc-temp.service`, which is responsible for the operation of `x11vnc` itself. The `x11vnc` arguments prohibit the two-way buffer and any other clipboard for security purposes (Can be fixed by editing the `x11vnc-temp.service` service). The local password `/etc/vncpasswd` is generally not particularly important when the `KDE`/`SDDM` shell itself protects the session.
* The `x11vnc` service itself is started with the argument to listen on `localhost`, and therefore it is most likely impossible to connect from outside and the service is only needed to intercept a local session and then transfer the image to `xrdp`. You can change the password if you want, but keep in mind that you will also have to `change the password in /etc/xrdp/xrdp.ini on line 229`.
* The `OpenSSH` server is configured on port `22522`, which has password and `root` access disabled, that is, to use the `OpenSSH` server you need to either set a private key for the system user `demon.system` (It can also be used, for example, for `Ansible`), or change the configuration to allow passwords.
* The system user `demon.system` has been added, which has no password, but also does not have the ability to log in with a password, since it is disabled and the user is additionally hidden in SDDM. Authorization can be done via `SSH key`.
* `ipa-client-add-user-sudo.service` is configured with the execution of the `ipa-client-add-user-sudo.sh` script, which can be read about in more detail in a separate section.
* Configurations of existing users from the `/etc/skel` folder are updated.

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

You need to take the script version from the `Environments` folder, then run the script as `root` and specify the archive located next to the script as the first argument (Required), then wait a while and follow the instructions on the screen.

If you are asked for `lightDM` or `SDDM`, it is recommended to choose `SDDM`, since it works best with `KDE` and the script is oriented towards this display manager.

# About the script (Enterprise)
If you want to know more about the script, it works like this: </br>
- [STEP 0.0] Creates a temporary folder `TEMP_DIR=$(mktemp -d)`.
- [STEP 0.0] Then displays a notification.
- [STEP 0.1] Checks for running as `root`.
- [STEP 0.2] Checks if the archive was passed as the first argument.
- [STEP 1] Asks the user for permission to continue the installation.
- [STEP 2.0] Checks the mod version using the variable `VERSION_MOD="X.X"` from the `/etc/os-release` file. If the version is outdated or the variable is missing, then with the user's permission, the file will be modified during archive unpacking.
- [STEP 2.1] Checks for an internet connection to `https://google.com` via `curl`. If there is no internet connection, no packages will be installed, but existing ones will be removed, which will also be at the user's discretion. To avoid problems, an internet connection is required.
- [STEP 3.0] Starts unpacking the archive using `tar -xzvf "$ARCHIVE" -C "$TEMP_DIR"`.
- [STEP 3.1] Installs system updates.
- [STEP 3.2] Installs packages according to the list in `$TEMP_DIR/to_install_packages.txt`.
- [STEP 3.3] Then completely cleans up packages from the list in `$TEMP_DIR/to_remove_packages.txt`.
- [STEP 3.4] The final step is removing packages using `autoremove`.
- [STEP 3.5] And cleans up local repositories using `apt clean`.
- [STEP 4.0.*] Copying files from `"$TEMP_DIR/etc/"*` and `"$TEMP_DIR/usr/"*` directories to `/etc/` and `/usr/` respectively.
- [STEP 4.1.*] Restarting the systemd daemon, and then enabling the services - `x11vnc-temp.service`, `x11vnc-connection-watcher.service`, `ipa-client-add-user-sudo.service`.
- [STEP 4.2.*] Setting `755` and `+x` permissions for scripts in the path `/usr/local/bin/ipa-client-add-user-sudo.sh` and `/usr/local/bin/x11vnc-connection-watcher.sh`.
- [STEP 4.3] Delete archive files from `rm -rf "$TEMP_DIR"`.
- [STEP 4.4] Place password for `x11vnc` in `/etc/vncpasswd`.
- [STEP 4.5] Create new user `demon.system` without password login option.
- [STEP 4.6.*] Ask user to specify PC's full domain name, then check if entered name is correct and display specified name.
- [STEP 4.7.*] At user's discretion, it is possible to immediately enter PC into IPA domain and in case of failure, choose to skip installation.
- [STEP 4.8.*] Update all existing users in `/home` from `/etc/skel`. First, registered users are searched for in the system, then files from `/etc/skel` are forcibly overwritten by users' home files, and a new directory `.custom_config` is created for custom program configurations. The last step for users is to correct file and directory permissions based on the folder name - `chown -R "$username:$username" "$user_home_dir"` 
- [STEP FIN] It remains to reboot the PC to apply all changes to the system.


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
