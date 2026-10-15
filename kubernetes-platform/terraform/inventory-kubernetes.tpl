[load_balancer]
${load_balancer.vm_name} ansible_host=${load_balancer.static_ip}

[masters]
%{ for node in control_plane ~}
${node.vm_name} ansible_host=${node.static_ip}
%{ endfor ~}

[workers]
%{ for node in workers ~}
${node.vm_name} ansible_host=${node.static_ip}
%{ endfor ~}

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_become=true
ansible_become_method=sudo
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_python_interpreter=/usr/bin/python3
