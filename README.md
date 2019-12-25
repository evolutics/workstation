# Workstation

1. Install [Xubuntu](https://xubuntu.org).
1. [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#latest-releases-via-apt-ubuntu).
1. ```bash
   sudo apt install git

   folder="$(mktemp --directory)"
   pushd "${folder}"
   git clone https://github.com/evolutics/workstation .
   ansible-galaxy role install --role-file requirements.yml
   sudo ansible-playbook local.yml
   popd
   rm --force --recursive -- "${folder}"
   ```
