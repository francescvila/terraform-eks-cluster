variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "sandbox"
}

variable "cluster_name" {
  type    = string
  default = "cluster-name-value"
}

variable "k8s_version" {
  type    = string
  default = "k8s-version-value"
}

variable "release_version" {
  type    = string
  default = "release-version-value"
}

variable "min_node_count" {
  type    = number
  default = 3
}

variable "max_node_count" {
  type    = number
  default = 9
}

variable "machine_type" {
  type    = string
  default = "t2.small"
}

variable "state_bucket" {
  type    = string
  default = "state-bucket-value"
}
