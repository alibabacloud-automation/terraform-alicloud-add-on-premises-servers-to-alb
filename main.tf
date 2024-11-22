
locals {
  vswitches  = { for vswitch in var.vswitches : vswitch.cidr_block => vswitch }
  vbr_config = { for index, vbr in var.vbr_config : index => vbr }
}

# VPC & vSwitchs
resource "alicloud_vpc" "this" {
  vpc_name    = var.vpc_config.vpc_name
  cidr_block  = var.vpc_config.cidr_block
  enable_ipv6 = var.vpc_config.enable_ipv6

  resource_group_id = var.resource_group_id
  tags              = var.tags
}


resource "alicloud_vswitch" "this" {
  for_each = local.vswitches

  vpc_id       = alicloud_vpc.this.id
  cidr_block   = each.value.cidr_block
  zone_id      = each.value.zone_id
  vswitch_name = each.value.vswitch_name

  tags = var.tags
}

# ALB
resource "alicloud_alb_load_balancer" "this" {
  address_type           = "Internet"
  address_allocated_mode = "Fixed"
  vpc_id                 = alicloud_vpc.this.id
  load_balancer_edition  = var.alb_load_balancer.load_balancer_edition

  load_balancer_billing_config {
    pay_type = var.alb_load_balancer.pay_type
  }

  dynamic "modification_protection_config" {
    for_each = [var.alb_load_balancer.modification_protection_config]
    content {
      status = modification_protection_config.value.status
      reason = modification_protection_config.value.reason
    }
  }

  dynamic "zone_mappings" {
    for_each = alicloud_vswitch.this
    content {
      vswitch_id = zone_mappings.value.id
      zone_id    = zone_mappings.value.zone_id
    }
  }

  resource_group_id = var.resource_group_id
  tags              = var.tags
}

resource "alicloud_alb_server_group" "this" {
  server_group_type = "Ip"
  vpc_id            = alicloud_vpc.this.id
  server_group_name = var.alb_server_group.server_group_name
  scheduler         = var.alb_server_group.scheduler
  protocol          = var.alb_server_group.protocol

  dynamic "sticky_session_config" {
    for_each = [var.alb_server_group.sticky_session_config]
    content {
      sticky_session_enabled = sticky_session_config.value.sticky_session_enabled
      cookie                 = sticky_session_config.value.cookie
      sticky_session_type    = sticky_session_config.value.sticky_session_type
    }
  }

  health_check_config {
    health_check_connect_port = var.alb_server_group.health_check_config.health_check_connect_port
    health_check_enabled      = var.alb_server_group.health_check_config.health_check_enabled
    health_check_host         = var.alb_server_group.health_check_config.health_check_host
    health_check_codes        = var.alb_server_group.health_check_config.health_check_codes
    health_check_http_version = var.alb_server_group.health_check_config.health_check_http_version
    health_check_interval     = var.alb_server_group.health_check_config.health_check_interval
    health_check_method       = var.alb_server_group.health_check_config.health_check_method
    health_check_path         = var.alb_server_group.health_check_config.health_check_path
    health_check_protocol     = var.alb_server_group.health_check_config.health_check_protocol
    health_check_timeout      = var.alb_server_group.health_check_config.health_check_timeout
    healthy_threshold         = var.alb_server_group.health_check_config.healthy_threshold
    unhealthy_threshold       = var.alb_server_group.health_check_config.unhealthy_threshold
  }

  dynamic "servers" {
    for_each = var.alb_server_group.servers
    content {
      server_type       = servers.value.server_type
      server_id         = servers.value.server_id
      server_ip         = servers.value.server_ip
      weight            = servers.value.weight
      port              = servers.value.port
      remote_ip_enabled = servers.value.remote_ip_enabled
    }
  }

  resource_group_id = var.resource_group_id
  tags              = var.tags
}

resource "alicloud_alb_listener" "this" {
  listener_protocol = var.alb_listener.listener_protocol
  listener_port     = var.alb_listener.listener_port
  load_balancer_id  = alicloud_alb_load_balancer.this.id
  default_actions {
    type = "ForwardGroup"
    forward_group_config {
      server_group_tuples {
        server_group_id = alicloud_alb_server_group.this.id
      }
    }
  }

  tags = var.tags
}


# ECR
resource "alicloud_express_connect_router_express_connect_router" "this" {
  alibaba_side_asn = var.ecr_alibaba_side_asn

  resource_group_id = var.resource_group_id
  tags              = var.tags
}

data "alicloud_regions" "default" {
  current = true
}


resource "alicloud_express_connect_router_vpc_association" "this" {
  ecr_id                = alicloud_express_connect_router_express_connect_router.this.id
  association_region_id = data.alicloud_regions.default.regions[0].id
  vpc_id                = alicloud_vpc.this.id
  depends_on            = [alicloud_vswitch.this]
}


# VBR
resource "alicloud_express_connect_virtual_border_router" "this" {
  for_each = local.vbr_config

  physical_connection_id     = each.value.physical_connection_id
  vlan_id                    = each.value.vlan_id
  local_gateway_ip           = each.value.local_gateway_ip
  peer_gateway_ip            = each.value.peer_gateway_ip
  peering_subnet_mask        = each.value.peering_subnet_mask
  virtual_border_router_name = each.value.virtual_border_router_name
  description                = each.value.description
}


resource "alicloud_express_connect_router_vbr_child_instance" "this" {
  for_each = local.vbr_config

  child_instance_id        = alicloud_express_connect_virtual_border_router.this[each.key].id
  child_instance_region_id = data.alicloud_regions.default.regions[0].id
  ecr_id                   = alicloud_express_connect_router_express_connect_router.this.id
  child_instance_type      = "VBR"


}

resource "alicloud_vpc_bgp_group" "this" {
  for_each = local.vbr_config

  router_id      = alicloud_express_connect_router_vbr_child_instance.this[each.key].child_instance_id
  peer_asn       = var.vbr_bgp_group.peer_asn
  auth_key       = var.vbr_bgp_group.auth_key
  bgp_group_name = var.vbr_bgp_group.bgp_group_name
  is_fake_asn    = var.vbr_bgp_group.is_fake_asn
  description    = var.vbr_bgp_group.description
}

resource "alicloud_vpc_bgp_peer" "this" {
  for_each = local.vbr_config

  bgp_group_id    = alicloud_vpc_bgp_group.this[each.key].id
  ip_version      = "IPV4"
  bfd_multi_hop   = var.vbr_bgp_peer.bfd_multi_hop
  enable_bfd      = var.vbr_bgp_peer.enable_bfd
  peer_ip_address = var.vbr_bgp_peer.peer_ip_address
}

