output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.minecraft_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.minecraft_server.public_ip
}

output "minecraft_connection" {
  description = "Command to check Minecraft server status"
  value       = "nmap -sV -Pn -p T:25565 ${aws_instance.minecraft_server.public_ip}"
}