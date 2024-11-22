variable "region" {
  default     = "cn-hangzhou"
  type        = string
  description = "The region ID which is used in internal parameter"
}

# VPC & vSwitchs
variable "vpc_config" {
  description = "The parameters of vpc. The attribute 'cidr_block' is required."
  type = object({
    cidr_block  = string
    vpc_name    = optional(string, null)
    enable_ipv6 = optional(bool, null)
  })
  default = {
    cidr_block = "10.0.0.0/16"
  }
}

variable "vswitches" {
  description = "The parameters of vswitches. The attributes 'zone_id', 'cidr_block' are required."
  type = list(object({
    zone_id      = string
    cidr_block   = string
    vswitch_name = optional(string, null)
  }))
  default = [{
    zone_id    = "cn-hangzhou-i"
    cidr_block = "10.0.1.0/24"
    }, {
    zone_id    = "cn-hangzhou-j"
    cidr_block = "10.0.2.0/24"
  }]

  validation {
    condition     = length(var.vswitches) >= 2
    error_message = "At least two vswitchs must be configured."
  }
}

variable "alb_server_group" {
  description = "The parameters of alb server group."
  type = object({
    server_group_name = string
    scheduler         = optional(string, "Wrr")
    protocol          = optional(string, "HTTP")
    sticky_session_config = optional(object({
      sticky_session_enabled = optional(bool, true)
      cookie                 = optional(string, "tf-example")
      sticky_session_type    = optional(string, "Server")
    }), {})
    health_check_config = optional(object({
      health_check_enabled      = optional(bool, true)
      health_check_connect_port = optional(number, 46325)
      health_check_host         = optional(string, "tf-example.com")
      health_check_codes        = optional(list(string), ["http_2xx", "http_3xx", "http_4xx"])
      health_check_http_version = optional(string, "HTTP1.1")
      health_check_interval     = optional(number, 2)
      health_check_method       = optional(string, "HEAD")
      health_check_path         = optional(string, "/tf-example")
      health_check_protocol     = optional(string, "HTTP")
      health_check_timeout      = optional(number, 5)
      healthy_threshold         = optional(number, 3)
      unhealthy_threshold       = optional(number, 3)
    }), {})
    servers = optional(list(object({
      server_type       = string
      server_id         = string
      server_ip         = optional(string, null)
      weight            = optional(number, null)
      port              = optional(number, null)
      remote_ip_enabled = optional(bool, null)
    })), [])
  })
  default = {
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
}



# ECR
variable "ecr_alibaba_side_asn" {
  description = "The alibaba side asn for ECR."
  type        = number
  default     = 64512
}


variable "tags" {
  description = "The tags of resources."
  type        = map(string)
  default = {
    "Created" = "Terraform"
  }
}




