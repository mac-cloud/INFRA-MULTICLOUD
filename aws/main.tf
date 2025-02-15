resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "${var.cluster_name}-vpc"
    }
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.vpc_id

    tags = {
        Name = "${var.cluster_name}-igw"
    }
}

resource "aws_subnet" "private" {
    count = length(var.private_subnets)
    vpc_id = aws_vpc.this.id
    cidr_block = var.private_subnets[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name = "$(var.cluster_name)-private-${count.index}"
    }
}

resource "aws_subnet" "public" {
    count = length(var.public_subnets)
    vpc_id = aws_vpc.this.id
    cidr_block = var.public_subnets[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name = "$(var.cluster_name)-public-${count.index}"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id 

    tags = {
        Name = "${var.cluster_name}-public-rt"
    }
}

resource "aws_route_table_association" "public_association" {
    count = length(var.public_subnets)
    route_table_id = aws_route_table.public.id
    subnet_id = aws_subnet.public[count.index].id 
}

resource "aws_route" "public_internet_access" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id 
}

resource "aws_eks_cluster" "this" {
    name = var.cluster_name
    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config {
        subnet_ids =concat(
            aws_subnet.private[*].id,
            aws_subnet.public[*].id
        )
    }
    depends_on = [
        aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
        aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy
    ]
    tags = {
        Name = var.cluster_name
    }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
    role = aws_iam_role.eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role" "eks_node_group_role" {
    name = "${var.cluster_name}-nodegroup-role"
    assume_role_policy = <<EOF
    {
    "version": ""
    "Statement": [
    {
        "Action": "sts:Assumble",
        "Pricipal": {
            "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
    }
    
    ]
    }
  EOF
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKSWorkerNodePolicy" {
    role = aws_iam_role.eks_node_group_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKS_CNI_Policy" {
    role = aws_iam_role.eks_node_group_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEC2ContainerRegistryReadOnly" {
    role = aws_iam_role.eks_node_group_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "aws_eks_node_group" "main" {
    cluster_name = aws_eks_cluster.this.name
    node_role_arn = aws_iam_role.eks_node_group_role.arn
    subnet_ids = aws_subnet.private[*].id 

    scaling_config {
        desired_size = var.node_group_desired_size
        max_size = var.node_group_desired_size + 2
        min_size = var.node_group_desired_size
    }
    instance_types = [var.node_group_instance_type]
    depends_on = [aws_eks_cluster.this]

    tags = {
        Name = "${var.cluster_name}-node-group"
    }
}

output "cluster_name" {
   value = aws_eks_cluster.this.name   
}
output "cluster_endpoint" {
    value = aws_eks_cluster.this.endpoint 
  
}
output "cluster_certificate_authority_data" {
    value = aws_eks_cluster.this.certificate_authority[0].data
}