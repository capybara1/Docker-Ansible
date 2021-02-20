#!/bin/bash

set -e

function usage {
	cat <<-'EOF'
	usage: $(basename "$0") --vault-id <id>
	  --vault-id   name of the vault secret to get from pass
	EOF
	exit 1
}

[ -z "$1" ] && usage

vault_id=dev

while [ $# ]
do
	if [ "${1#--vault-id}" != "$1" ]; then
		shift
		vault_id="$1"
		break
	fi
	shift
done

pass "ansible-vault/${vault_id}_password"
