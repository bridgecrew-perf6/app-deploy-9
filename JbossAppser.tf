provider "aws" {
  access_key = "AKIASEBXJS56UV4N7VI6"
  secret_key = "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"
  region     = "ca-central-1"
}
#Creating security group,allow ssh and http
resource "aws_security_group" "test-terra-ssh-http" {
  name        = "test-terra-ssh-http"
  description = "allowing ssh and http traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#security group ends here.
#Creating instance
resource "aws_instance" "hello-Jboss_Terra" {
  ami             = "ami-09321d7714bae0aab"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.test-terra-ssh-http.name}"]
  key_name        = "terraform1"
  user_data       = <<-EOF
           #! /bin/bash
          sudo yum update -y
          sudo yum install -y nginx >> /tmp/install.log
          sudo yum install -y openjdk-7-jdk >> /tmp/install.log

          cd /tmp
          wget http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.tar.gz
          tar xfvz jboss-as-7.1.1.Final.tar.gz
          mv jboss-as-7.1.1.Final /usr/local/share/jboss
          adduser appserver
          chown -R appserver /usr/local/share/jboss

          echo "Completed Install." >> /tmp/install.log

          # Start the JBoss server
          su - appserver -c '/usr/local/share/jboss/bin/standalone.sh -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0 &'
          EOF
  tags = {
    name = "Raghu_terra_ec2_Webserver_JbossAppserver"
  }
}