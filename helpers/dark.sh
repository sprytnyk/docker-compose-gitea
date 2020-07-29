#!/usr/bin/env sh
# Sets dark theme as a global theme for Gitea.

sudo -u git sh -c "cat >> /var/lib/gitea/gitea/conf/app.ini <<EOF
[ui]
DEFAULT_THEME = arc-green

EOF"