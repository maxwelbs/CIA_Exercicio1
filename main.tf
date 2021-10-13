module "slackapp" {
  source      = "./modules/slacko-app"
  vpc_id      = "vpc-0eb594e2572bbbda5"
  subnet_cidr = "10.0.102.0/24"

    # Gerar SSH Key Publica -
    # cd ./modules/slacko-app/files/
    # ssh-keygen -C slacko-app -f slacko-app
    # cat ./modules/slacko-app/files/slacko-app.pub
  ssh_key = "sh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHMSpkLsSgKnd4GlPiIR27+5C2VtgwEbygyrnRXinZLxEvpreaw/xGMLLqODZb3ffZaTki2QsYlnONrlIJAbxTu9Hnx86e6dqCmsbSYqKuspJZj08d7HSCmZckVjM8xbp7kXlrBdN/GrdFmvXL3WpS9w22gf3sPKE8FqbqKusPLle04VErzI70fRzitVPpYAZIS/FB782xPgQFkfW2ajPnNYER4fe27Jcs9jCa+1/P+g+1UKwXxtS93KKnYAAy5SJbIh5q9yFh1JIWput2D9y7NHMLgPbacTbF5rJ0/N+9Ys/8yVugjHA1mr/XNr19RTrTiwU2p+yffiQ0WVStqEsV rsa-key-20211013"

  # Sufixo - Slackoapp machine name
  app_name = "MyAPPp"


  tipo_instancia_slack   = "t2.micro"
  tipo_instancia_mongodb = "t2.small"


  # Tags ára os recuros
  app_tags ={
  ambiente = "TIPO DO AMBIENTE"  #PROD, HOMOL, DEV
  owner = "DONO DO PROJETO"  #PROJETO XPTO
  }

}

output "slackip" {
  value = module.slackapp.slacko-app
}



 