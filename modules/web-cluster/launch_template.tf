# Launch Template for EC2 Instances
resource "aws_launch_template" "app" {
  name_prefix   = "app-launch-template"
  image_id      = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI ID (change as needed)
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.instance_sg.id]
  }

  user_data = base64encode(<<-EOF
        #!/bin/bash
        export APP_ENV="${var.environment}"

        # Update the instance and install necessary packages
        yum update -y

        # Install development tools and dependencies
        yum groupinstall -y "Development Tools"
        yum install -y curl wget git tar
        yum install -y httpd wget unzip
        
        # Install NodeJS
        curl -sL https://rpm.nodesource.com/setup_16.x | bash -
        yum install -y nodejs

        # Verify installation
        node -v
        npm -v

        # Install Ruby and Bundler
        amazon-linux-extras install -y ruby2.6
        gem install bundler -v 2.3.27


        # Verify installation
        ruby --version
        bundle --version

        # Start Apache and enable it to start on boot
        systemctl start httpd
        systemctl enable httpd

        # Clone the repo
        git clone https://github.com/oselmo/terraform-concepts-project /opt/app

        # Install Ruby deps
        cd /opt/app/app/backend
        bundle install

        # build React
        cd /opt/app/app/frontend
        npm run build
        # outputs static files to /opt/app/app/frontend/dist

        # Start Sinatra in background
        cd /opt/app/app/backend
        ruby server.rb &

        # Point Apache at the React build
        cp -r /opt/app/app/frontend/dist/* /var/www/html/

        # configure Apache
        echo "ProxyPass /api http://localhost:4567/api
        ProxyPassReverse /api http://localhost:4567/api" >> /etc/httpd/conf/httpd.conf

        systemctl restart httpd

        EOF
  )
}