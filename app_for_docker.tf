resource "aws_vpc" "staging-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Env = "staging"
  }
}

resource "aws_subnet" "staging-pub-sub-a" {
  vpc_id = "${aws_vpc.staging-vpc.id}"
  availability_zone = "ap-northeast-1a"
  cidr_block = "10.0.0.0/24"

  tags = {
    Env = "staging"
  }
}

resource "aws_internet_gateway" "staging-gw" {
  vpc_id = "${aws_vpc.staging-vpc.id}"
}

resource "aws_route_table" "staging-route-table" {
  vpc_id = "${aws_vpc.staging-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.staging-gw.id}"
  }
}

resource "aws_route_table_association" "stagin-assc-a" {
    subnet_id = "${aws_subnet.staging-pub-sub-a.id}"
    route_table_id = "${aws_route_table.staging-route-table.id}"
}

resource "aws_security_group" "staging-ec2-sg" {
    name = "staging-ec2-sg"
    vpc_id = "${aws_vpc.staging-vpc.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # Set your ip address or comment out this block.
    }

    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "staging-ec2" {
  ami = "ami-03179588b2f59f257"
  instance_type = "t3.micro"
  subnet_id = "${aws_subnet.staging-pub-sub-a.id}"
  # key_name = "" - your key name
  vpc_security_group_ids = [
    "${aws_security_group.staging-ec2-sg.id}"
  ]
  associate_public_ip_address = "true"

  root_block_device {
    volume_type = "gp2"
    volume_size = "30"
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "100"
  }

  tags = {
    Env = "staging"
  }
}

resource "aws_eip" "staging-eip" {
  instance = "${aws_instance.staging-ec2.id}"
  vpc = true
}

