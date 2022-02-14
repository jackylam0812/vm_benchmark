# alicloud-variables.tf | Variables for the alicloud module

variable "alicloud_access_key" {
    default = "xxx" # please change to your alicloud access key 
}

variable "alicloud_secret_key" {
    default = "xxx" # please change to your alicloud secret key 
}

variable "alicloud_region" {
  default = "ap-southeast-1"
}

variable "alicloud_az_c" {
  default = "ap-southeast-1c"
}

variable "alicloud_az_b" {
  default = "ap-southeast-1b"
}

variable "alicloud_key_pair" {
  default = "xxx"  # please change to your ECS key pair
}

variable "profile" {
  default = "default"
}