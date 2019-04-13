
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
    source      = "files/setup_frontend.sh"
    destination = "/home/ubuntu/setup_frontend.sh"
  }
    provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/setup_frontend.sh",
      "export BACKEND_IP=${aws_instance.backend.public_ip}",
      "bash /home/ubuntu/setup_frontend.sh",
      
    ]
  }

  depends_on = ["aws_instance.frontend", "aws_instance.backend"]
}

resource "null_resource" "connect-to-backend" {
  connection {
    type         = "ssh"
    host         = "${aws_instance.backend.public_ip}"
    user         = "ubuntu"
    agent        = true
    port         = 22
   
  }

   # // copy our script to the server
  provisioner "file" {
    source      = "files/backend_migrations.sh"
    destination = "/home/ubuntu/backend_migrations.sh"
  }
    provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/backend_migrations.sh",
      "bash /home/ubuntu/backend_migrations.sh",
    ]
  }

  depends_on = ["aws_instance.backend", "aws_instance.db"]
}