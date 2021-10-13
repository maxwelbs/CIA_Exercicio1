data "aws_ami" "slacko-app" {
    most_recent = true
    owners = ["amazon"]
 
    filter {
        name = "name"
        values = ["Amazon*"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

}

data "aws_subnet" "subnet_public" {
   cidr_block = var.subnet_cidr
}

resource "aws_key_pair" "slacko-sshkey" {
    key_name = format("%s-app-key", var.app_name)
    public_key = var.ssh_key
  
}

#EC2 Slacko APP
resource "aws_instance" "slacko-app" {
    ami = data.aws_ami.slacko-app.id
    instance_type = var.tipo_instancia_slack
    subnet_id = data.aws_subnet.subnet_public.id
    associate_public_ip_address = true

  tags = merge(var.app_tags,
            {
            "Name" = format("%s-app", var.app_name)
            },)

  key_name = aws_key_pair.slacko-sshkey.id
  user_data = file("${path.module}/files/ec2.sh")
}


# EC2 do MongoDB
resource "aws_instance" "mongodb" {
    ami = data.aws_ami.slacko-app.id
    instance_type = var.tipo_instancia_mongodb
    subnet_id = data.aws_subnet.subnet_public.id

  tags = merge(var.app_tags,{
      "Name" = format("%s-mongodb", var.app_name)
    },)
    
    key_name = aws_key_pair.slacko-sshkey.id
    user_data = file("${path.module}/files/mongodb.sh")
}


# SG do Slacko APP
resource "aws_security_group" "allow-slacko" {
    name = format("%s-sg-app-ssh-http", var.app_name)
    description = "Allow ssh and http port"
    vpc_id = var.vpc_id  

tags = merge(var.app_tags,{
        "Name" = format("%s-sg-app", var.app_name)
    })

    ingress =[
    {
        description = "Allow SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        self = null
        prefix_list_ids = [] 
        security_groups = []
    },
    {
        description = "Allow Http"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        self = null
        prefix_list_ids = [] 
        security_groups = []
    }
]

    egress = [
    {
        description = "Allow all"
        from_port = 0
        to_port = 0
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        self = null
        prefix_list_ids = [] 
        security_groups = []
    }
]

 
}

# SG do MongoDB
resource "aws_security_group" "allow-mongodb" {
    name = format("%s-sg-db-mongodb", var.app_name)
    description = "Allow MongoDB"
    vpc_id = var.vpc_id


    tags = merge(var.app_tags,{
        "Name" = format("%s-sg-db", var.app_name)
    })


    ingress = [
    {
        description = "Allow MongoDB"
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        self = null
        prefix_list_ids = [] 
        security_groups = []
    }
]
    egress = [
    {
        description = "Allow all"
        from_port = 0
        to_port = 0
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        self = null
        prefix_list_ids = [] 
        security_groups = []
    }
]

}

resource "aws_network_interface_sg_attachment" "mongodb-sg" {
   security_group_id = aws_security_group.allow-mongodb.id
   network_interface_id = aws_instance.mongodb.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "slacko-sg" {
   security_group_id = aws_security_group.allow-slacko.id
   network_interface_id = aws_instance.slacko-app.primary_network_interface_id
}

resource "aws_route53_zone" "slack_zone" {
  name = "iaac0506.com.br"
  vpc {
    vpc_id = var.vpc_id
  }
  tags = var.app_tags
}

resource "aws_route53_record" "mongodb" {
    zone_id = aws_route53_zone.slack_zone.id
    name = "mongodb.iaac0506.com.br"
    type = "A"
    ttl = "300"
    records = [aws_instance.mongodb.private_ip]
}
