variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type to use for the application"
}

variable "scaling_config" {
  type = object ({
    min = number
    max = number
  })

  validation {
    condition     = var.scaling_config.min <= var.scaling_config.max
    error_message = "Minimum capacity must be less than or equal to max_capacity."
  }

  validation {
    condition     = var.scaling_config.min >= 0
    error_message = "Minimum capacity cannot be negative."
  }
}

variable "environment" {
  description = "The name of the environment (e.g., dev, prod)"
  type        = string
}

# modules/web-cluster/variables.tf
variable "vpc_id" {
  type = string
}

variable "alb_subnet_ids" {
  type = list(string)
}

variable "instance_subnet_ids" {
  type = list(string)
}