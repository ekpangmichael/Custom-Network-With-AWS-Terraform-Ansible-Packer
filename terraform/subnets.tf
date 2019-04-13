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
