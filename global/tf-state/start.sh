#!/bin/bash
<<<<<<< HEAD
<<<<<<< HEAD
ln -s    ../../global/providers/cloud.tf ./cloud.tf
=======
rm cloud.tf ; ln -s    ../../global/providers/cloud.tf ./cloud.tf
>>>>>>> 5df2590 (add backend with a single variable)
=======
rm cloud.tf ; ln -s    ../../global/providers/cloud.tf ./cloud.tf
>>>>>>> 5df2590c20626653835164556da77d4faa7426fd
terraform init   
terraform plan 
terraform apply --auto-approve 
