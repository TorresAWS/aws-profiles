# aws-profiles

## Table of contents
1. [Introduction](#introduction)
2. [Goal](#goal)
3. [Provider configuration](#provider)
4. [Terraform's Back end configuration](#backend)
5. [Using a profile to deploy a hosted Zone](#one)
6. [Using another profile to deploy an ACM Certificates](#two)
7. [Conclusion](#conclusion)

## Introduction <a name="introduction"></a>
Terraform is an open-source Infrastructure as Code (IaC) tool that allows you to automatically build infrastructure defined as code. When working with Terraform it is not only very easy to deploy infrastructure (e.g. Load balancers, VPCs, virtual machines, etc) but <mark> unfortunately, it is also very easy to destroy your infrastructure</mark>. However, some infrastructures such as domain registrations or hosted zones should be protected from accidental wiping. Terraform offers tools to preserve infrastructure (e.g. prevent_destroy lifecycle option). However, these tools are not enough. The safest approach is always to use a dedicated provider account to save those very important pieces of infrastructure. Hence, it is common practice to employ numerous cloud provider accounts when developing infrastructure with Terraform.
Indeed, Terraform offers the option of selecting the cloud provider account that you want to use to develop infrastructure using the <mark>provider</mark>  tag. This is nothing new, having been described before in numerous [posts](https://dev.to/sepiyush/using-terraform-to-manage-resources-in-multiple-aws-accounts-1b61). Still, I decided to describe it here, again, as this is one of my best practices when using Terraform which I extensively used in many of my posts. Hence in the future, I will refer my readers to this post. Still, I will address my approach for dealing with the Terraform's Provider block, avoiding repetition. This post will focus on AWS as a cloud provider only and will show as a proof of concept how a hosted zone can be deployed in an AWS account whereas SSL/TLS X.509 certificates can be deployed in a different account.

## Goal <a name="goal"></a>
<div class="alert alert-block alert-info">
Here I describe how to use multiple profiles when deploying infrastructure with Terraform
</div>

## Provider configuration <a name="provider"></a>
First, I will clone the corresponding GITHub repo and update the cloud profile data showing two different profiles. Mind, this file can only be found in the `global/providers/` folder.

 ```
git clone https://github.com/TorresAWS/aws-profiles
cd global/providers/
vi cloud.tf     # make sure you update your AWS profile info
```
Here is an (edited) example of my `$HOME/.aws/credentials` file that needs to have the same names found in `global/providers/cloud.tf`

```
# vi $HOME/.aws/credentials
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
 
Normally, you will need a `cloud.tf` file with the provider block in each folder containing any of your infrastructure so that Terraform knows about your provider (e.g. AWS, Azure, GCP). Hence one ends up having the same file copied over and over in numerous folders. However, a convenient way to deal with this issue if to use symbolic links when initializing Terraform, as I will describe next.


## Terraform's Back end configuration <a name="backend"></a>

Now I will start Terraform's backend. I will update the names in the backend to avoid conflict:

```
#cd global/tf-state/
cd global/tf-state/
vi backend.tf     # make sure you update the bucket and dynamodb names
vi local.tf           # make sure you update the bucket name
bash start.sh    # at this point the backend is setup
```

If you open the `start.sh` file you will see how a symbolic link was established between the `global/providers/cloud.tf` file and the current folder where infrastructure is being deployed. Also, notice that a profile tag was included in every Terraform resource. For example, below I show the file `global/tf-state/bucket.tf` responsible for creating an S3 bucket for the backend:

```
#cd global/tf-state/bucket.tf
resource "aws_s3_bucket" "terraform_state" {
  provider        =  aws.Infrastructure
  bucket          =  local.aws_s3_bucket_bucket
  lifecycle {
    prevent_destroy = true
  }
}
```

As a quick note to set up Terraform's backend, you need to create an S3 bucket to store the state file and a dynamoDB to save the lock&mdash; so that numerous users can work on the same folder. The `provider=aws.Infrastructure` tags mean that Terraform should use Account 2 to deploy the infrastructure. At the same time, I use the `prevent_destroy = true` tag. Hence, If you try destroying the resource terraform will give an error.  At this point, we have the backend all setup. 
 
## Using a profile to deploy a hosted Zone <a name="one"></a>
Before deploying the hosted zone, we will define all relevant variables:

```
#cd global/variables
bash start.sh    # at this point all variables are defined

```

Now we are ready to deploy the hosted zone in AWS account 1 by simply entering the `vpcs/zone` folder and executing the bash `start.sh` file.

```
#cd vpcs/zone
cd vpcs/zone
bash start.sh    # at this point all variables are defined

```

If you access your AWS account 1 you will see the newly created hosted zone in Route53/Hosted Zones.

## Using another profile to deploy a ACM Certificates <a name="two"></a>
Now we can deploy the certificate in <mark>AWS account 2</mark>, again simply by entering the `vpcs/certs` folder and executing the bash `start.sh` file

```
#cd vpcs/certs
cd vpcs/certs
bash start.sh    # at this point all variables are defined

```

If you now access your <mark>AWS account 2</mark> you will see the newly created certificate in Certificate Manager/List certificates. By inspecting Terraform's files you can see how the `provider` tag was used for example in the `acm_certificate.tf` file.

```
#vi vpcs/certs/acm_certificate.tf
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

```
#vi vpcs/certs/route53_record.tf
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

## Conclusion <a name="conclusion"></a>
Here I have shown how to use the <mark>provider</mark> tag to use different AWS accounts when deploying infrastructure. I applied this method to deploy a hosted zone and an SSL/TLS X.509 certificate. 
 