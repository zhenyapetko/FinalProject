variable "server_name" {
  description = "Name for the server"
  type        = string
  default     = "portfolio-server"
}

variable "environment" {
  description = "Environment (dev, prod, stage)"
  type        = string
  default     = "prod"
}