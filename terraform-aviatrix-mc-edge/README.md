# terraform-aviatrix-mc-edge

### Description
Deploys one or multiple Aviatrix edge gateways to a site and attaches it to the desired transit gateway(s) and network domain for segmentation.

### Compatibility
Module version | Terraform version | Controller version | Terraform provider version
:--- | :--- | :--- | :---
v1.3.0 | >= 1.3.0 | >= 7.1 | ~> 3.1.0

### Usage Example
See [examples](https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-edge/tree/main/examples)
```hcl
module "branch1" {
  source  = "terraform-aviatrix-modules/mc-edge/aviatrix"
  version = "v1.3.0"

  site_id        = "home"
  network_domain = "test"

  edge_gws = {
    gw1 = {
      gw_name                 = "gw1",
      lan_interface_ip_prefix = "10.50.10.10/24",
      transit_gws = {
        transit1 = {
          name               = "transit1",
          attached           = true
          enable_jumbo_frame = true,
        },
        transit2 = {
          name = "transit2",
        },
      }
      wan_default_gateway_ip  = "1.1.1.1"
      wan_interface_ip_prefix = "1.1.1.10/24"
    }
    gw2 = {
      gw_name                 = "gw2",
      lan_interface_ip_prefix = "10.50.10.11/24",
      transit_gws = {
        transit1 = {
          name               = "transit1",
          attached           = true
          enable_jumbo_frame = true,
        },
        transit2 = {
          name     = "transit2",
          attached = true
        },
      }
      wan_default_gateway_ip  = "1.1.1.1"
      wan_interface_ip_prefix = "1.1.1.11/24"
    }
  }
}
```
On first apply, the ISO/Cloud-init gets created for deployiong the actual gateway. Once gateway deployment is complete, add `attached = true` to each gw entry to create the attachment to the transit gateway, any network segmentation domain as well as set up any desired BGP peers.

### Module variables
The following variables are required:

key | value
:--- | :---
edge_gws | A map of edge gateways.
site_id | Site ID for the spoke gateway.

### Mandatory Edge Gateway map attributes (edge_gws)
key | value
:--- | :---
lan_interface_ip_prefix | A list of LAN interface IP and subnet prefix for each edge gw.
wan_default_gateway_ip | WAN default gateway IP.
wan_interface_ip_prefix | WAN interface IP and subnet prefix.

### Mandatory Transit Gateway map attributes (transit_gws)
key | value
:--- | :---
name | Name of the transit gateway to attach to.
attached | Whether the edge gateway should be attached to this transit.

### Mandatory BGP peering map attributes (bgp_peers)
key | value
:--- | :---
connection_name | Name for the BGP peering.
bgp_remote_as_num | AS Number of the remote gateway to peer with.
remote_lan_ip | IP Address of the remote gateway to peer with.

### Optional module variables
key | default | value
:--- | :--- | :---
transit_gws | | A list of names of the transit gateways to attach this edge to.
ztp_file_download_path | execution folder | The folder path where the ZTP file will be downloaded.
network_domain | | Provide network domain name to which the edges needs to be deployed. Transit gateways must have segmentation enabled.
ztp_file_type | "iso" | ZTP file type. Valid values: "iso", "cloud-init".

### Optional Edge Gateway map attributes (edge_gws)
key | default | value 
:---|:---|:---
approved_learned_cidrs | | A list of approved learned CIDRs.
bgp_hold_time | | BGP hold time. Unit is in seconds.
bgp_peers | | Map of BGP peers to set up for this edge gateway. Requires a local_as_number to be set on the gateway.
bgp_polling_time | | BGP route polling time. Unit is in seconds.
dns_server_ip | | DNS server IP.
enable_edge_active_standby | | Switch to enable Edge Active-Standby mode.
enable_edge_active_standby_preemptive | | Switch to enable Preemptive Mode for Edge Active-Standby.
enable_edge_transitive_routing | | Switch to enable Edge transitive routing.
enable_jumbo_frame | false | Switch to enable jumbo frame on gateway.
enable_learned_cidrs_approval | false | Switch to enable/disable CIDR approval for BGP Edge Gateway.
enable_management_over_private_network | | Switch to enable management over the private network.
enable_preserve_as_path | | Enable preserve as_path when advertising manual summary cidrs on BGP edge gateway.
latitude | | Edge gateway latitude.
local_as_number | | Configures the Aviatrix Edge Gateway ASN number.
longitude | | Edge gateway longitude.
management_default_gateway_ip | | Management default gateway IP.
management_egress_ip_prefix_list | | Management egress gateway IP and subnet prefix.
management_enable_dhcp | false | Enable DHCP on the management interface.
management_interface_ip_prefix | | Management interface IP and subnet prefix.
prepend_as_path | | List of AS numbers to prepend gateway BGP AS_Path field. Valid only when local_as_number is set.
secondary_dns_server_ip | | Secondary DNS server IP.
spoke_bgp_manual_advertise_cidrs | | Intended CIDR list to be advertised to external BGP router.
wan_public_ip | | WAN public IP. Required for attaching connections over the Internet.

### Optional Transit Gateway map attributes (transit_gws)
key | default | value 
:---|:---|:---
attached | false | Set to true to attach it to the transit gateway after provisioning.
enable_jumbo_frame | false | Switch to enable jumbo frame on attachment.
enable_insane_mode | false | Switch to enable insane mode.
enable_over_private_network | true | Set to false to use public network.
insane_mode_tunnel_number | | Insane mode tunnel number.
spoke_prepend_as_path | | Connection based AS Path Prepend. Can only use the gateway's own local AS number, repeated up to 25 times. Applies on the Edge as a Spoke.
transit_prepend_as_path | | Connection based AS Path Prepend. Can only use the gateway's own local AS number, repeated up to 25 times. Applies on the Transit Gateway.

### Outputs
This module will return the following outputs:

key | description
:---|:---
\<keyname> | \<description of object that will be returned in this output>
