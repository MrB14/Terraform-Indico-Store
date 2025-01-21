variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-3"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "indico-store-eks"
}

variable "major_engine_version" {
  description = "Major version of the database engine"
  type        = string
  default     = "8.0"
}

variable "family" {
  description = "Family of the DB parameter group"
  type        = string
  default     = "mysql8.0"
}
