provider "aws" {
    region  =   "us-east-1"
    access_key  =   "AKIAUKWE3JKALNE5ZJIU"
    secret_key  =   "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"
}
variable "cidr_vpc" {
  description=  "CIDR block for the VPC"
  default   =   "10.0.0.0/16"  
}

variable "cidr_subnet" {
    description =   "CIDR block for the subnet"
    default =   "10.0.1.0/24"
}

variable "availability_zone" {
    description =   "availability zone for the subnet"
    default =   "us-east-1f"
}

variable "instance_ami" {
    description =   "AMI for aws EC2 Instance"
    default =   "ami-0b898040803850657"
}

variable "instance_type" {
    description =   "type for aws ec2 instance"
    default =   "t2.micro"
}


resource "aws_vpc" "messi10" {
    cidr_block  =   "${var.cidr_vpc}"
    instance_tenancy    =   "default"
    enable_dns_support  =   true
    enable_dns_hostnames    =   true
    tags    =   {
        Name    =   "main"
    }
}

resource "aws_subnet" "public" {
    vpc_id  =   "${aws_vpc.messi10.id}"
    cidr_block  =   "${var.cidr_subnet}"
    map_public_ip_on_launch =   true
    availability_zone   =   "${var.availability_zone}"
}

resource "aws_subnet" "us-east-2f" {
    vpc_id  =   "${aws_vpc.messi10.id}"
    cidr_block  =   "10.0.2.0/24"
}

resource "aws_internet_gateway" "iqw" {
  vpc_id    =   "${aws_vpc.messi10.id}"
}

resource "aws_route_table" "public_table" {
    vpc_id  =   "${aws_vpc.messi10.id}"

    route{
        cidr_block  =   "0.0.0.0/0"
        gateway_id  =   "${aws_internet_gateway.iqw.id}"
    }
}

resource "aws_route_table_association" "ass_pub_sub" {
  subnet_id =   "${aws_subnet.public.id}"
  route_table_id    =   "${aws_route_table.public_table.id}"
}

resource "aws_security_group" "SecG" {
    name    =   "sg_22"
    vpc_id  =   "${aws_vpc.messi10.id}"

    ingress{
        from_port   =   22
        to_port =   22
        protocol    =   "tcp"
        cidr_blocks  =   ["0.0.0.0/0"]
    }

    egress{
        from_port   =   0
        to_port =   0
        protocol    =   "-1"
        cidr_blocks =   ["0.0.0.0/0"]
    }
}


resource "aws_instance" "TestInstance"{
    ami =   "${var.instance_ami}"
    instance_type   =   "${var.instance_type}"
    subnet_id   =   "${aws_subnet.public.id}"
    vpc_security_group_ids  =   ["${aws_security_group.SecG.id}"]
    key_name    =   "leo"
}