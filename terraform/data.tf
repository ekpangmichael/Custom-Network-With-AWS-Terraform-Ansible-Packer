data "aws_ami" "backend" {
  most_recent = true

  filter {
    name   = "name"
    values = ["authors-haven-backend"]
  }

  owners = ["387883916874"] 
}
data "aws_ami" "frontend" {
  most_recent = true

  filter {
    name   = "name"
    values = ["authors-haven-frontend"]
  }

  owners = ["387883916874"] 
}

data "aws_ami" "database" {
  most_recent = true

  filter {
    name   = "name"
    values = ["authors-haven-database"]
  }

  owners = ["387883916874"] 
}

