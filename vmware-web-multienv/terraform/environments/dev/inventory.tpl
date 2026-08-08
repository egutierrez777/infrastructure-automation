[webservers]
${vm_name} ansible_host=${vm_ip}

[webservers:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_become=true
ansible_become_method=sudo
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_python_interpreter=/usr/bin/python3
