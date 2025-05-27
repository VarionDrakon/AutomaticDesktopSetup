#!/bin/bash
# Version script 1.2 (20.05.2025)

LOCKED=false

while true; do
    if ss -tonp | grep -E "3389" | grep -v "127.0.0.1\|::1"; then
        if [ "$LOCKED" = false ]; then
            echo "RDP client connected -> Locked session and set LOCKED=true" | systemd-cat -t x11vnc-hook
            loginctl lock-sessions
            systemctl restart x11vnc-temp.service
            LOCKED=true
        fi
    else
#        echo "RDP client disoconnected -> set LOCKED=false" | systemd-cat -t x11vnc-hook
        [ "$LOCKED" = true ] && LOCKED=false
    fi
    sleep 1
done
