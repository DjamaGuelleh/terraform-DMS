terraform {
  required_version = ">=0.13.0"
}

provider "aws" {
  region  = "us-east-1"
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}


data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "default_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

data "aws_ssm_parameter" "amazon_linux2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "source_mysql_key" {
  key_name   = "source_mysql"
  public_key = file(var.private-key-file)
}

resource "aws_security_group" "security_group_dms" {
  name        = "security_group_dms"
  description = "TCP/22"
  vpc_id      = data.aws_vpc.default_vpc.id
  ingress {
    description = "Allow anyone on port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow anyone on port 3306"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

#Add a rule to allow DMS replication instance to access 3306 within EC2/RDS SG
resource "aws_security_group_rule" "add_dms_replication_ip_to_sg" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [join("", [element(aws_dms_replication_instance.dms-instance.replication_instance_public_ips, 0), "/32"])]
  security_group_id = aws_security_group.security_group_dms.id
}


#Target RDS Instance
resource "aws_db_instance" "target_mysql_rds" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0.32"
  instance_class         = "db.t3.micro"
  db_name                = "target_mysql"
  username               = "admin"
  password               = var.password
  vpc_security_group_ids = [aws_security_group.security_group_dms.id]
  skip_final_snapshot    = true
}

