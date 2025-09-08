# просто макет
resource "aws_instance" "portfolio_server" {
  # фиктивные параметры
  ami           = "ami-12345678"
  instance_type = "t3.micro"
  tags = {
    Name        = var.server_name
    Environment = var.environment
    Project     = "devops-portfolio"
  }

  # заглушка
  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}

# виртуальная сеть
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "portfolio-vpc"
  }
}