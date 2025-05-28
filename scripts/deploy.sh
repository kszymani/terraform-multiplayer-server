terraform apply -auto-approve 

echo "ssh -i C:\\\\Users\\\\Krzysztof\\\\VSCodeProjects\\\\Memcraft\\\\memcraft.pem ec2-user@$(terraform output -raw instance_public_ip)"
echo "$(terraform output -raw start_command)"

