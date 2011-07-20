Provisionator is a bash scripting framework that makes it easy to
provision machines using only bash scripts.

=== Usage ===

                   your dir   steps to         override __config.txt file values
                   \          run (or all)    /
                    \          \             /
                     \________  \_________  /__________________
 ./provisionator.sh  app_server  1,6-10,14  URI=192.168.168.102,SSH_PORT=30101
