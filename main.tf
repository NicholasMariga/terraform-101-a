//Creating a VPC

resource "aws_vpc" "slim_vpc" {
  cidr_block           = "10.176.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

// creating a subnet

resource "aws_subnet" "slim_public_subnet" {
  vpc_id                  = aws_vpc.slim_vpc.id
  cidr_block              = "10.176.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "dev-public"
  }
}

//creating an Internet Gateway

resource "aws_internet_gateway" "slim_internet_gateway" {
  vpc_id = aws_vpc.slim_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

//creating a route table

resource "aws_route_table" "slim_public_route_table" {
  vpc_id = aws_vpc.slim_vpc.id

  tags = {
    Name = "dev-public_route_table"
  }

}

//create a route

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.slim_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.slim_internet_gateway.id

}

// association between subnet and route table
resource "aws_route_table_association" "slim_route_table_association" {
  subnet_id      = aws_subnet.slim_public_subnet.id
  route_table_id = aws_route_table.slim_public_route_table.id
}

//creating a security group 

resource "aws_security_group" "slim_security_group" {
  name        = "dev-sg"
  description = "Dev security group"
  vpc_id      = aws_vpc.slim_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

// adding key pairs 

resource "aws_key_pair" "slim_auth" {
  key_name   = "slimkey"
  public_key = file("~/.ssh/slimkey.pub")
}

//adding an instance 

resource "aws_instance" "dev-node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server-ami.id
  key_name               = aws_key_pair.slim_auth.id
  vpc_security_group_ids = [aws_security_group.slim_security_group.id]
  subnet_id              = aws_subnet.slim_public_subnet.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }
  tags = {
    Name = "dev-node"
  }



  provisioner "local-exec" {
    //command = templatefile("windows-ssh-config.tpl", {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/slimkey"
    })
    //interpreter = ["Powershell", "-command"]
    //linux
    //interpreter=["bash","-c"]
    interpreter = var.host_os == "windows" ? ["Powershell", "-command"] : ["bash", "-c"]

  }
}
