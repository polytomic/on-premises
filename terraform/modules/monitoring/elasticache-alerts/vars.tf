variable "name" {
  type = string
}

variable "sns_topic_arns" {
  type = list(string)
}

variable "cache_cluster_id" {
  type = list(string)
}


variable "cpu_utilization_threshold" {
  description = "The maximum percentage of CPU utilization."
  type        = number
  default     = 80
}

variable "freeable_memory_threshold" {
  description = "The minimum amount of available random access memory in Byte."
  type        = number
  default     = 64000000

  # 64 Megabyte in Bytes
}

variable "current_connections_threshold" {
  description = "The maximum number of current connections."
  type        = number
  default     = 1000
}
