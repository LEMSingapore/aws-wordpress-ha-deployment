# Amazon Linux 2 AMI for ap-southeast-1 (Singapore)
# Using specific AMI ID to avoid permission issues with DescribeImages
locals {
  amazon_linux_2_ami = "ami-0464f90f5928bccb8"  # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
}

# EC2 Instance: cloudserver (Private subnet)
resource "aws_instance" "cloudserver" {
  ami                    = local.amazon_linux_2_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet4.id
  vpc_security_group_ids = [aws_security_group.webserver.id]
  key_name               = var.key_name

  tags = {
    Name = "cloudserver-${var.iam_name}"
  }

  # User data to mount EFS
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y amazon-efs-utils
              mkdir -p /mnt/efs
              echo "${aws_efs_file_system.main.id}:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab
              mount -a
              echo "EFS mounted at /mnt/efs" > /mnt/efs/test.txt
              EOF

  depends_on = [
    aws_nat_gateway.main,
    aws_efs_mount_target.subnet4
  ]
}

# EC2 Instance: webserver (Public subnet)
resource "aws_instance" "webserver" {
  ami                    = local.amazon_linux_2_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.webserver.id]
  key_name               = var.key_name

  tags = {
    Name = "webserver-${var.iam_name}"
  }

  # User data to install NGINX, PHP-FPM, MySQL client
  user_data = <<-EOF
              #!/bin/bash
              # Update system
              yum update -y

              # Install NGINX
              amazon-linux-extras install nginx1 -y
              systemctl start nginx
              systemctl enable nginx

              # Install PHP 7.4 and PHP-FPM
              amazon-linux-extras install php7.4 -y
              yum install -y php-fpm php-mysqli php-json php-gd php-mbstring php-xml

              # Configure PHP-FPM
              sed -i 's/listen = 127.0.0.1:9000/listen = \/run\/php-fpm\/www.sock/' /etc/php-fpm.d/www.conf
              sed -i 's/;listen.owner = nobody/listen.owner = nginx/' /etc/php-fpm.d/www.conf
              sed -i 's/;listen.group = nobody/listen.group = nginx/' /etc/php-fpm.d/www.conf
              sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf
              sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf

              systemctl start php-fpm
              systemctl enable php-fpm

              # Install MySQL client
              yum install -y mysql

              # Download WordPress
              cd /tmp
              wget https://wordpress.org/latest.tar.gz
              tar -xzf latest.tar.gz
              cp -r wordpress /usr/share/nginx/html/
              chown -R nginx:nginx /usr/share/nginx/html/wordpress
              chmod -R 755 /usr/share/nginx/html/wordpress

              # Configure NGINX for WordPress
              cat > /etc/nginx/conf.d/wordpress.conf << 'NGINXCONF'
              server {
                  listen 80;
                  server_name _;
                  root /usr/share/nginx/html/wordpress;
                  index index.php index.html index.htm;

                  location / {
                      try_files \$uri \$uri/ /index.php?\$args;
                  }

                  location ~ \.php$ {
                      fastcgi_pass unix:/run/php-fpm/www.sock;
                      fastcgi_index index.php;
                      fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                      include fastcgi_params;
                  }
              }
              NGINXCONF

              # Remove default NGINX config
              rm -f /etc/nginx/conf.d/default.conf

              # Restart NGINX
              systemctl restart nginx

              # Create info page
              echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php
              chown nginx:nginx /usr/share/nginx/html/info.php
              EOF

  depends_on = [aws_internet_gateway.main]
}

# Associate Elastic IP with webserver
resource "aws_eip_association" "webserver" {
  instance_id   = aws_instance.webserver.id
  allocation_id = aws_eip.webserver.id
}
