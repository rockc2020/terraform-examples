module "subnets" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = var.cidr
  networks = [
    {
      name     = "private_1"
      new_bits = 2
    },
    {
      name     = "private_2"
      new_bits = 2
    },
    {
      name     = "private_3"
      new_bits = 2
    },
    {
      name     = "public_1"
      new_bits = 5
    },
    {
      name     = "public_2"
      new_bits = 5
    },
    {
      name     = "public_3"
      new_bits = 5
    }
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = var.name
  cidr = var.cidr
  azs  = data.aws_availability_zones.available.names

  private_subnets      = [for k, v in module.subnets.network_cidr_blocks : v if length(regexall("^private_\\d", k)) > 0]
  public_subnets       = [for k, v in module.subnets.network_cidr_blocks : v if length(regexall("^public_\\d", k)) > 0]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/elb"            = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"   = 1
  }
}
