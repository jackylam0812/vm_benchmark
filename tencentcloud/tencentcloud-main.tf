# tencentcloud-main.tf | Define Tencentcloud Provider, VPC, Subnet, Routes, Security Groups, CVM Instance
provider "tencentcloud" {
  secret_id = var.tencentcloud_secret_id
  secret_key = var.tencentcloud_secret_key
  region = var.tencentcloud_region
}

resource "tencentcloud_vpc" "vpc" {
  name       = "terraform-vpc"
  cidr_block = "172.16.0.0/16"
}

resource "tencentcloud_subnet" "subnet" {
  vpc_id            = tencentcloud_vpc.vpc.id
  cidr_block        = "172.16.0.0/24"
  availability_zone = var.tencentcloud_az
  name              = "terraform-subnet"
}

resource "tencentcloud_security_group" "default" {
  name        = "terraform"
  description = "terraform"
}

resource "tencentcloud_security_group_rule" "ssh" {
  security_group_id = tencentcloud_security_group.default.id
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "22"
  policy            = "accept"
}

resource "tencentcloud_security_group_rule" "egress" {
  security_group_id = tencentcloud_security_group.default.id
  type              = "egress"
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
}

# CVM 01
resource "tencentcloud_instance" "benchmark-ecs-01" {
  availability_zone           = var.tencentcloud_az
  vpc_id                      = tencentcloud_vpc.vpc.id
  subnet_id                   = tencentcloud_subnet.subnet.id
  instance_name               = "benchmark-ecs"
  image_id                    = "img-pi0ii46r"
  instance_type               = "S5.MEDIUM8"
  allocate_public_ip          = "true"
  instance_charge_type        = "SPOTPAID"
  spot_instance_type          = "ONE-TIME"
  spot_max_price              = "0.72"
  security_groups             = tencentcloud_security_group.default.*.id
  internet_max_bandwidth_out  = 1
  system_disk_type            = "CLOUD_PREMIUM"
  system_disk_size            = 50
  user_data_raw               = local.startup_script
  key_name                    = var.tencentcloud_key_pair
}

output "this_instance_ids_01" {
  description = "The instance ids 01."
  value       = tencentcloud_instance.benchmark-ecs-01.id
}

output "this_public_ip_01" {
  description = "The public ip of the instance 01."
  value       = tencentcloud_instance.benchmark-ecs-01.public_ip
}

# # CVM 02
# resource "tencentcloud_instance" "benchmark-ecs-02" {
#   availability_zone           = var.tencentcloud_az
#   vpc_id                      = tencentcloud_vpc.vpc.id
#   subnet_id                   = tencentcloud_subnet.subnet.id
#   instance_name               = "benchmark-ecs"
#   image_id                    = "img-pi0ii46r"
#   instance_type               = "S1.LARGE16"
#   allocate_public_ip          = "true"
#   instance_charge_type        = "SPOTPAID"
#   spot_instance_type          = "ONE-TIME"
#   spot_max_price              = "1.4"
#   security_groups             = tencentcloud_security_group.default.*.id
#   internet_max_bandwidth_out  = 1
#   system_disk_type            = "CLOUD_PREMIUM"
#   system_disk_size            = 50
#   user_data_raw               = local.startup_script
#   key_name                    = var.tencentcloud_key_pair
# }

# output "this_instance_ids_02" {
#   description = "The instance ids 02."
#   value       = tencentcloud_instance.benchmark-ecs-02.id
# }

# output "this_public_ip_02" {
#   description = "The public ip of the instance 02."
#   value       = tencentcloud_instance.benchmark-ecs-02.public_ip
# }

