resource "aws_vpc" "default" {
	cidr_block = "${var.vpc_cidr}"
	enable_dns_hostnames = true

	tags = {
		Name = "Linuxer-DEV-VPC"
	}
}
resource "aws_subnet" "pub-common" {
        count = "${length(var.availability_zone)}"
        vpc_id = "${aws_vpc.default.id}"
        cidr_block = [
                for num in var.subnet_numbers:
                cidrsubnet(aws_vpc.default.cidr_block, 8, num)
                ][count.index]
        availability_zone = "${element(var.availability_zone, count.index)}"
        tags = {
                Name = "Linuxer-Dev-Pub-Common-${element(var.az_count, count.index)}"
        }
}
resource "aws_subnet" "pub-elb" {
        count = "${length(var.availability_zone)}"
        vpc_id = "${aws_vpc.default.id}"
        cidr_block = [
                for num in var.subnet_numbers:
                cidrsubnet(aws_vpc.default.cidr_block, 8, num+1)
                ][count.index]
        availability_zone = "${element(var.availability_zone, count.index)}"
        tags = {
                Name = "Linuxer-Dev-Pub-ELB-${element(var.az_count, count.index)}"
        }
}
resource "aws_internet_gateway" "gw" {
	vpc_id = "${aws_vpc.default.id}"

	tags = {
		Name = "VPC-Dev-IGW"
	}
}
resource "aws_route_table" "pub" {
	vpc_id = "${aws_vpc.default.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.gw.id}"
	}

	tags = {
		Name = "Linuxer-Pub-Route-Table"
	}
}
resource "aws_route_table_association" "pub-common" {
        count = "${length(var.subnet_numbers)}"
        subnet_id = "${element(aws_subnet.pub-common.*.id, count.index)}"
        route_table_id = "${aws_route_table.pub.id}"
}
resource "aws_route_table_association" "pub-elb" {
        count = "${length(var.subnet_numbers)}"
        subnet_id = "${element(aws_subnet.pub-elb.*.id, count.index)}"
        route_table_id = "${aws_route_table.pub.id}"
}
