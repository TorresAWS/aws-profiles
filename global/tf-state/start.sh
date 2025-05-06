#!/bin/bash
<<<<<<< HEAD
ln -s    ../../global/providers/cloud.tf ./cloud.tf
=======
rm cloud.tf ; ln -s    ../../global/providers/cloud.tf ./cloud.tf
>>>>>>> 5df2590 (add backend with a single variable)
terraform init   
terraform plan 
terraform apply --auto-approve 
