# Ansible for Docker

Container image providing an Ansible environment for the controller

## How-To use

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

Run a containerized bash with docker:


```bash
sudo docker run \
	-it \
	--rm \
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
- Add an SSH key-pair
- Add a GPG key
- Init a password store for `pass`

