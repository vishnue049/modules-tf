# Query all avilable Availibility Zone
data "aws_availability_zones" "available" {}
module "my_vpc_module" {
  source             = "./modules/network"
  environment        = var.environment

}
## Single instance module
# module "my_server_module" {
#   depends_on = [
#     module.my_vpc_module
#   ]
#   source             = "./modules/webserver"
#   environment        = var.environment
#   subnet_id          = module.my_vpc_module.public_cidrs[0]
#   security_group_ids = [module.my_vpc_module.security_group_ids]
#   availability_zones = data.aws_availability_zones.available.names[0]
# }

module "my_server_module_2" {
  depends_on = [
    module.my_vpc_module
  ]
  count = length(module.my_vpc_module.public_cidrs)
  source             = "./modules/webserver"
  environment        = var.environment
  subnet_id          = module.my_vpc_module.public_cidrs[count.index]
  security_group_ids = [module.my_vpc_module.security_group_ids]
  availability_zones = data.aws_availability_zones.available.names[count.index]
}

module "s3_module" {
  source = "./modules/storage"
}

module "flowlog_module" {
  source = "./modules/flowlogs"
  aws_s3_bucket = var.aws_s3_bucket.name
  aws_vpc = module.my_vpc_module.vpc_id
}