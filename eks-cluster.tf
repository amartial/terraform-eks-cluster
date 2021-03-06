module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.18"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = "training"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  node_groups = [
    {
      name                          = "node-group-1"
      instance_types                = ["t2.small"]
      additional_userdata           = "echo foo bar"
      scaling_config = {
        desired_size = 2
        max_size     = 2
        min_size     = 2
      }
      additional_security_group_ids = [aws_security_group.node_group_mgmt_two.id]
    },
    {
      name                          = "node-group-2"
      instance_types                = ["t2.medium"]
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.node_group_mgmt_one.id]
      scaling_config = {
        desired_size = 1
        max_size     = 1
        min_size     = 1
      }
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
