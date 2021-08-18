variable "v_login" {
	description = "your vDirector login"
	type = string
}

variable "v_pass" {
	description = "you vDirector Pass"
	type = string
}	
variable "url_api" {
	description = "url to vDirector API"
	type = string
	default = "https://vcd.vdcportal.com/api" 
}

variable "v_org" {
	description = "your v_org name e.g. org_134821"
	type = string
	default = "org_134821"
}
variable "v_vdc_s" {
	description = "your service v_org name e.g. org_134821_service"
	type = string
	default = "vdc_134821_service"
}
variable "v_vdc" {
	description = "vdc name e.g. vdc_134821_standard"
	type = string
	default = "vdc_134821_standard"
}

variable "v_edge" {
	description = "name of your EDGE e.g. Edge-134821"
	type = string
	default = "Edge-134821"
}

variable "ct_name" {
	description = "Catalog name with templates e.g.MSK, NY, Ath etc."
	type = string
	default = "NY"
}

variable "ext_net" {
	description = "name of your ext_net e.g. ExtNet_vlan_236"
	type = string
	default = "ExtNet_vlan_236"
}

variable "ext_ip" {
	description = "your external ip"
	type = string
	default = "78.32.45.127"
}
