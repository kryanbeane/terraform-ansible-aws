# Terraform and Ansible - HA Proxy Load Balancing with AWS

## Instructions to test
- First, make sure you're authorized with AWS. I usually test this by running `aws s3 ls` and ensure I either get a list of buckets or if no buckets then no error should suffice.
  
- Run the following commands:
  
    ```
    git clone git@github.com:kryanbeane/terraform-ansible-aws.git
    cd terraform-ansible-aws
    terraform init
    terraform plan
    terraform apply
    ```