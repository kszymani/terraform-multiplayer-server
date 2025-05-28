resource "aws_vpc" "project_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.platform_name}-vpc"
  }
}

resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.project_vpc.id 

  tags = {
    Name = "${var.platform_name}-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.project_vpc.id 

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id        
  destination_cidr_block = "0.0.0.0/0"                         
  gateway_id             = aws_internet_gateway.example_igw.id 

}

resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zones[1]
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.platform_name}-ec2-sg"
  description = "${var.platform_name} security group"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    description = "Krzysztof"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }
  
  # TODO add here other IPs

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
