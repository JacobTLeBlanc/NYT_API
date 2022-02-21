variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "account_id" {
  type        = number
  description = "AWS Account ID"
}

variable "nyt_api_key" {
  type        = string
  description = "Key to access NYT api"
}

variable "log_retention_in_days" {
  type        = number
  default     = 3
  description = "Log retention for lambdas (days)"
}