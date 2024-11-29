#modb_table-name  = "soc-statefile-lock"
s3-bucket-name    = "{{ account_id }}-us-east-1-terraform-state"

#Network Details
region            = "us-east-2"
vpc_name          = "prod-vpc"
vpc_cidr          = "10.4.0.0/24"

#Cluster Details
cluster_name      = "prod-cluster"
cluster_version   = "1.30"
csi-role-name     = "role"

#Ncpu ode Group Details
node_group_name   = "prod-core-ng"
max_size          = "10"
min_size          = "1"
desired_size      = "2"

#GPU node Group Name
gpu_group_name    = "gpu-manage-ng"
gpu_max_size      = "3"
gpu_min_size      = "1"
gpu_desired_size  = "1"

#Bastion Host Daetails
bastion-host_name = "jum-box"
key_name          = "bastion_key"
account_id        = "843825445314"

#bastion_host_sg  = "bastion_host_sg"
ami_id            = "ami-0ea3c35c5c3284d82"