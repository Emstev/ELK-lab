provider "aws" {
  region = "us-west-2"  # Adjust to your preferred region.
}

resource "aws_security_group" "elk_sg" {
  name        = "elk-security-group"
  description = "Security group for both ELK and App servers"

  # Elasticsearch ports
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kibana ports
  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP port
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS port
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Logstash Beats input port
  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App server port
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "elk_server" {
  ami           = "ami-075686beab831bb7f"  # Ubuntu AMI (adjust for your region)
  instance_type = "t3.large"  # Recommended for ELK

  root_block_device {
    volume_type = "gp3"
    volume_size = 28  # 28 GiB as requested
    encrypted   = true
  }

  key_name      = "test-keypair"  # Replace with your EC2 key pair

  security_groups = [aws_security_group.elk_sg.name]

  user_data = file("${path.module}/ELK.sh")

  tags = {
    Name = "ELK-Server"
  }
  provisioner "local-exec" {
    command = "echo 'ELK server created with IP: ${self.public_ip}'"
  }
  provisioner "local-exec" {
    command = "echo '\\n\\nIMPORTANT: Please wait 3-5 minutes for the ELK stack to fully initialize before accessing Elasticsearch or Kibana.\\n'"
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-0efcece6bed30fd98"  # Ubuntu AMI (adjust for your region)
  instance_type = "t2.medium"  # As requested

  root_block_device {
    volume_type = "gp3"
    volume_size = 25  # 25 GiB as requested
    encrypted   = true
  }

  key_name      = "test-keypair"  # Replace with your EC2 key pair

  security_groups = [aws_security_group.elk_sg.name]

   user_data = templatefile("${path.module}/app-server_config.sh.tpl", 
  {
    elk_server_ip = aws_instance.elk_server.public_ip  
  }
  )

  tags = {
    Name = "App-server"
  }
   # Make sure the ELK server is created first
  depends_on = [aws_instance.elk_server]
  
  provisioner "local-exec" {
    command = "echo 'App server created with IP: ${self.public_ip}'"
  }
}

# Output the public IP of the ELK server
output "elk_server_public_ip" {
  value = aws_instance.elk_server.public_ip
  description = "The public IP address of the ELK server"
}

output "Note" {
  value = "Please wait 3-5 minutes for the ELK stack to fully initialize before accessing the above URLs."
  description = "Instructions for the user to wait before accessing services"
}

# Output the Kibana URL
output "kibana_url" {
  value = "http://${aws_instance.elk_server.public_ip}:5601"
  description = "The URL to access Kibana"
}

# Output the Elasticsearch URL
output "elasticsearch_url" {
  value = "http://${aws_instance.elk_server.public_ip}:9200"
  description = "The URL to access Elasticsearch"
}

# Output the App server public IP
output "app_server_public_ip" {
  value = aws_instance.app_server.public_ip
  description = "The public IP address of the App server"
}

# Output the App server URL
output "app_server_url" {
  value = "http://${aws_instance.app_server.public_ip}:8080"
  description = "The URL to access the App server"
}
