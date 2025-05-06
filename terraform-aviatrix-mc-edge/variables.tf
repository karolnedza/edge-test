variable "edge_gws" {
  description = "A map of edge gateways."
  type = map(object({
    wan_interface_ip_prefix = string,
    gw_name                 = string,
    lan_interface_ip_prefix = string,

    wan_default_gateway_ip                 = string,
    management_enable_dhcp                 = optional(bool),
    management_default_gateway_ip          = optional(string),
    management_egress_ip_prefix_list       = optional(set(string), []),
    enable_management_over_private_network = optional(bool),
    enable_edge_active_standby             = optional(bool),
    enable_edge_active_standby_preemptive  = optional(bool),
    management_interface_ip_prefix         = optional(string),
    dns_server_ip                          = optional(string),
    secondary_dns_server_ip                = optional(string),
    local_as_number                        = optional(number),
    prepend_as_path                        = optional(list(number)),
    enable_learned_cidrs_approval          = optional(bool),
    approved_learned_cidrs                 = optional(list(string)),
    spoke_bgp_manual_advertise_cidrs       = optional(list(string)),
    enable_preserve_as_path                = optional(bool),
    bgp_polling_time                       = optional(number),
    bgp_hold_time                          = optional(number),
    enable_edge_transitive_routing         = optional(bool),
    latitude                               = optional(string),
    longitude                              = optional(string),
    wan_public_ip                          = optional(string),
    enable_jumbo_frame                     = optional(bool),

    transit_gws = optional(map(object({
      name                        = string,
      enable_jumbo_frame          = optional(bool),
      enable_over_private_network = optional(bool),
      enable_insane_mode          = optional(bool),
      attached                    = optional(bool),
      insane_mode_tunnel_number   = optional(number),
      spoke_prepend_as_path       = optional(list(string)),
      transit_prepend_as_path     = optional(list(string)),
    }))),

    bgp_peers = optional(map(object({
      connection_name   = string,
      bgp_remote_as_num = number,
      remote_lan_ip     = string,
    }))),
  }))

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : length(v.gw_name) <= 50
    ])
    error_message = "gw_name is too long. Max length is 50 characters."
  }

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : can(regex("^[a-zA-Z0-9-_]*$", v.gw_name))
    ])
    error_message = "Only a-z, A-Z, 0-9 and hyphens and underscores are allowed."
  }

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : can(cidrnetmask(v.wan_interface_ip_prefix))
    ])
    error_message = "wan_interface_ip_prefix does not like a valid IP/NETMASK combination."
  }

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : can(cidrnetmask(format("%s/32", v.wan_default_gateway_ip)))
    ])
    error_message = "wan_default_gateway_ip does not like a valid IP address."
  }

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : can(cidrnetmask(v.lan_interface_ip_prefix))
    ])
    error_message = "lan_interface_ip_prefix does not like a valid IP/NETMASK combination."
  }

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : alltrue(
        [for cidr in v.management_egress_ip_prefix_list : can(cidrnetmask(cidr))]
      ) || v.management_egress_ip_prefix_list == null
    ])
    error_message = "management_egress_ip_prefix_list does not like a set with valid IP/NETMASK combinations."
  }

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : can(cidrnetmask(v.management_interface_ip_prefix)) || v.management_interface_ip_prefix == null
    ])
    error_message = "management_interface_ip_prefix does not like a valid IP/NETMASK combination."
  }

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : can(cidrnetmask(format("%s/32", v.management_default_gateway_ip))) || v.management_default_gateway_ip == null
    ])
    error_message = "management_default_gateway_ip does not like a valid IP address."
  }

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : can(cidrnetmask(format("%s/32", v.dns_server_ip))) || v.dns_server_ip == null
    ])
    error_message = "dns_server_ip does not like a valid IP address."
  }

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : can(cidrnetmask(format("%s/32", v.secondary_dns_server_ip))) || v.secondary_dns_server_ip == null
    ])
    error_message = "secondary_dns_server_ip does not like a valid IP address."
  }

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : v.bgp_polling_time != null ? v.bgp_polling_time >= 10 && v.bgp_polling_time <= 50 : true
    ])
    error_message = "bgp_polling_time invalid value. Must be in range 10-50."
  }

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : v.bgp_hold_time != null ? v.bgp_hold_time >= 12 && v.bgp_hold_time <= 360 : true
    ])
    error_message = "bgp_hold_time invalid value. Must be in range 12-360."
  }

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : can(regex("^(\\+|-)?(?:90(?:(?:\\.0{1,6})?)|(?:[0-9]|[1-8][0-9])(?:(?:\\.[0-9]{1,6})?))$", v.latitude)) || v.latitude == null
    ])
    error_message = "This does not like a valid latitude."
  }

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : can(regex("^(\\+|-)?(?:180(?:(?:\\.0{1,6})?)|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:(?:\\.[0-9]{1,6})?))$", v.longitude)) || v.longitude == null
    ])
    error_message = "This does not like a valid longitude."
  }

  validation {
    condition = alltrue([
      for k, v in var.edge_gws : can(cidrnetmask(format("%s/32", v.wan_public_ip))) || v.wan_public_ip == null
    ])
    error_message = "wan_public_ip does not like a valid IP address."
  }
}

