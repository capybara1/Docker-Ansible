# Ansible for Docker

Container image providing an Ansible environment for the controller

## Features

- Supports `pass`
  - Dynamically generate and persist secret values
  - Obtain ansible vault password via a vault client script (`vault/pass-client.sh`)
- Supports ansible kubernetes tasks

## Details

- The Working Directory is `/project`

## Usage

Ensure local mount directories are present and sufficiently restrictive:

```bash
for d in .ssh .gnupg .password-store
	do
	if [ ! -d "$d" ]
	then
		mkdir "$d"
		chmod u=rwx "$d"
	fi
done
```

The directories are used for SSH, GNUPG and [pass](https://www.passwordstore.org/).
Using a volume allows persisting configuration accross container lifetimes.

It is possible to mount existing directories, however it is required that the
pid and gid of the user container (`ansible`) match in order to meet security
requirements.
The default pid and gid are 1000 respectively.
It might be required to build a custom container image if different ids are required.
The `Dockerfile` supports the optional arguments `USER_ID` and `GROUP_ID` for this purpose.

Run a containerized bash with docker:

```bash
sudo docker run \
	-it \
	--rm \
	-e ANSIBLE_VAULT_IDENTITY_LIST="dev@/project/vault/pass-client.sh,prod@/project/vault/pass-client.sh" \
	-v $PWD/requirements.yml:/project/requirements.yml:ro \
	-v $PWD/inventories:/project/inventories:ro \
	-v $PWD/roles:/project/roles:ro \
	-v $PWD/sshservers.yml:/project/sshservers.yml:ro \
	-v $PWD/k8s.yml:/project/k8s.yml:ro \
	-v $PWD/common.yml:/project/common.yml:ro \
	-v $PWD/.ssh:/home/ansible/.ssh:rw \
	-v $PWD/.gnupg:/home/ansible/.gnupg:rw \
	-v $PWD/.password-store:/home/ansible/.password-store:rw \
	--network=host \
	capybara1/ansible
```

... or with containerd:

```bash
sudo ctr run \
	-t \
	--rm \
	--env ANSIBLE_VAULT_IDENTITY_LIST="dev@/project/vault/pass-client.sh,prod@/project/vault/pass-client.sh" \
	--mount type=bind,src=$PWD/requirements.yml,dst=/project/requirements.yml,options=rbind:ro \
	--mount type=bind,src=$PWD/inventories,dst=/project/inventories,options=rbind:ro \
	--mount type=bind,src=$PWD/roles,dst=/project/roles,options=rbind:ro \
	--mount type=bind,src=$PWD/sshservers.yml,dst=/project/sshservers.yml,options=rbind:ro \
	--mount type=bind,src=$PWD/k8s.yml,dst=/project/k8s.yml,options=rbind:ro \
	--mount type=bind,src=$PWD/common.yml,dst=/project/common.yml,options=rbind:ro \
	--mount type=bind,src=$PWD/.ssh,dst=/home/ansible/.ssh,options=rbind:rw \
	--mount type=bind,src=$PWD/.gnupg,dst=/home/ansible/.gnupg,options=rbind:rw \
	--mount type=bind,src=$PWD/.password-store,dst=/home/ansible/.password-store,options=rbind:rw \
	--net-host \
	docker.io/capybara1/ansible:latest ansible
```

Things to do next:

- Add target node(s) to the known_hosts for SSH
- Add an [SSH key-pair](https://linuxize.com/post/how-to-set-up-ssh-keys-on-ubuntu-20-04/)
- Add a [GPG key](https://www.gnupg.org/gph/en/manual.html)
- Init a [password store](https://www.passwordstore.org/)

