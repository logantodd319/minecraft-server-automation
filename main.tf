terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "us-west-2"
  access_key = "ASIATCKANHQJ5GGCSWO6"  # Your AWS access key
  secret_key = "TzebjbFztYEUSBreIuqXIVEsfJK2iA8uN/1hBShb"  # Your AWS secret key
  token      = "IQoJb3JpZ2luX2VjEAkaCXVzLXdlc3QtMiJGMEQCIBzGkHVc3wHnecIV7dPzBrxsVyOLHv287RQkwMKFu0YdAiBjrI40NTRuuK7XzgdmDTQVeOS54g2WHyXM96RgO22z0Sq5Agji//////////8BEAAaDDIxMTEyNTM1MzQ5MSIMnz9j/qOFmnr6z9NbKo0Ccgls6kco1EByhIfxyxMuF4uZ2BidnCx5aE69kSconNnxW9hiu2LEsGFxohYCeYJY8VFdd0cZgE+VfCIZLcFCoU6Vh8WuQZPfKqXkHYfshWdLJivaHZe16lSSO5vzWCSwk26iEAWcFeLx2K3QjQBpUWsET45yyHCpmrnisg8G9hUydxM/Za+laZoF5QECnkbcFS/L5b345kIckRemDCnQ9qQ0YUr3uaJNwjXV0GAI4ry8V/PePegNNLKyqJZkvuhnOsmQihjm/PmG8l5k6DwIkCSCS5Xn32+imjv2FTS0wpV/mzHymorbYawPOdfmwoiCOzBTJdNI7zIwVM+gaDzjUe93CSnGe+PodUr5wxwwjMeowgY6ngFQTBsKq619TMjG8QXAsQvv/EAfoYz/KMfkSjVxIZTnr2p4EKAcbNoqpryh8zQ8Jgb6QJ/kAjaPaJFQYetqzgXEPpUxQJ99NEg9dVCaBJM4bsmjj22WA//geODwtx+wShlBcp0q/haV1dkzPbYhp9AF0145R51LX7n24tVQKhDpdYsDJyTR5dBK6lj9jssEeN0vCrbSL+uc/PI+7mbwOQ=="  # Your session token
}

resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft-security-group"
  description = "Allow Minecraft and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "minecraft_server" {
  ami           = "ami-08d70e59c07c61a3a"  # Ubuntu 22.04 in us-west-2
  instance_type = "t3.large"
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  key_name      = "mine-key"

  root_block_device {
    volume_size = 30  # GB - Minecraft worlds can grow large
  }

  tags = {
    Name = "MinecraftServerInstance"
  }

  # Wait for SSH to be available
  provisioner "remote-exec" {
    inline = ["echo 'SSH connection established'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/mine-key.pem")
      host        = self.public_ip
      timeout     = "10m"
    }
  }

  # Copy the setup script
  provisioner "file" {
    source      = "setup_minecraft.sh"
    destination = "/tmp/setup_minecraft.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/mine-key.pem")
      host        = self.public_ip
    }
  }

  # Execute the setup script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_minecraft.sh",
      "sudo /tmp/setup_minecraft.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/mine-key.pem")
      host        = self.public_ip
      timeout     = "30m"  # Minecraft setup can take a while
    }
  }
}

output "server_ip" {
  value = aws_instance.minecraft_server.public_ip
}

output "minecraft_connect" {
  value = "Connect to Minecraft at ${aws_instance.minecraft_server.public_ip}:25565"
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/mine-key.pem ubuntu@${aws_instance.minecraft_server.public_ip}"
}
