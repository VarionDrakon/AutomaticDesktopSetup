#!/bin/bash
# Version script 1.2 (20.05.2025)
# Get users from groups ipa_sudo

IPA_SUDO_USERS=$(getent group ipa_sudo | cut -d: -f4 | tr ',' '\n')
LIST_SUDO_USERS=$(getent group sudo | cut -d: -f4 | tr ',' '\n')

# Add users from ipa_sudo in LOCAL SYSTEM group sudo

echo "Starting script... Wait 10 seconds before performing the next search."
echo "List of found users: $IPA_SUDO_USERS"

sleep 10

echo "Removed all users from sudo group..."

        for usudo in $LIST_SUDO_USERS; do
                gpasswd -d $USER_SUDO sudo
                echo "User $USER_SUDO has been deleted."
        done
echo "Search users started. If users are found in the sudo group, they will be removed."

        for user in $IPA_SUDO_USERS; do
                gpasswd -d $USER sudo
                echo "User: $USER was removed from the group - sudo."
                usermod -a -G sudo $USER
                echo "User - $USER added in group - sudo"
        done

echo "All done."
