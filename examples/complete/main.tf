provider "alicloud" {
  region = var.region
}

data "alicloud_express_connect_physical_connections" "example" {
  name_regex = "^preserved-NODELETING"
}

module "complete" {
  source = "../.."

  vpc_config = var.vpc_config
  vswitches  = var.vswitches

  alb_server_group = var.alb_server_group

  ecr_alibaba_side_asn = var.ecr_alibaba_side_asn

  vbr_config = [
    {
      physical_connection_id = data.alicloud_express_connect_physical_connections.example.connections[0].id
      vlan_id                = 104
      local_gateway_ip       = "192.168.0.1"
      peer_gateway_ip        = "192.168.0.2"
      peering_subnet_mask    = "255.255.255.252"
    },
    {
      physical_connection_id = data.alicloud_express_connect_physical_connections.example.connections[1].id
      vlan_id                = 105
      local_gateway_ip       = "192.168.1.1"
      peer_gateway_ip        = "192.168.1.2"
      peering_subnet_mask    = "255.255.255.252"
    }
  ]

  vbr_bgp_group = {
    peer_asn = 45000
  }

  tags = var.tags
}
