#!/bin/bash
rm cloud.tf ; ln -s    ../../global/providers/cloud.tf ./cloud.tf
terraform init   
terraform plan 
terraform apply --auto-approve 
