resource "aviatrix_edge_gateway_selfmanaged" "default" {
  for_each = var.edge_gws

  #Required values
  gw_name                = each.value.gw_name
  site_id                = var.site_id
  ztp_file_type          = var.ztp_file_type
  ztp_file_download_path = local.ztp_file_download_path

  #Interfaces
  interfaces {
    name          = "eth0"
    type          = "WAN"
    ip_address    = each.value.wan_interface_ip_prefix
    gateway_ip    = each.value.wan_default_gateway_ip
    wan_public_ip = each.value.wan_public_ip
  }

  interfaces {
    name       = "eth1"
    type       = "LAN"
    ip_address = each.value.lan_interface_ip_prefix
  }

  interfaces {
    name        = "eth2"
    type        = "MANAGEMENT"
    enable_dhcp = each.value.management_enable_dhcp
    ip_address  = each.value.management_interface_ip_prefix
    gateway_ip  = each.value.management_default_gateway_ip
  }

  #Optional
  management_egress_ip_prefix_list       = each.value.management_egress_ip_prefix_list
  enable_management_over_private_network = each.value.enable_management_over_private_network
  enable_edge_active_standby             = each.value.enable_edge_active_standby
  enable_edge_active_standby_preemptive  = each.value.enable_edge_active_standby_preemptive
  dns_server_ip                          = each.value.dns_server_ip
  secondary_dns_server_ip                = each.value.secondary_dns_server_ip

  #Advanced options
  local_as_number                  = each.value.local_as_number
  prepend_as_path                  = each.value.prepend_as_path
  enable_learned_cidrs_approval    = each.value.enable_learned_cidrs_approval
  approved_learned_cidrs           = each.value.approved_learned_cidrs
  spoke_bgp_manual_advertise_cidrs = each.value.spoke_bgp_manual_advertise_cidrs
  enable_preserve_as_path          = each.value.enable_preserve_as_path
  bgp_polling_time                 = each.value.bgp_polling_time
  bgp_hold_time                    = each.value.bgp_hold_time
  enable_edge_transitive_routing   = each.value.enable_edge_transitive_routing
  enable_jumbo_frame               = each.value.enable_jumbo_frame
  latitude                         = each.value.latitude
  longitude                        = each.value.longitude
}

resource "aviatrix_segmentation_network_domain_association" "default" {
  for_each = local.network_domain_attachments

  transit_gateway_name = each.value.transit
  network_domain_name  = var.network_domain
  attachment_name      = aviatrix_edge_gateway_selfmanaged.default[each.value.edge_gw_instance].id

  lifecycle {
    precondition {
      condition     = aviatrix_edge_gateway_selfmanaged.default[each.value.edge_gw_instance].state == "up"
      error_message = format("The edge gateway %s is not yet up. You can prevent this error by leaving it detached (do not set attached = true on each gateway) until the gateway is up.", each.value.gw_name)
    }
  }
}

resource "aviatrix_edge_spoke_transit_attachment" "default" {
  for_each = local.transit_attachments

  spoke_gw_name               = aviatrix_edge_gateway_selfmanaged.default[each.value.edge_gw_instance].id
  transit_gw_name             = each.value.transit
  enable_jumbo_frame          = each.value.enable_jumbo_frame
  enable_over_private_network = each.value.enable_over_private_network
  enable_insane_mode          = each.value.enable_insane_mode
  insane_mode_tunnel_number   = each.value.insane_mode_tunnel_number
  spoke_prepend_as_path       = each.value.spoke_prepend_as_path
  transit_prepend_as_path     = each.value.transit_prepend_as_path
  edge_wan_interfaces         = ["eth0"] #Hardcoded patch for issue with provider.

  lifecycle {
    precondition {
      condition     = aviatrix_edge_gateway_selfmanaged.default[each.value.edge_gw_instance].state == "up"
      error_message = format("The edge gateway %s is not yet up. You can prevent this error by leaving it detached (do not set attached = true on each gateway) until the gateway is up.", each.value.gw_name)
    }
  }
}

resource "aviatrix_edge_spoke_external_device_conn" "default" {
  for_each = local.bgp_peers

  site_id           = var.site_id
  gw_name           = aviatrix_edge_gateway_selfmanaged.default[each.value.edge_gw_instance].id
  connection_name   = each.value.connection_name
  bgp_local_as_num  = aviatrix_edge_gateway_selfmanaged.default[each.value.edge_gw_instance].local_as_number
  bgp_remote_as_num = each.value.bgp_remote_as_num
  local_lan_ip      = split("/", each.value.lan_prefix)[0]
  remote_lan_ip     = each.value.remote_lan_ip
  connection_type   = "bgp" #Only supported value
  tunnel_protocol   = "LAN" #Only supported value

  lifecycle {
    precondition {
      condition     = can(signum(aviatrix_edge_gateway_selfmanaged.default[each.value.edge_gw_instance].local_as_number))
      error_message = format("The edge gateway %s does not have a local as number configured. This is required for BGP peering.", each.value.gw_name)
    }

    precondition {
      condition     = aviatrix_edge_gateway_selfmanaged.default[each.value.edge_gw_instance].state == "up"
      error_message = format("The edge gateway %s is not yet up. You can prevent this error by removing the BGP peerings until the gateway is up.", each.value.gw_name)
    }
  }
}
