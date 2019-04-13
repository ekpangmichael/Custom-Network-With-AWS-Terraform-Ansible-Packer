
# Define frontend inside the public subnet
resource "aws_instance" "frontend" {
   ami  = "${data.aws_ami.frontend.id}"
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
   ami  = "${data.aws_ami.backend.id}"
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
   ami  = "${data.aws_ami.database.id}"
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