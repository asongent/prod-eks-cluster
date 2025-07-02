
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.identifier}-sng"
  subnet_ids = var.private_subnet_id
}

# resource "aws_security_group" "allow_postgres_traffic" {
#   name        = var.rds-sg-name
#   description = "Allow Postgres traffic"
#   vpc_id      = var.vpc_id

#   ingress {
#     description = "allow Postgres"
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     cidr_blocks = [var.vpc_cidr]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   # tags = {
#   #   Name = "allow postgres"
#   # }
# }

# resource "aws_security_group_rule" "bastion_host" {
#   type                     = "ingress"
#   from_port                = 443
#   to_port                  = 443
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.allow_postgres_traffic.id
#   security_group_id        = var.cluster_sg
# }

resource "aws_db_instance" "postgres" {
  # count                  = length(data.aws_availability_zones.source.names)
  allocated_storage      = var.storage
  engine                 = var.engine_type
  engine_version         = var.engine_version
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  instance_class         = var.rds_instance_class
  identifier             = var.identifier
  publicly_accessible    = var.publicly_accessible
  username               = var.user_name
  password               = var.db_password
  multi_az               = false
  skip_final_snapshot    = var.snapshot
  vpc_security_group_ids = [var.rds_sg_id]
  depends_on             = [aws_db_subnet_group.db_subnet_group]
}