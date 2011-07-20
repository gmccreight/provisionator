# To use these functions from the scripts, just do:
# source __shared/library.sh
# In the script you want to use it in.

# Notice how this script is in the __shared directory.  That means it is shared
# with the remote machine, meaning it's available to be used there, too.

load_var() {
    eval `grep "^$1=" __config_generated.txt`
}
