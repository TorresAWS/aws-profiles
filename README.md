
## Table of contents
1. [Introduction](#introduction)
2. [Goal: use multiple profiles when deploying infrastructure](#goal)
3. [Configuring multiple providers](#provider)
4. [Terraform's Back end configuration](#backend)
5. [Using a Domain profile to deploy a hosted Zone](#one)
6. [Using an Infrastructure profile to deploy an ACM Certificate](#two)
7. [Conclusion: multiaccount environments enhance infrastructure security](#conclusion)

## Introduction <a name="introduction"></a>
Terraform is an open-source Infrastructure as Code (IaC) tool that allows you to automatically build infrastructure defined as code. When working with Terraform it is very easy to deploy infrastructure (e.g. Load balancers, VPCs, virtual machines, etc) but <mark> unfortunately, it is also very easy to destroy infrastructure</mark>. Some pieces of infrastructure such as domain registrations or hosted zones should be protected from accidental wiping. The safest approach to avoid this problem (besides using the prevent_destroy lifecycle option) is isolating workloads using dedicated provider accounts to save those very important pieces of infrastructure. Hence, when developing infrastructure with Terraform it is common practice to employ numerous cloud provider accounts.

Indeed, it is not new that Terraform offers the option of selecting the [provider account](https://dev.to/sepiyush/using-terraform-to-manage-resources-in-multiple-aws-accounts-1b61) that you want to use to develop infrastructure using the <mark>provider</mark>  tag. Still, this is one of my best practices when using Terraform hence I decided to describe it here for documenting purposes.

This post  will demonstrate that by using multiaccount environments one can deploy a hosted zone and a SSL/TLS X.509 certificate in different provider's accounts, using AWS as a cloud provider.



## Goal: use multiple profiles when deploying infrastructure <a name="goal"></a>
<div class="alert alert-block alert-info">
Here I describe how to use multiple profiles when deploying infrastructure with Terraform
</div>

## Configuring multiple providers <a name="provider"></a>
First, I will clone the corresponding GITHub repo and update the cloud profile data showing two different profiles. Mind, this file can only be found in the `global/providers/` folder.

```
git clone https://github.com/TorresAWS/aws-profiles
cd global/providers/
vi cloud.tf     # make sure you update your AWS profile info
```

Here is an example of my `$HOME/.aws/credentials` file 

<h5 a><strong><code>vi $HOME/.aws/credentials</code></strong></h5>

```
[Domain]
#Associated with email email1@gmail.com
#Account #1
aws_access_key_id = AKIAZA6SHHSHSFFKS
aws_secret_access_key = 5RMzkJmBXFakeLtU+KMe4a2ygjAQ/5X5
region=us-east-1
output = json

[Infrastructure]
#Associated with email email2@gmail.com
#Account #2
aws_access_key_id = AKIA2344553N67CLFN5
aws_secret_access_key = gzXKcDvfakeagainDL5+UMYN9bSE87dFdE
region=us-east-1
output = json
 ```

that needs to have the same names found in `global/providers/cloud.tf`
<h5 a><strong><code>vi global/providers/cloud.tf</code></strong></h5>

```
provider "aws" {
        shared_config_files      = ["$HOME/.aws/config"]
        shared_credentials_files = ["$HOME/.aws/credentials"]
        alias  = "Infrastructure"
        profile  = "Infrastructure"
        }

provider "aws" {
        shared_config_files      = ["$HOME/.aws/config"]
        shared_credentials_files = ["$HOME/.aws/credentials"]
        alias  = "Domain"
        profile  = "Domain"
        }
 ```


Normally, you will need a `cloud.tf` file with the provider block in each folder containing any of your infrastructure so that Terraform knows about your provider (e.g. AWS, Azure, GCP). Hence one ends up having the same file copied over and over in numerous folders. However, <mark>a convenient way to deal with this issue if to use symbolic links when initializing Terraform</mark>. In oder to start every piece of infrastructure in this example, you will have to execute a bash file called `start.sh`. If you open the file you will find:

<h5 a><strong><code>vi global/tf-state/start.sh</code></strong></h5>

```
#!/bin/bash
rm cloud.tf
ln -s    ../../global/providers/cloud.tf ./cloud.tf
terraform init
terraform plan
terraform apply --auto-approve
```

As you can see, this file stablishes a symbolic link between the `cloud.tf` file locates in `global/providers` into the current folder. This way, I will have a single providers block located in `global/providers` which can be uses throughout the infrastructure.


## Terraform's Back end configuration <a name="backend"></a>
Now I will start Terraform's backend which is <mark>defined with a single variable</mark> in `backendname.tf`. I will update the backend name to avoid conflict:

<h5 a><strong><code>cd global/tf-state/</code></strong></h5>
```
cd global/tf-state/
vi backendname.tf    # make sure you update the bucket and dynamodb names into a unique name
bash start.sh    # at this point the backend is setup
```
If you open the `start.sh` file you will see how a symbolic link was established between the `global/providers/cloud.tf` file and the current folder where infrastructure is being deployed. Also, notice that a profile tag was included in every Terraform resource. For example, below I show the file `global/tf-state/bucket.tf` responsible for creating an S3 bucket for the backend:

<h5 a><strong><code>cd global/tf-state/bucket.tf</code></strong></h5>
```
resource "aws_s3_bucket" "terraform_state" {
  provider        =  aws.Infrastructure
  bucket          =  local.aws_s3_bucket_bucket
  lifecycle {
    prevent_destroy = true
  }
}
```
I achieved a backend defined by a single variable by means of the following trick. I used a local resource that creates a file `backend.hcl` with the bucket and DB name defined in a local variable called `aws_s3_bucket_bucket`. The local resource file is shown below:

<h5 a><strong><code>cd global/tf-state/create-backend-file.tf</code></strong></h5>

```
resource "local_file" "create-backend-file" {
    content  = <<EOF
bucket         = "${local.aws_s3_bucket_bucket}"
dynamodb_table = "${local.aws_s3_bucket_bucket}"
region         = "us-east-1"
encrypt        = "true"
    EOF
    filename = "../../global/tf-state/backend.hcl"
}
```

At the same time, the backend unique name is saved as a variable in the `variables` folder so that it can be carried out throughout the infrastructure without having to repeate the name. This was achieved by means a local resource that saves the backend name as variable in the variable's folder:
<h5 a><strong><code>cd global/tf-state/exportvariable-to-global-variables.tf</code></strong></h5>

```
resource "local_file" "exportbackend-to-global-variables" {
    content  = <<EOF
variable "backendname" {
  default = "${local.aws_s3_bucket_bucket}"   
}
    EOF
    filename = "../../global/variables/backendname-var.tf"
}
```
You can learm more about variables in [another post](https://www.headinthecloud.xyz/blog/projectwide-variables/).

As a quick note to set up Terraform's backend, you need to create an S3 bucket to store the state file and a dynamoDB to save the lock&mdash; so that infrastucture can be saved in source control and for example numerous users can work on the same folder. The `provider=aws.Infrastructure` tags mean that Terraform should use Account 2 to deploy the infrastructure. At the same time, I use the `prevent_destroy = true` tag. Hence, If you try destroying the resource terraform will give an error.  At this point, we have the backend all setup. 
To be able to use a single variable to define our backend, I used a local-file resource that creates the backend file `backend.hcl`. This way both the DB and the bucket are named according to `backendname.tf` and hence this one variable defines the backend.
 
## Using a Domain profile to deploy a hosted Zone <a name="one"></a>
Before deploying the hosted zone, we will define all relevant variables:

<h5 a><strong><code>cd global/variables</code></strong></h5>

```
bash start.sh    # at this point all variables are defined

```
Now we are ready to deploy the hosted zone in AWS account 1 by simply entering the `vpcs/zone` folder and executing the bash `start.sh` file.

<h5 a><strong><code>cd vpcs/zone</code></strong></h5>

```
cd vpcs/zone
bash start.sh    # at this point all variables are defined

```

If you access your AWS account 1 you will see the newly created hosted zone in Route53/Hosted Zones.

## Using another profile to deploy a ACM Certificates <a name="two"></a>
Now we can deploy the certificate in <mark>AWS account 2</mark>, again simply by entering the `vpcs/certs` folder and executing the bash `start.sh` file

<h5 a><strong><code>cd vpcs/certs</code></strong></h5>

```
cd vpcs/certs
bash start.sh    # at this point all variables are defined

```

If you now access your <mark>AWS account 2</mark> you will see the newly created certificate in Certificate Manager/List certificates. By inspecting Terraform's files you can see how the `provider` tag was used for example in the `acm_certificate.tf` file.

<h5 a><strong><code>vi vpcs/certs/acm_certificate.tf</code></strong></h5>

```
resource "aws_acm_certificate" "domain" {
  provider                     =  aws.Infrastructure
  domain_name       = "${data.terraform_remote_state.variables.outputs.domain}"
  validation_method = "DNS"
  subject_alternative_names = ["www.${data.terraform_remote_state.variables.outputs.domain}"]
  lifecycle {
    create_before_destroy = true
  }
}
```

As you can see this resource will be deployed in <mark>AWS account 2</mark>, however by inspecting the `route53_record.tf` file you can see that the set of CNAME records needed for the certificate validation is indeed created in <mark>AWS account 1</mark>, the account that hosts the domain. As a note, CNAME records are just DNS record that maps an alias to the canonical domain name, allowing multiple names to point to the same location.

<h5 a><strong><code>vi vpcs/certs/route53_record.tf</code></strong></h5>

```
resource "aws_acm_certificate" "domain" {
  provider                     =  aws.Infrastructure
  domain_name       = "${data.terraform_remote_state.variables.outputs.domain}"
  validation_method = "DNS"
  subject_alternative_names = ["www.${data.terraform_remote_state.variables.outputs.domain}"]
  lifecycle {
    create_before_destroy = true
  }
}
```

## Conclusion: multiaccount environments enhance infrastructure security <a name="conclusion"></a>
<div class="alert alert-block alert-info">
Here I have shown how to use the <mark>provider</mark> tag to use different AWS accounts when deploying infrastructure. I applied this method to deploy a hosted zone and an SSL/TLS X.509 certificate. 
</div>


 
 
 
