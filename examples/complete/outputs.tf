output "vpc_id" {
  value       = module.complete.vpc_id
  description = "The ID of the VPC."
}

output "vswitch_ids" {
  value       = module.complete.vswitch_ids
  description = "The IDs of the VSwitches."

}

output "alb_load_balancer_id" {
  value       = module.complete.alb_load_balancer_id
  description = "The ID of the ALB Load Balancer."
}

output "alb_server_group_id" {
  value       = module.complete.alb_server_group_id
  description = "The ID of the ALB Server Group."
}


output "alb_listener" {
  value       = module.complete.alb_listener
  description = "The ID of the ALB Listener."

}

output "ecr_id" {
  value       = module.complete.ecr_id
  description = "The id of Express Connect Router."

}

output "ecr_vpc_association_id" {
  value       = module.complete.ecr_vpc_association_id
  description = "The association ID of Express Connect Router and VPC."

}
output "vbr_id" {
  value       = module.complete.vbr_id
  description = "The id of VBR."
}


output "bgp_group_id" {
  value       = module.complete.bgp_group_id
  description = "The id of BGP group."
}


output "bgp_peer_id" {
  value       = module.complete.bgp_peer_id
  description = "The id of BGP peer."
}
