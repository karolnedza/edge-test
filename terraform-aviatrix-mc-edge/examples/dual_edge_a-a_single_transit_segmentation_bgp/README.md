# Single Edge Active/Active Single Transit Segmentation with BGP
This will create a single edge gateway and attach it to a single transit. The edge will be placed in a network domain for segmentation.

```hcl
module "branch1" {
  source  = "terraform-aviatrix-modules/mc-edge/aviatrix"
  version = "1.3.0"

  site_id        = "branch1"
  network_domain = "branches"

  edge_gws = {

    #Edge Gateway 1
    gw1 = {
      gw_name                 = "gw1",
      lan_interface_ip_prefix = "10.50.10.10/24",
      wan_default_gateway_ip  = "1.1.1.1"
      wan_interface_ip_prefix = "1.1.1.10/24"
      local_as_number         = 65010

      #Settings for transit gateway attachment for Edge Gateway 1
      transit_gws = {
        transit1 = {
          name = "transit1",
          #attached = true
        },
      }

      #BGP Peerings for Edge Gateway 1
      bgp_peers = {
        peering1 = {
          connection_name   = "gw1_to_lan_router1"
          bgp_remote_as_num = 65001
          remote_lan_ip     = "10.50.10.1"
        }
        peering2 = {
          connection_name   = "gw1_to_lan_router2"
          bgp_remote_as_num = 65001
          remote_lan_ip     = "10.50.10.2"
        }
      }
    }

    #Edge Gateway 2
    gw2 = {
      gw_name                 = "gw2",
      lan_interface_ip_prefix = "10.50.10.11/24",
      wan_default_gateway_ip  = "1.1.1.1"
      wan_interface_ip_prefix = "1.1.1.11/24"
      local_as_number         = 65010

      #Settings for transit gateway attachment for Edge Gateway 1
      transit_gws = {
        transit1 = {
          name = "transit1",
          #attached = true
        },
      }

      #BGP Peerings for Edge Gateway 1
      bgp_peers = {
        peering1 = {
          connection_name   = "gw2_to_lan_router1"
          bgp_remote_as_num = 65001
          remote_lan_ip     = "10.50.10.1"
        }
        peering2 = {
          connection_name   = "gw2_to_lan_router2"
          bgp_remote_as_num = 65001
          remote_lan_ip     = "10.50.10.2"
        }
      }
    }
  }
}
```