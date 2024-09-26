#! /bin/bash
fileNameBash=/usr/local/bin/ipa-client-add-user-sudo.sh
fileNameService=/etc/systemd/system/ipa-client-add-user-sudo.service
nameSystemService=ipa-client-add-user-sudo
nameIPAGroup=ipa_sudo

if [ "$EUID" -ne 0 ]; then
    printf "\033[91mPlease run as root!\033[0m\n"
    exit
fi

printf "\033[94m{ The file has been created and is in the repository https://github.com/VarionDrakon/FreeIPAAutomaticClientSetup }\033[0m\n\n" 

# Step 1
printf "[Step 1.0] \033[93mAttempting to update the system\033[0m\n"
if apt update -y; then
    printf "[Step 1.!] \033[93mThe system has been updated successfully!\033[0m\n"
    if apt install tree freeipa-client freeipa-common -y; then
        printf "[Step 1.!] \033[93mThe packages: \033[92m[tree freeipa-client freeipa-common] \033[93mwere installed successfully!\033[0m\n[Step 1.1] Enter the command: \033[92m{ ipa-client-install --mkhomedir --enable-dns-updates } \033[0mfor configure the client after finished this file!\n"
    fi
else
    printf "[Step 1.!] \033[91mThe system has not been updated!\033[0m\n"
    exit
fi

# Step 2
if [ ! -f $fileNameBash ]; then
    printf "[Step 2.0] The file: \033[93m$fileNameBash\033[0m not found! The file will be created.\n"
    touch $fileNameBash
    chmod +x $fileNameBash
    cat /dev/null > $fileNameBash
    cat << EOF >> $fileNameBash
#!/bin/bash
# Get users from groups $nameIPAGroup

ipa_sudo_users=\$(getent group $nameIPAGroup | cut -d: -f4 | tr ',' '\n')
list_sudo_users=\$(getent group sudo | cut -d: -f4 | tr ',' '\n')

# Add users from $nameIPAGroup in LOCAL SYSTEM group sudo

echo "Starting script... Wait 10 seconds before performing the next search."
echo "List of found users: \$ipa_sudo_users"

sleep 10

echo "Removed all users from sudo group..."

        for usudo in \$list_sudo_users; do
                gpasswd -d \$usudo sudo
                echo "User \$usudo has been deleted."
        done

echo "...And add sysadm in sudo group"
usermod -aG sudo sysadm
echo "Search users started. If users are found in the sudo group, they will be removed."

        for user in \$ipa_sudo_users; do
                gpasswd -d \$user sudo
                echo "User: \$user was removed from the group - sudo."
                usermod -a -G sudo \$user
                echo "User - \$user added in group - sudo"
        done

echo "All done."
EOF
    printf "[Step 2.!] The file: \033[93m$fileNameBash\033[0m was created.\n"
    printf "[Step 2.!] Create file: \033[93m$fileNameBash\033[0m And make executable...\n"
elif [ -f $fileNameBash ]; then
    printf "[Step 2.0] The file: \033[93m$fileNameBash\033[0m found!\n"
fi

# Step 3
if [ ! -f $fileNameService ]; then
    printf "[Step 3.!] File: \033[93m$fileNameService\033[0m not found! The file will be created.\n"
    touch $fileNameService
    chmod +x $fileNameService
    cat /dev/null > $fileNameService
    cat << EOF >> $fileNameService
[Unit]
Description=Add users from $nameIPAGroup group to sudo group
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=$fileNameBash

[Install]
WantedBy=multi-user.target
EOF
    printf "[Step 3.!] Service file created: \033[93m$fileNameService\033[0m...\n"
elif [ -f $fileNameService ]; then
    printf "[Step 3.!] The file: \033[93m$fileNameService\033[0m found!\n"
fi
printf "[Step 3.!] The service: \033[92m{ systemctl unmask $nameSystemService }\033[0m will be unmasked!\n"
systemctl unmask $nameSystemService
printf "[Step 3.!] Setting the service to autorun: \033[92m{ systemctl enable $nameSystemService }\033[0m\n"
systemctl enable $nameSystemService
printf "[Step 3.!] Attempting to start service: \033[92m{ systemctl start $nameSystemService }\033[0m\n"
systemctl start $nameSystemService
printf "[Step 3.1] Please check the service status: \033[92m{ systemctl status $nameSystemService }\033[0m\n"
systemctl status $nameSystemService

# Step 4
printf "[Step 4.!] f everything was successfully, then the system settings is \033[92mcomplete!\033[0m\n"
printf "[Step 4.1] If you want to reinstall services, then delete the files: \n\033[91m{ rm $fileNameBash }\n{ rm $fileNameService }\033[0m\n[Step 4.1] And startup this file \033[92m{ sudo bash /root/setup.sh }\033[0m with sudo!\n"
# Done
printf "\n\033[94m{ Varion Drakonov - with best wishes :> }\033[0m\n"
