
# Complete

Configuration in this directory create VPC, vSwitchs, ECR, VBR and ALB resources.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_complete"></a> [complete](#module\_complete) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [alicloud_express_connect_physical_connections.example](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/data-sources/express_connect_physical_connections) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_server_group"></a> [alb\_server\_group](#input\_alb\_server\_group) | The parameters of alb server group. | <pre>object({<br>    server_group_name = string<br>    scheduler         = optional(string, "Wrr")<br>    protocol          = optional(string, "HTTP")<br>    sticky_session_config = optional(object({<br>      sticky_session_enabled = optional(bool, true)<br>      cookie                 = optional(string, "tf-example")<br>      sticky_session_type    = optional(string, "Server")<br>    }), {})<br>    health_check_config = optional(object({<br>      health_check_enabled      = optional(bool, true)<br>      health_check_connect_port = optional(number, 46325)<br>      health_check_host         = optional(string, "tf-example.com")<br>      health_check_codes        = optional(list(string), ["http_2xx", "http_3xx", "http_4xx"])<br>      health_check_http_version = optional(string, "HTTP1.1")<br>      health_check_interval     = optional(number, 2)<br>      health_check_method       = optional(string, "HEAD")<br>      health_check_path         = optional(string, "/tf-example")<br>      health_check_protocol     = optional(string, "HTTP")<br>      health_check_timeout      = optional(number, 5)<br>      healthy_threshold         = optional(number, 3)<br>      unhealthy_threshold       = optional(number, 3)<br>    }), {})<br>    servers = optional(list(object({<br>      server_type       = string<br>      server_id         = string<br>      server_ip         = optional(string, null)<br>      weight            = optional(number, null)<br>      port              = optional(number, null)<br>      remote_ip_enabled = optional(bool, null)<br>    })), [])<br>  })</pre> | <pre>{<br>  "server_group_name": "idc",<br>  "servers": [<br>    {<br>      "port": 80,<br>      "remote_ip_enabled": true,<br>      "server_id": "172.16.1.5",<br>      "server_ip": "172.16.1.5",<br>      "server_type": "Ip",<br>      "weight": 10<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_ecr_alibaba_side_asn"></a> [ecr\_alibaba\_side\_asn](#input\_ecr\_alibaba\_side\_asn) | The alibaba side asn for ECR. | `number` | `64512` | no |
| <a name="input_region"></a> [region](#input\_region) | The region ID which is used in internal parameter | `string` | `"cn-hangzhou"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags of resources. | `map(string)` | <pre>{<br>  "Created": "Terraform"<br>}</pre> | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | The parameters of vpc. The attribute 'cidr\_block' is required. | <pre>object({<br>    cidr_block  = string<br>    vpc_name    = optional(string, null)<br>    enable_ipv6 = optional(bool, null)<br>  })</pre> | <pre>{<br>  "cidr_block": "10.0.0.0/16"<br>}</pre> | no |
| <a name="input_vswitches"></a> [vswitches](#input\_vswitches) | The parameters of vswitches. The attributes 'zone\_id', 'cidr\_block' are required. | <pre>list(object({<br>    zone_id      = string<br>    cidr_block   = string<br>    vswitch_name = optional(string, null)<br>  }))</pre> | <pre>[<br>  {<br>    "cidr_block": "10.0.1.0/24",<br>    "zone_id": "cn-hangzhou-i"<br>  },<br>  {<br>    "cidr_block": "10.0.2.0/24",<br>    "zone_id": "cn-hangzhou-j"<br>  }<br>]</pre> | no |

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