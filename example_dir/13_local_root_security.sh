#This file is run locally because of its name

source __shared/library.sh
load_var URI
load_var PROVISIONING_FOLDER

ssh root@$URI "mkdir $PROVISIONING_FOLDER 2>/dev/null"
scp __config_generated.txt root@$URI:~/$PROVISIONING_FOLDER
scp __security_ssh.sh root@$URI:~/$PROVISIONING_FOLDER
ssh root@$URI "cd ./$PROVISIONING_FOLDER; bash ./__security_ssh.sh; rm ./__security_ssh.sh"
