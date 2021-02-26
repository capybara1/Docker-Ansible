#!/usr/bin/env sh

eval "$( ssh-agent )"

exec /bin/bash -l
