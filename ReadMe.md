Minecraft Server Automation with Terraform and Bash
Overview
This project automates the deployment of a Minecraft server on AWS using Terraform for infrastructure provisioning and a Bash script for server configuration. The solution creates a secure, ready-to-play Minecraft server with minimal manual intervention.

Requirements
Tooling
Terraform v1.2.0 or later

AWS CLI configured with proper credentials

SSH client (for connection testing)

Bash (for script execution)

AWS Resources
AWS account with EC2 permissions

Key pair for SSH access (created in AWS or existing)


Pipeline Stages
Infrastructure Provisioning (Terraform):

Creates security group with necessary ports (SSH 22, Minecraft 25565)

Launches EC2 instance (Ubuntu 22.04, t3.large)

Attaches security group and key pair

Server Configuration (Bash):

Installs Java (Eclipse Temurin 17)

Creates dedicated Minecraft user

Downloads latest Minecraft server

Configures server properties

Sets up systemd service for automatic management

Deployment Verification:

Checks service status

Validates port accessibility

Provides connection details

Tutorial
For Windows Users
Install Prerequisites:

Install Git for Windows

Install Terraform

Install AWS CLI

Configure AWS:

powershell
aws configure
Enter your AWS access key, secret key, and preferred region.

Run the Deployment:

powershell
git clone https://github.com/your-repo/minecraft-terraform.git
cd minecraft-terraform
terraform init
terraform apply

