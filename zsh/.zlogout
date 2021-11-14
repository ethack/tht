# Store current working directory in a file to restore as OLDPWD on next launch
printf "export OLDPWD=$PWD" > $PERSISTENT/.oldpwd