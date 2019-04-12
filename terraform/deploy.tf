
# Define AWS as our provider
provider "aws" {
  region = "${var.aws_region}"
}

# Define our VPC
resource "aws_vpc" "testVPC" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "test-vpc"
  }
}

# Define the public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.testVPC.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-east-2a"

  tags {
    Name = "Public Subnet"
  }
}

# Define the private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id = "${aws_vpc.testVPC.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "us-east-2b"

  tags {
    Name = "Private Subnet"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.testVPC.id}"

  tags {
    Name = "VPC IGW"
  }
}


# Define the route table
resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.testVPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Public Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "public-rt" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}


# Define the route table for the private subnet
resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.testVPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}" #change to nat instance network_interface_id
  }

  tags {
    Name = "Private Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "private-rt" {
  subnet_id = "${aws_subnet.private-subnet.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}



# Define the security group for public subnet
resource "aws_security_group" "sgweb" {
  name = "vpc_test_web"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

  vpc_id="${aws_vpc.testVPC.id}"

  tags {
    Name = "Web Server SG"
  }
}

# Define the security group for private subnet
resource "aws_security_group" "sgdb"{
  name = "sg_test_web"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.nat.private_ip}/32"] # change here to the private id of the nat instance of the 
  }

egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
  vpc_id = "${aws_vpc.testVPC.id}"

  tags {
    Name = "DB SG"
  }
}


# the security group for the API Instance that will be created
resource "aws_security_group" "api-backend-sg" {
  name        = "api-backend-sg"
  description = "Security group for the API Server Instance"

  # inbound traffic
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.testVPC.id}"

  tags = {
    Name = "api_server_security_group"
  }
}
# Define SSH key pair for our instances
resource "aws_key_pair" "default" {
  key_name = "vpctestkeypair"
  public_key = "${file("${var.key_path}")}"
}

# Define frontend inside the public subnet
resource "aws_instance" "frontend" {
   ami  = "ami-00ab85ee1c3583d40"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
   associate_public_ip_address = true
   source_dest_check = false
 

  tags {
    Name = "frontend"
  }
}

# Define backend inside the public subnet
resource "aws_instance" "backend" {
   ami  = "ami-070e336f6f6468d50"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
   associate_public_ip_address = true
   private_ip ="10.0.1.15"
   source_dest_check = false
 

  tags {
    Name = "backend"
  }
}

# Define the nat instance nside the public subnet
resource "aws_instance" "nat" {
   ami  = "${var.nat-ami}"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
   associate_public_ip_address = true
   source_dest_check = false
 

  tags {
    Name = "Nat instance"
  }
}


# Define database inside the private subnet
resource "aws_instance" "db" {
   ami  = "ami-0c20b79d7fff4621d"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
   associate_public_ip_address = false
   private_ip = "10.0.2.186"
   source_dest_check = false

  tags {
    Name = "database"
  }
}

resource "null_resource" "connect-to-frontend" {
  connection {
    type         = "ssh"
    host         = "${aws_instance.frontend.public_ip}"
    user         = "ubuntu"
    agent        = true
    port         = 22
   
  }

  # // copy our script to the server
  provisioner "file" {
    source      = "files/test.sh"
    destination = "/home/ubuntu/test.sh"
  }
    provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/test.sh",
      "bash /home/ubuntu/test.sh ",
    ]
  }

  depends_on = ["aws_instance.frontend"]
}