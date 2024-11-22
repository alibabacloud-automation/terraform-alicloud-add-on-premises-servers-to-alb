Terraform module to add on-premises servers to ALB for Alibaba Cloud

terraform-alicloud-add-on-premises-servers-to-alb
======================================

English | [简体中文](https://github.com/alibabacloud-automation/terraform-alicloud-add-on-premises-servers-to-alb/blob/main/README-CN.md)

This Module designs a cloud-based delivery network for IDC seven-layer applications, including:
1. Building a high-availability dedicated network between the cloud and IDC through ECR （Express Connect Router）
2. Enabling the migration of seven-layer public network entry points of IDC servers to the cloud through ALB (Network Load Balancer).

Architecture Diagram:

<img src="https://raw.githubusercontent.com/alibabacloud-automation/terraform-alicloud-add-on-premises-servers-to-alb/main/scripts/diagram.png" alt="Architecture Diagram" width="300" height="500">


## Usage

```hcl
provider "alicloud" {
  region = "cn-hangzhou"
}

data "alicloud_express_connect_physical_connections" "example" {
  name_regex = "^preserved-NODELETING"
}

module "complete" {
  source = "alibabacloud-automation/add-on-premises-servers-to-alb/alicloud"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
  }
  vswitches  = [{
    zone_id    = "cn-hangzhou-i"
    cidr_block = "10.0.1.0/24"
    }, {
    zone_id    = "cn-hangzhou-j"
    cidr_block = "10.0.2.0/24"
  }]

  alb_server_group = {
    server_group_name = "idc"
    servers = [{
      server_type       = "Ip"
      server_id         = "172.16.1.5"
      server_ip         = "172.16.1.5"
      weight            = 10
      port              = 80
      remote_ip_enabled = true
    }]
  }

  ecr_alibaba_side_asn = 64512

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

  tags = {
    "Created" = "Terraform"
  }
}
```

## Examples

* [Complete Example](https://github.com/alibabacloud-automation/terraform-alicloud-add-on-premises-servers-to-alb/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alicloud_alb_listener.this](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/alb_listener) | resource |
| [alicloud_alb_load_balancer.this](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/alb_load_balancer) | resource |
| [alicloud_alb_server_group.this](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/alb_server_group) | resource |
| [alicloud_express_connect_router_express_connect_router.this](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/express_connect_router_express_connect_router) | resource |
| [alicloud_express_connect_router_vbr_child_instance.this](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/express_connect_router_vbr_child_instance) | resource |
| [alicloud_express_connect_router_vpc_association.this](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/express_connect_router_vpc_association) | resource |
| [alicloud_express_connect_virtual_border_router.this](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/express_connect_virtual_border_router) | resource |
| [alicloud_vpc.this](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/vpc) | resource |
| [alicloud_vpc_bgp_group.this](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/vpc_bgp_group) | resource |
| [alicloud_vpc_bgp_peer.this](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/vpc_bgp_peer) | resource |
| [alicloud_vswitch.this](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/vswitch) | resource |
| [alicloud_regions.default](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/data-sources/regions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_listener"></a> [alb\_listener](#input\_alb\_listener) | The parameters of alb listener. | <pre>object({<br>    listener_protocol = string<br>    listener_port     = number<br>  })</pre> | <pre>{<br>  "listener_port": 80,<br>  "listener_protocol": "HTTP"<br>}</pre> | no |
| <a name="input_alb_load_balancer"></a> [alb\_load\_balancer](#input\_alb\_load\_balancer) | The parameters of alb load balancer. | <pre>object({<br>    load_balancer_edition = string<br>    pay_type              = optional(string, "PayAsYouGo")<br>    modification_protection_config = optional(object({<br>      status = optional(string, "NonProtection")<br>      reason = optional(string, null)<br>    }), {})<br>  })</pre> | <pre>{<br>  "load_balancer_edition": "Standard"<br>}</pre> | no |
| <a name="input_alb_server_group"></a> [alb\_server\_group](#input\_alb\_server\_group) | The parameters of alb server group. | <pre>object({<br>    server_group_name = string<br>    scheduler         = optional(string, "Wrr")<br>    protocol          = optional(string, "HTTP")<br>    sticky_session_config = optional(object({<br>      sticky_session_enabled = optional(bool, true)<br>      cookie                 = optional(string, "tf-example")<br>      sticky_session_type    = optional(string, "Server")<br>    }), {})<br>    health_check_config = optional(object({<br>      health_check_enabled      = optional(bool, true)<br>      health_check_connect_port = optional(number, 46325)<br>      health_check_host         = optional(string, "tf-example.com")<br>      health_check_codes        = optional(list(string), ["http_2xx", "http_3xx", "http_4xx"])<br>      health_check_http_version = optional(string, "HTTP1.1")<br>      health_check_interval     = optional(number, 2)<br>      health_check_method       = optional(string, "HEAD")<br>      health_check_path         = optional(string, "/tf-example")<br>      health_check_protocol     = optional(string, "HTTP")<br>      health_check_timeout      = optional(number, 5)<br>      healthy_threshold         = optional(number, 3)<br>      unhealthy_threshold       = optional(number, 3)<br>    }), {})<br>    servers = optional(list(object({<br>      server_type       = string<br>      server_id         = string<br>      server_ip         = optional(string, null)<br>      weight            = optional(number, null)<br>      port              = optional(number, null)<br>      remote_ip_enabled = optional(bool, null)<br>    })), [])<br>  })</pre> | <pre>{<br>  "server_group_name": "idc_server_group"<br>}</pre> | no |
| <a name="input_ecr_alibaba_side_asn"></a> [ecr\_alibaba\_side\_asn](#input\_ecr\_alibaba\_side\_asn) | The alibaba side asn for ECR. | `number` | `null` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group id. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags of resources. | `map(string)` | `{}` | no |
| <a name="input_vbr_bgp_group"></a> [vbr\_bgp\_group](#input\_vbr\_bgp\_group) | The parameters of the bgp group. The attribute 'peer\_asn' is required. | <pre>object({<br>    peer_asn       = string<br>    auth_key       = optional(string, null)<br>    bgp_group_name = optional(string, null)<br>    description    = optional(string, null)<br>    is_fake_asn    = optional(bool, false)<br>  })</pre> | <pre>{<br>  "peer_asn": null<br>}</pre> | no |
| <a name="input_vbr_bgp_peer"></a> [vbr\_bgp\_peer](#input\_vbr\_bgp\_peer) | The parameters of the bgp peer. The default value of 'bfd\_multi\_hop' is 255. The default value of 'enable\_bfd' is 'false'. The default value of 'ip\_version' is 'IPV4'. | <pre>object({<br>    bfd_multi_hop   = optional(number, 10)<br>    enable_bfd      = optional(bool, "true")<br>    ip_version      = optional(string, "IPV4")<br>    peer_ip_address = optional(string, null)<br>  })</pre> | `{}` | no |
| <a name="input_vbr_config"></a> [vbr\_config](#input\_vbr\_config) | The list parameters of VBR. The attributes 'physical\_connection\_id', 'vlan\_id', 'local\_gateway\_ip','peer\_gateway\_ip','peering\_subnet\_mask' are required. | <pre>list(object({<br>    physical_connection_id     = string<br>    vlan_id                    = number<br>    local_gateway_ip           = string<br>    peer_gateway_ip            = string<br>    peering_subnet_mask        = string<br>    virtual_border_router_name = optional(string, null)<br>    description                = optional(string, null)<br>  }))</pre> | <pre>[<br>  {<br>    "local_gateway_ip": null,<br>    "peer_gateway_ip": null,<br>    "peering_subnet_mask": null,<br>    "physical_connection_id": null,<br>    "vlan_id": null<br>  },<br>  {<br>    "local_gateway_ip": null,<br>    "peer_gateway_ip": null,<br>    "peering_subnet_mask": null,<br>    "physical_connection_id": null,<br>    "vlan_id": null<br>  }<br>]</pre> | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | The parameters of vpc. The attribute 'cidr\_block' is required. | <pre>object({<br>    cidr_block  = string<br>    vpc_name    = optional(string, null)<br>    enable_ipv6 = optional(bool, null)<br>  })</pre> | <pre>{<br>  "cidr_block": null<br>}</pre> | no |
| <a name="input_vswitches"></a> [vswitches](#input\_vswitches) | The parameters of vswitches. The attributes 'zone\_id', 'cidr\_block' are required. | <pre>list(object({<br>    zone_id      = string<br>    cidr_block   = string<br>    vswitch_name = optional(string, null)<br>  }))</pre> | <pre>[<br>  {<br>    "cidr_block": null,<br>    "zone_id": null<br>  },<br>  {<br>    "cidr_block": null,<br>    "zone_id": null<br>  }<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_listener"></a> [alb\_listener](#output\_alb\_listener) | The ID of the ALB Listener. |
| <a name="output_alb_load_balancer_id"></a> [alb\_load\_balancer\_id](#output\_alb\_load\_balancer\_id) | The ID of the ALB Load Balancer. |
| <a name="output_alb_server_group_id"></a> [alb\_server\_group\_id](#output\_alb\_server\_group\_id) | The ID of the ALB Server Group. |
| <a name="output_bgp_group_id"></a> [bgp\_group\_id](#output\_bgp\_group\_id) | The id of BGP group. |
| <a name="output_bgp_peer_id"></a> [bgp\_peer\_id](#output\_bgp\_peer\_id) | The id of BGP peer. |
| <a name="output_ecr_id"></a> [ecr\_id](#output\_ecr\_id) | The id of Express Connect Router. |
| <a name="output_ecr_vpc_association_id"></a> [ecr\_vpc\_association\_id](#output\_ecr\_vpc\_association\_id) | The association ID of Express Connect Router and VPC. |
| <a name="output_vbr_id"></a> [vbr\_id](#output\_vbr\_id) | The id of VBR. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC. |
| <a name="output_vswitch_ids"></a> [vswitch\_ids](#output\_vswitch\_ids) | The IDs of the VSwitches. |
<!-- END_TF_DOCS -->

## Submit Issues

If you have any problems when using this module, please opening
a [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) and let us know.

**Note:** There does not recommend opening an issue on this repo.

## Authors

Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com).

## License

MIT Licensed. See LICENSE for full details.

## Reference

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)
