# Terraform VMWare vDirector deploying script

## Description

This is a basic terraform script which deploying VM, creating vAPP, routed network, DNAT, SNAT FW rules.

#### Attention!!!
This script was written for vDirector which has two VDC, first uses for network resources (vdc_service), second  uses for compute, storage resources (vdc_standard).


## Requrements
- Linux based OS or Windows
- vDirector v.10
- Terraform (>=0.14)
- Administrator acces into vDirector

## Usage

1. Clone this repo
2. Initialize plugins
```
terraform init
```
3. Edit varriables.tf according to your values

4. Edit terraform.tfvars according to your credentials

5. Check all config
```
terraform plan
```
If all is ok
6. Deploy VM
```
terraform apply
```

When terraform ends working it'll show you local VM's ip and password



## License

GPL v3