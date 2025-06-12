variable "aws_access_key" {
  description = "AWS temporary access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS temporary secret key"
  type        = string
  sensitive   = true
}

variable "aws_session_token" {
  description = "AWS temporary session token"
  type        = string
  sensitive   = true
}