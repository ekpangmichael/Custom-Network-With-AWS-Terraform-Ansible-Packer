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