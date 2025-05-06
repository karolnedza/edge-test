# Single Edge Single Transit Segmentation
This will create a single edge gateway and attach it to a single transit. The edge will be placed in a network domain for segmentation.

```hcl
module "branch1" {
  source  = "terraform-aviatrix-modules/mc-edge/aviatrix"
  version = "1.3.0"

  site_id        = "branch1"
  network_domain = "branches"

  edge_gws = {
    gw1 = {
      gw_name                 = "gw1",
      lan_interface_ip_prefix = "10.50.10.10/24",
      wan_default_gateway_ip  = "1.1.1.1"
      wan_interface_ip_prefix = "1.1.1.10/24"

      transit_gws = {
        transit1 = {
          name = "transit1",
          #attached = true
        },
      }
    }
  }
}
```