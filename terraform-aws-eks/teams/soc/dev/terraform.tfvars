#modb_table-name  = "soc-statefile-lock"
s3-bucket-name = "{{ account_id }}-us-east-1-terraform-state"

account_id = "84"

#Network Details
region   = "us-east-2"
vpc_name = "prod-vpc"
vpc_cidr = "10.4.0.0/24"

###Cluster Details
cluster_name    = "prod-cluster"
cluster_version = "1.31"
private_access  = "false"
public_access   = "true"
#csi-role-name   = "csi-driver-role" #This has been replaced by Pod Identity

###Cpu Node Group Details
node_group_name = "prod-core-ng"
max_size        = "10"
min_size        = "1"
desired_size    = "1"

### Karpenter nodes
Karp_ng_name = "karpenter-ng"
desired      = "1"
max          = "2"
min          = "1"

###GPU node Group Name
gpu_group_name   = "gpu-manage-ng"
gpu_max_size     = "3"
gpu_min_size     = "1"
gpu_desired_size = "1"

##Bastion Host Daetails
bastion-host_name = "jum-box"
bastion_sg_name   = "jump-host-sg"
key_name          = "bastion_host"
ami_id            = "ami-04f167a56786e4b09"

##RDS Postgres details
rds-sg-name = "rds-psql-sg"
# subnet_group_name   = "prod-rds-subnet"
engine_type         = "postgres"
rds_instance_class  = "db.t3.micro"
user_name           = "fredgent"
db_password         = "Z2hoamRyeWV2Z2VmCg"
storage             = "30"
engine_version      = "14"
publicly_accessible = "false"
snapshot            = "true"
identifier          = "prod-rds-postgres"