variable "site_id" {
  description = "Site ID for the spoke gateway."
  type        = string

  validation {
    condition     = length(var.site_id) <= 50
    error_message = "Name is too long. Max length is 50 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]*$", var.site_id))
    error_message = "Only a-z, A-Z, 0-9 and hyphens and underscores are allowed."
  }
}

variable "ztp_file_type" {
  description = "ZTP file type."
  type        = string
  default     = "iso"
  nullable    = false

  validation {
    condition     = contains(["iso", "cloud-init"], lower(var.ztp_file_type))
    error_message = "Invalid ztp_file_type type. Choose iso or cloud-init."
  }
}

variable "ztp_file_download_path" {
  description = "The folder path where the ZTP file will be downloaded."
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = can(dirname(var.ztp_file_download_path))
    error_message = "Invalid ztp_file_download_path."
  }
}

variable "network_domain" {
  description = "Provide network domain name to which edge needs to be deployed. Transit gateway must be attached and have segmentation enabled."
  type        = string
  default     = ""
  nullable    = false
}

locals {
  ztp_file_download_path = var.ztp_file_download_path == "" ? path.root : var.ztp_file_download_path

  #Forge map for network domain attachments
  network_domain_attachments = merge([for k, v in var.edge_gws :
    { for x, y in coalesce(v.transit_gws, {}) :
      format("%s-%s", k, y.name) => {
        edge_gw_instance = k
        transit          = y.name
        gw_name          = v.gw_name
      }
      if coalesce(y.attached, false)
    }
    if length(var.network_domain) > 0
  ]...)

  #Forge map for transit attachments
  transit_attachments = merge([for k, v in var.edge_gws :
    { for x, y in coalesce(v.transit_gws, {}) :
      format("%s-%s", k, y.name) => {
        edge_gw_instance            = k
        transit                     = y.name
        gw_name                     = v.gw_name
        enable_jumbo_frame          = y.enable_jumbo_frame
        enable_over_private_network = y.enable_over_private_network
        enable_insane_mode          = y.enable_insane_mode
        insane_mode_tunnel_number   = y.insane_mode_tunnel_number
        spoke_prepend_as_path       = y.spoke_prepend_as_path
        transit_prepend_as_path     = y.transit_prepend_as_path
      }
      if coalesce(y.attached, false)
    }
  ]...)

  #Forge map for bgp peers
  bgp_peers = merge([for k, v in var.edge_gws :
    { for x, y in coalesce(v.bgp_peers, {}) :
      format("%s-%s", k, y.connection_name) => {
        edge_gw_instance  = k
        gw_name           = v.gw_name
        lan_prefix        = v.lan_interface_ip_prefix
        connection_name   = y.connection_name,
        bgp_remote_as_num = y.bgp_remote_as_num,
        remote_lan_ip     = y.remote_lan_ip,
      }
    }
  ]...)
}
