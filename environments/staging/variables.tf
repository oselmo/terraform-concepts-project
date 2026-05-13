variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "scaling_config" {
  type = object({
    min = number
    max = number
  })
  default = { min = 2, max = 4 }
}

variable "environment" {
  description = "The name of the environment (e.g., dev, prod)"
  type        = string
  default     = "staging"
}

