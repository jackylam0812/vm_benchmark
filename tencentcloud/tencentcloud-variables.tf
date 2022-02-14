# tencentcloud-variables.tf | Variables for the tencentcloud module

variable "tencentcloud_secret_id" {
    default = "xxx" # please change to your tencentcloud access key 
}

variable "tencentcloud_secret_key" {
    default = "xxx" # please change to your tencentcloud secret key 
}

variable "tencentcloud_region" {
  default = "ap-hongkong"
}

variable "tencentcloud_az" {
  default = "ap-hongkong-2"
}

variable "tencentcloud_key_pair" {
  default = "xxx" # please change to your cvm key pair
}