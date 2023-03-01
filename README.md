terraform init
terraform validate
terraform plan -var external_ip=$(curl -s ifconfig.me)/32
terraform apply -var external_ip=$(curl -s ifconfig.me)/32
#When you're done
terraform destroy -var external_ip=$(curl -s ifconfig.me)/32
