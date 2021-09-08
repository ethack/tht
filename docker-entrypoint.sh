#!/bin/bash

# create a user and group to match what's on the host
# this makes any files created conveniently have the correct file permissions
if [[ $PUID ]] && [[ $PUID -ne 0 ]] && [[ $PGID ]]; then
    # add a group with the specified ID
    groupadd --non-unique --gid "$PGID" "${GROUPNAME:-group}"
    # add a user with the specified ID
    useradd \
    --non-unique \
    --home-dir /root \
    --gid "$PGID" \
    --uid "$PUID" \
    --groups root \
    --shell /usr/bin/zsh \
    "${USERNAME:-user}"

    # change ownership of necesasry files
    chown -R $PUID:$PGID /root
    chown -R $PUID:$PGID /usr/local/share/zsh

    # give user unrestricted sudo rights
    echo "${USERNAME:-user} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo >/dev/null

    # execute the original command with the new user
    sudo -u "${USERNAME:-user}" sh -c "$*"
else
    exec "$@"
fi
