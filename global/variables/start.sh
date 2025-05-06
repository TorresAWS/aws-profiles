#!/bin/bash
<<<<<<< HEAD
backend="../../global/tf-state/backend.hcl"
ln -s    ../../global/providers/cloud.tf ./cloud.tf
terraform init -backend-config=$backend  
=======
rm cloud.tf ; ln -s    ../../global/providers/cloud.tf ./cloud.tf
terraform init   
>>>>>>> 5df2590 (add backend with a single variable)
terraform plan 
terraform apply --auto-approve 
