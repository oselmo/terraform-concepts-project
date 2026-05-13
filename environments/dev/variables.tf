variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "scaling_config" {
  type = object({
    min = number
    max = number
  })
  default = { min = 1, max = 2 }
}

variable "environment" {
  description = "The name of the environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

