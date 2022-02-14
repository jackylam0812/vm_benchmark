terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {

  credentials = file(var.gcp_credentials_file)

  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network-benchmark-${random_string.random.result}"
}

resource "google_compute_firewall" "ssh" {
  name    = "ssh-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["web"]
}

# ---- VM01 ----
# if you want to launch more machine type for testing, please copy below with new resource name to create another VM
resource "google_compute_instance" "benchmark-vm01" {
  name         = "terraform-instance-benchmark-vm01"
  machine_type = "n2-standard-4"   # VM machine type
  min_cpu_platform = "Intel Icelake"    # Specifies a minimum CPU platform for the VM instance if need.
  allow_stopping_for_update = true
  labels       = {name = "terraform" , usage = "benchmark"}
  metadata_startup_script = local.startup_script 
  
  scheduling {
    preemptible = true
    automatic_restart = false
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"  # ubuntu18.04 for testing env
      size =  50   # use a large storage to store testing suite if needed
      type = "pd-ssd"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}

# # ---- VM02 ----
# # if you want to launch more machine type for testing, please copy below with new resource name to create another VM
# resource "google_compute_instance" "benchmark-vm02" {
#   name         = "terraform-instance-benchmark-vm02"
#   machine_type = "n1-standard-4"   # VM machine type
#   min_cpu_platform = "Intel Skylake"    # Specifies a minimum CPU platform for the VM instance if need.
#   allow_stopping_for_update = true
#   labels       = {name = "terraform" , usage = "benchmark"}
#   metadata_startup_script = local.startup_script 
  
#   scheduling {
#     preemptible = true
#     automatic_restart = false
#   }

#   boot_disk {
#     initialize_params {
#       image = "ubuntu-os-cloud/ubuntu-1804-lts"  # ubuntu18.04 for testing env
#       size =  50   # use a large storage to store testing suite if needed
#       type = "pd-ssd"
#     }
#   }

#   network_interface {
#     network = google_compute_network.vpc_network.name
#     access_config {
#     }
#   }
# }