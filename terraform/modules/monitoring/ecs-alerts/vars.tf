variable "name" {
  type = string
}

variable "sns_topic_arns" {
  type = list(string)
}

variable "cluster_name" {
  type        = string
  description = "The name of the ECS cluster to monitor"
}

variable "service_name" {
  type        = string
  description = "The name of the ECS Service in the ECS cluster to monitor"
  default     = ""
}

variable "cpu_utilization_high_threshold" {
  type        = number
  description = "The maximum percentage of CPU utilization average"
  default     = 80
}


variable "memory_utilization_high_threshold" {
  type        = number
  description = "The maximum percentage of Memory utilization average"
  default     = 80
}

