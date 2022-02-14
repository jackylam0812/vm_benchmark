# alicloud-main.tf | Define Alicloud Provider, VPC, Subnet, Routes, Security Groups, ECS Instance
provider "alicloud" {
  access_key = var.alicloud_access_key
  secret_key = var.alicloud_secret_key
  region = var.alicloud_region
  profile = var.profile
}

resource "alicloud_vpc" "vpc" {
  vpc_name   = "terraform-vpc"
  cidr_block = "172.16.0.0/16"
}

resource "alicloud_vswitch" "vswitch_b" {
  vpc_id            = alicloud_vpc.vpc.id
  cidr_block        = "172.16.0.0/24"
  zone_id           = var.alicloud_az_b
  vswitch_name      = "terraform-vswitch-b"
}

resource "alicloud_vswitch" "vswitch_c" {
  vpc_id            = alicloud_vpc.vpc.id
  cidr_block        = "172.16.1.0/24"
  zone_id           = var.alicloud_az_c
  vswitch_name      = "terraform-vswitch-c"
}

resource "alicloud_security_group" "default" {
  name        = "terraform"
  description = "terraform"
  vpc_id      = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  # nic_type          = "internet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

# ECS-01
resource "alicloud_instance" "benchmark-ecs-01" {
  availability_zone           = var.alicloud_az_b
  instance_name               = "benchmark-ecs"
  image_id                    = "ubuntu_18_04_x64_20G_alibase_20201120.vhd"
  instance_type               = "ecs.g7.2xlarge"
  vswitch_id                  = alicloud_vswitch.vswitch_b.id
  security_groups             = alicloud_security_group.default.*.id
  internet_max_bandwidth_out  = 1
  spot_strategy               = "SpotAsPriceGo"
  system_disk_category        = "cloud_essd"
  system_disk_name            = "benchmark_disk"
  system_disk_description     = "benchmark_disk_description"
  system_disk_size            = 50
  user_data                   = local.startup_script
  key_name                    = var.alicloud_key_pair
}

output "this_instance_ids_01" {
  description = "The instance ids 01."
  value       = alicloud_instance.benchmark-ecs-01.id
}

output "this_public_ip_01" {
  description = "The public ip of the instance 01."
  value       = alicloud_instance.benchmark-ecs-01.public_ip
}

# # ECS-02
# resource "alicloud_instance" "benchmark-ecs-02" {
#   availability_zone           = var.alicloud_az
#   instance_name               = "benchmark-ecs"
#   image_id                    = "ubuntu_18_04_x64_20G_alibase_20201120.vhd"
#   instance_type               = "ecs.g6.xlarge"
#   vswitch_id                  = alicloud_vswitch.vswitch.id
#   security_groups             = alicloud_security_group.default.*.id
#   internet_max_bandwidth_out  = 1
#   spot_strategy               = "SpotAsPriceGo"
#   system_disk_category        = "cloud_efficiency"
#   system_disk_name            = "benchmark_disk"
#   system_disk_description     = "benchmark_disk_description"
#   system_disk_size            = 50
#   user_data                   = local.startup_script
#   key_name                    = var.alicloud_key_pair
# }

# output "this_instance_ids_02" {
#   description = "The instance ids 02."
#   value       = alicloud_instance.benchmark-ecs-02.id
# }

# output "this_public_ip_02" {
#   description = "The public ip of the instance 02."
#   value       = alicloud_instance.benchmark-ecs-02.public_ip
# }