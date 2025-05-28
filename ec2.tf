resource "aws_instance" "instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  subnet_id                   = aws_subnet.subnet1.id
  key_name                    = var.ssh_key_name
  depends_on                  = [aws_internet_gateway.example_igw, aws_route.public_route, aws_route_table_association.subnet1]
  associate_public_ip_address = true

  tags = {
    Name = "${var.platform_name}-ec2"
    User = "${var.ec2_user}"
    Folder = "${var.folder}"
  }

  connection {
    type        = "ssh"
    user        = self.tags.User
    private_key = file("${path.root}/keys/${self.key_name}.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${var.folder}"
    destination = "/home/${var.ec2_user}/"
  }

  provisioner "file" {
    source      = "scripts/setup.sh"
    destination = "/home/${var.ec2_user}/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash setup.sh",
    ]
  }

  provisioner "local-exec" {
    when = destroy
    command = <<EOT
    rsync -avz -e "ssh -o StrictHostKeyChecking=no -i ${path.root}/keys/${self.key_name}.pem" \
    ${self.tags.User}@${self.public_ip}:/home/${self.tags.User}/${self.tags.Folder}/ ${path.root}/${self.tags.Folder}/
    EOT
  }

  root_block_device {
    volume_size = var.ec2_disk_size
    volume_type = var.ec2_disk_type
  }
}

output "instance_public_ip" {
  value       = aws_instance.instance.public_ip
  description = "The public IP address of the EC2 instance"
}
output "start_command" {
  value = "source ~/miniconda3/bin/activate && cd ${var.folder} && java -Xms4G -Xmx8G -jar server.jar -nogui"
}
