# based off of the script at: http://forum.slicehost.com/comments.php?DiscussionID=2187
# basically, add a new user (no longer root) that you will use from now on, and open certain ports.

config_file="__config_generated.txt"

eval `grep "^NEW_ROOT_PASS=" $config_file`
eval `grep "^USER_NAME=" $config_file`
eval `grep "^USER_PASS=" $config_file`
eval `grep "^SSH_PORT=" $config_file`

echo "** - Root password is being changed to $NEW_ROOT_PASS"
echo "** - New user is $USER_NAME"
echo "** - User password for $USER_NAME is $USER_PASS"

# Change the root password
echo -e "$NEW_ROOT_PASS\n$NEW_ROOT_PASS\n" | passwd

# Add the new non-root user
useradd -m -s /bin/bash $USER_NAME
echo -e "$USER_PASS\n$USER_PASS\n" | passwd $USER_NAME

cp /etc/sudoers /etc/newsudoers
echo -e "\n$USER_NAME ALL=(ALL) NOPASSWD: ALL\n" >> /etc/newsudoers
mv -f /etc/newsudoers /etc/sudoers
chmod 440 /etc/sudoers

mkdir /home/$USER_NAME/.ssh
cp /root/.ssh/authorized_keys /home/$USER_NAME/.ssh/
chown -R $USER_NAME /home/$USER_NAME/.ssh
# Finished adding the non-root user


sed -e "s/Port.*/Port $SSH_PORT/" -e 's/PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config > /etc/ssh/new_sshd_config
cat >> /etc/ssh/new_sshd_config <<ENDOFFILE

AllowUsers $USER_NAME

ENDOFFILE

mv -f /etc/ssh/new_sshd_config /etc/ssh/sshd_config
chmod 644 /etc/ssh/sshd_config

cat > /etc/iptables.test.rules <<ENDOFFILE
*filter


# Allows all loopback (lo0) traffic and drop all traffic to 127/8 that doesn't use lo0
-A INPUT -i lo -j ACCEPT
-A INPUT -i ! lo -d 127.0.0.0/8 -j REJECT


# Accepts all established inbound connections
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT


# Allows all outbound traffic
# You can modify this to only allow certain traffic
-A OUTPUT -j ACCEPT


# Allows HTTP and HTTPS connections from anywhere (the normal ports for websites)
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 443 -j ACCEPT

# Allow the port that is used on qa1 as a port forwarding port for testing email forwarding from SendGrid
-A INPUT -p tcp --dport 8080 -j ACCEPT


# Allows SSH connections
#
# THE -dport NUMBER IS THE SAME ONE YOU SET UP IN THE SSHD_CONFIG FILE
#
-A INPUT -p tcp -m tcp --dport $SSH_PORT -j ACCEPT

# Allow ping
-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT


# log iptables denied calls
-A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7


# Reject all other inbound - default deny unless explicitly allowed policy
-A INPUT -j REJECT
-A FORWARD -j REJECT

COMMIT
ENDOFFILE

iptables-restore < /etc/iptables.test.rules
iptables-save > /etc/iptables.up.rules

sed -e 's|iface lo inet loopback|iface lo inet loopback\npre-up iptables-restore < /etc/iptables.up.rules|' /etc/network/interfaces > /etc/network/new_interfaces
mv -f /etc/network/new_interfaces /etc/network/interfaces
chmod 644 /etc/network/interfaces

/etc/init.d/ssh reload
