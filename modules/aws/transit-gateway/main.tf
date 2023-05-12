locals {
  gateway_routes = merge([for k, v in var.vpc_attachments : {
    for rtid in v.route_table_ids : "${k}-${rtid}" => {
      cidr           = v.destination_cidr
      route_table_id = rtid
    }
  }]...)
}

################################################################################
# Transit Gateway
################################################################################
resource "aws_ec2_transit_gateway" "main" {
  description                    = var.description
  auto_accept_shared_attachments = "enable"

  tags = {
    Name = var.name
  }
}

################################################################################
# Transit Gateway VPC Attachments
################################################################################
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  for_each = var.vpc_attachments

  subnet_ids         = each.value.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = each.value.vpc_id
  dns_support        = "enable"

  tags = {
    Name = "${var.name}-${each.key}"
  }
}

################################################################################
# VPC Routes
################################################################################
resource "aws_route" "vpc_to_tgw" {
  for_each = local.gateway_routes

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}
