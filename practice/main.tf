


# Simple- one public_subnet, one igw
# Source_Blue_PenDrive= G:\Jenkins cicd\terraform  cicd\DevOps CICD with Jenkins Nexus Ansible Docker Terraform
# Resources as per Terraform for AWS
# aws_vpc =  vpc
# aws_subnet = subnet
# aws_internet_gateway = Internet Gateway
# aws_route_table =  Router, Configuring what subnet the packets will come from n route it to Internet Gateway
# aws_route_table_association = Linking subnet with Router(Route_Table)
# list of objects 
# =================
# cidr_blocks = [
#     { cidr_block = "10.0.0.0/16", name = "dev-vpc" },
#     { cidr_block = "10.0.10.0/24", name ="dev-subnet"}
# ]
# validation:
#                   type = list(object({
                             
#                      cidr_block = string
#                      name = string
#                   }))

##=======================================================================================================


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.3.0"
    }
  }
}

provider "aws" {
  shared_config_files      = ["C:\\Users\\Hello1\\.aws\\config"]
  shared_credentials_files = ["C:\\Users\\Hello1\\.aws\\credentials"]
  profile                  = var.profile
  region                   = var.region
}

output "print_region"{
  value = var.region
}

output "print_profile"{
  value = var.profile
}

# --------------------------------------------------------------------------------------------

# Create vpc.  vpc=  aws_vpc  
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block[0]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.name[0]
  }
}
#---------------------------------------------------------------------------------------------

# Create a Public Subnets. subnet= aws_subnet
resource "aws_subnet" "force_subnet1" { # Creating Public Subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr_block[1] # CIDR block of public subnets
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = var.name[1]
  }
}
#--------------------------------------------------------------------------------------------

# Gateway. gateway = aws_internet_gateway 
resource "aws_internet_gateway" "force_gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.name[2]
  }
}
#---------------------------------------------------------------------------------------------

# route table or router. routetable= aws_route_table
resource "aws_route_table" "force_rout_tab" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.cidr_block[2]
    gateway_id = aws_internet_gateway.force_gw.id
  }
  tags = {
    Name = var.name[3]
  }
}

# route_table_assossiation.  route_table_assossiation = aws_route_table_association
resource "aws_route_table_association" "force_assoc" {
  subnet_id      = aws_subnet.force_subnet1.id
  route_table_id = aws_route_table.force_rout_tab.id
}
#--------------------------------------------------------------------------------------------------

# Create Secutity Group

resource "aws_security_group" "Force_SG" {
  name        = "Force Security Group"
  description = "FORCE- To allow inbound and outbound traffic to mylab"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" { # coming from internet and reaching to subnet and all the ec2 in the subnet
    iterator = port
    for_each = [22, 443, 8080]  # This is the manual way
    #for_each = var.each # this is by defining each variable as list n defining them terraform.tfvars
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block[2]] # koi bhi internet ke ya intranet ke subnet se aaye , only allow  22, 443, 8080
    }
  }

  egress {          # Outgoing Traffic , going out from the subnet to the internet 
    from_port   = 0 # 0 means All 
    to_port     = 0
    protocol    = "-1"          # -1 means all protocol
    cidr_blocks = [var.cidr_block[2]] # koi bhi packet humare kisi bhi machine aur subnet se internet ki taraf jaaye to jaane do
  }

  tags = {
    Name = var.name[4]
  }
}
#---------------------------------------------------------------------------------------------


# output "print"{
#    value = file("${path.module}/temp.txt")
# }

# resource "aws_key_pair" "our-key" {
#   key_name  = "my-key"
#   public_key = file("${path.module}/temp.txt")
# }

# output "key"{
#    value = aws_key_pair.our-key.key_name
# }


# Create an AWS EC2 Instance to host Jenkins

resource "aws_instance" "Force-EC2" {
  ami                         = "ami-012b9156f755804f5"
  instance_type               = var.instance_type
  key_name                    = var.key_name
  # key_name                    =  aws_key_pair.our-key.key_name
  vpc_security_group_ids      = [aws_security_group.Force_SG.id]
  subnet_id                   = aws_subnet.force_subnet1.id
  associate_public_ip_address = true
  count                       = 1

  tags = {
    Name = var.name[5]
  }
 provisioner "file" {
    source      = "README.md"
    destination = "/tmp/README.md"
  }
  
  
}


