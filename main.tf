module "tags" {
  source          = "./modules/tags"
  application     = "flights-stackoverflow-answers"
  project         = "learn-aws-2"
  team            = "infrastructure"
  environment     = "dev"
  owner           = "giraffeman123"
  project_version = "1.0"
  contact         = "giraffeman123@gmail.com"
  cost_center     = "35009"
  sensitive       = false
}

module "vpc" {
  source = "./modules/imported-vpc"
  vpc_id = var.vpc_id
}

module "ecs_cluster" {
  source         = "./modules/ecs-cluster"
  mandatory_tags = module.tags.mandatory_tags
  cluster_name   = "flights-and-answers"
}

module "fsa_api_ecs_service" {
  source           = "./modules/fsa-api-ecs-service"
  mandatory_tags   = module.tags.mandatory_tags
  name             = "fsa-api"
  docker_image_url = var.fsa_api_docker_image_url
  app_port         = 3000
  ecs_cluster_id   = module.ecs_cluster.cluster_id

  # db_host             = module.rds.db_host
  db_host = "mydb"

  db_name             = var.db_name
  db_admin_user       = var.db_admin_user
  db_pwd              = var.db_pwd
  answer_endpoint     = "https://api.stackexchange.com/2.2/search?order=desc&sort=activity&intitle=perl&site=stackoverflow"
  vpc_id              = module.vpc.vpc_id
  private_subnets_ids = module.vpc.private_subnets_ids
  public_subnets_ids  = module.vpc.public_subnets_ids
  health_check_path   = "/liveness"

  # web_app_sg_id       = module.webapp.ec2s_sg
  web_app_sg_id = "sg_id"
}

