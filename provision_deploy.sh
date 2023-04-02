cd terraform
terraform init
terraform apply -auto-approve

cd ../ansible
# Run Ansible playbook
ansible-playbook -i node_inventory.ini playbook.yml