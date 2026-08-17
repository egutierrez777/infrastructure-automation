[loadbalancers]
${lb_name} ansible_host=${lb_ip}

[webservers]
%{ for i, web_name in web_names ~}
${web_name} ansible_host=${web_ips[i]}
%{ endfor ~}

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_become=true
ansible_become_method=sudo
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_python_interpreter=/usr/bin/python3
work_env=${work_env}
