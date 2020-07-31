#!/usr/bin/env sh
# Check certs every day
cp helpers/cp/certs-autorenewal "${HOME}/.scripts/certs-autorenewal"
(crontab -l 2>/dev/null; echo "@daily /bin/sh ${HOME}/.scripts/certs-autorenewal") | crontab -
