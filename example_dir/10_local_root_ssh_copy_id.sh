source __shared/library.sh
load_var INITIAL_ROOT_PASS
load_var URI

# Copy the id file so we can simply SSH from now on.
expect <<ExpectInput
spawn ssh-copy-id "-o StrictHostKeyChecking=no root@$URI"
expect "root@$URI's password:"
send -- "$INITIAL_ROOT_PASS\r"
send -- "\r"
ExpectInput
