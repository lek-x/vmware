provider "vcd" {
  user                 = var.v_login                     
  password             = var.v_pass                    
  auth_type            = "integrated"
  org                  = var.v_org                 
  vdc                  = var.v_vdc          
  url                  = var.url_api          
  max_retry_timeout    = 60
  allow_unverified_ssl = "true"
}

###  Creating routed network
resource "vcd_network_routed" "routed-net" {
  org = var.v_org                            
  vdc = var.v_vdc_s                  

  name         = "routed1"
  edge_gateway = var.v_edge             
  gateway      = "192.168.0.1"
  shared       = "true"

  dhcp_pool {
    start_address = "192.168.0.2"
    end_address   = "192.168.0.15"
  }

  static_ip_pool {
    start_address = "192.168.0.16"
    end_address   = "192.168.0.25"
  }
}


#Creating vAPP
resource "vcd_vapp" "terraform" {
  name = "terra"
}

resource "vcd_vapp_org_network" "routed-net" {
  vapp_name        = vcd_vapp.terraform.name
  org_network_name = vcd_network_routed.routed-net.name
  
}
  
#Creating vNET into vAPP
#resource "vcd_vapp_network" "vnet" {
#  name               = "vAPPnet"
#  vapp_name          = vcd_vapp.terraform.name
#  gateway            = "192.168.1.1"
#  netmask            = "255.255.255.0"
#  dns1               = "192.168.1.1"
#  dns2               = "192.168.1.1"
#  dns_suffix         = "test.test"
#  guest_vlan_allowed = false
#  
#  static_ip_pool {
#    start_address = "192.168.1.2"
#    end_address   = "192.168.1.15"
#  }
#} 

#Creating VM in vAPP 
resource "vcd_vapp_vm" "terraform" {
  vapp_name     = vcd_vapp.terraform.name
  name          = "VM1"
  catalog_name  = "MSK"
  template_name = "centos76-x86-64"
  memory        = 1024
  cpus          = 2
  cpu_cores     = 1
  storage_profile = "FAST"
  hardware_version  = "vmx-14"
  power_on      = "true"
  computer_name = "TestVM"
  guest_properties = {
    "guest.hostname"   = "testhost1"
  }
  
  network {
    type               = "org"
    name               = vcd_vapp_org_network.routed-net.org_network_name
    ip_allocation_mode = "POOL"
    is_primary         = true
  }
}


#Setting up ICMP for VM1
resource "vcd_nsxv_dnat" "forIcmp" {
  org = var.v_org                      
  vdc = var.v_vdc_s                 

  edge_gateway = var.v_edge          
  network_name = var.ext_net    
  network_type = "ext"

  original_address   = var.ext_ip
  translated_address = lookup(element(vcd_vapp_vm.terraform.network, 0),"ip")
  protocol           = "icmp"
  icmp_type          = "router-advertisement"
}


#Setting up sNAT for whole network  vnet
resource "vcd_nsxv_snat" "snatvm1" {
  org = var.v_org 
  vdc = var.v_vdc_s 

  edge_gateway = var.v_edge
  network_type = "ext"
  network_name = var.ext_net

  original_address   = "192.168.0.0/24"
  translated_address = var.ext_ip
}


#Setting up dNAT for VM1
resource "vcd_nsxv_dnat" "dnatssh22" {
  org = var.v_org                       
  vdc = var.v_vdc_s                

  edge_gateway = var.v_edge         
  network_name = var.ext_net    
  network_type = "ext"

  original_address   = var.ext_ip
  original_port      = 22
  
  translated_address = lookup(element(vcd_vapp_vm.terraform.network, 0),"ip")
  translated_port    = 22
  
  protocol           = "tcp"

}

#Firewall rule for ingress traffic  ssh port 22 for VM1
resource "vcd_nsxv_firewall_rule" "ssh22" {
  org          = var.v_org
  vdc          = var.v_vdc_s
  edge_gateway = var.v_edge

  source {
    ip_addresses       = ["any"]
    gateway_interfaces = ["internal"]
  }

  destination {
    ip_addresses = [var.ext_ip]
  }
  service {
    protocol = "icmp"
  }
  
  service {
    protocol = "tcp"
    port     = "22"
  }
}



output "local_ip" {
  value = lookup(element(vcd_vapp_vm.terraform.network, 0),"ip")
}

output "pass_for_vm" {
  value = lookup(element(vcd_vapp_vm.terraform.customization, 0),"admin_password")
}

