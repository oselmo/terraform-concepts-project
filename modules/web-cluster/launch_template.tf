# Launch Template for EC2 Instances
resource "aws_launch_template" "app" {
  name_prefix   = "app-launch-template"
  image_id      = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI ID (change as needed)
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.instance_sg.id]
  }

  iam_instance_profile {
  name = aws_iam_instance_profile.instance_profile.name
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
        export HOME=/root
        export NVM_DIR="/root/.nvm"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        source "$NVM_DIR/nvm.sh"
        nvm install 16.20.2
        nvm use 16.20.2

        # Verify installation
        node -v
        npm -v

        # Install Ruby and Bundler
        amazon-linux-extras install -y ruby2.6
        yum install -y ruby-devel
        gem install bundler -v 2.3.27

        # Verify installation
        ruby --version
        bundle --version

        # Start Apache and enable it to start on boot
        systemctl start httpd
        systemctl enable httpd

        # Clone the repo
        git clone https://github.com/oselmo/terraform-concepts-project /opt/repo

        # Install Ruby deps
        cd /opt/repo/app/backend
        bundle install

        # build React
        cd /opt/repo/app/frontend
        npm install
        npm run build
        # outputs static files to /opt/repo/app/frontend/dist

        # Start Sinatra in background
        cd /opt/repo/app/backend
        ruby server.rb &

        # Point Apache at the React build
        cp -r /opt/repo/app/frontend/dist/* /var/www/html/

        # configure Apache
        echo "ProxyPass /api http://localhost:4567/api
        ProxyPassReverse /api http://localhost:4567/api" >> /etc/httpd/conf/httpd.conf

        systemctl restart httpd

        EOF
  )
}