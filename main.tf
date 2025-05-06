locals {
  edge_iso = ["${path.cwd}/au-bne-plrs-avx-edge01-BHPB1076.iso", "${path.cwd}/au-bne-plrs-avx-edge02-BHPB1076.iso"]
}


resource "aws_s3_bucket" "avx-edge-iso" {
  bucket = "it-bhp-aws-avx-edge-iso-test"

  tags = {
    Name        = "avx-edge-iso"
    Environment = "prd"
  }
}

# resource "aws_s3_bucket_acl" "avx-edge-iso-acl" {
#   bucket = aws_s3_bucket.avx-edge-iso.id
#   #acl    = "private"
# }

resource "aws_s3_bucket_public_access_block" "avx-edge-iso-access" {
  bucket                  = aws_s3_bucket.avx-edge-iso.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "avx-edge-iso-upload" {
  for_each = toset(local.edge_iso)
  bucket   = aws_s3_bucket.avx-edge-iso.id
  key      = basename(each.value)
  source   = each.value

  depends_on = [
    module.edge-plrs
  ]
}

######################################################


#### Aviatrix Edge deployment in Polaris #####

module "edge-plrs" {
  source = "./terraform-aviatrix-mc-edge"

  site_id                = "BHPB1076"
  network_domain         = "it-bne-dct2"
  ztp_file_download_path = path.cwd

  edge_gws = {
    au-bne-plrs-avx-edge01 = {
      gw_name                          = "au-bne-plrs-avx-edge01"
      management_egress_ip_prefix_list = ["123.103.194.10/30", "123.103.194.14/30", "49.255.89.50/30"]
      management_over_private_network  = false
      management_default_gateway_ip    = "10.30.229.121"
      management_interface_ip_prefix   = "10.30.229.122/29"
      lan_interface_ip_prefix          = "10.30.229.106/29"
      wan_default_gateway_ip           = "10.30.229.113"
      wan_interface_ip_prefix          = "10.30.229.114/29"
      enable_jumbo_frame               = false
      dns_server_ip                    = "10.138.64.70"
      local_as_number                  = "64999"
      prepend_as_path                  = ["64999", "64999", "64999", "64999", "64999", "64999", "64999", "64999", "64999", "64999", ]
      enable_learned_cidrs_approval    = true
      approved_learned_cidrs           = ["10.200.0.0/24"]
      enable_edge_transitive_routing   = false
      rx_queue_size                    = "2K"
      transit_gws = {
        aws_apse2_transit = {
          spoke_gw_name               = "au-bne-plrs-avx-edge01"
          name                        = "transit-gw"
          attached                    = false
          enable_jumbo_frame          = false
          enable_insane_mode          = true
          enable_over_private_network = true
        },
        azr_ause_transit = {
          spoke_gw_name               = "au-bne-plrs-avx-edge01"
          name                        = "it-azr-ause-prd-transit"
          attached                    = false
          enable_jumbo_frame          = false
          enable_insane_mode          = true
          enable_over_private_network = true
        }
      }
      # bgp_peers = {
      #   plrs_edge_lan_peer = {
      #     connection_name   = "plrs-edge01-wed"
      #     bgp_remote_as_num = "64618"
      #     remote_lan_ip     = "10.30.229.105"
      #   }
      # }
    }

    au-bne-plrs-avx-edge02 = {
      gw_name                          = "au-bne-plrs-avx-edge02"
      management_egress_ip_prefix_list = ["123.103.194.10/30", "123.103.194.14/30", "49.255.89.50/30"]
      management_over_private_network  = false
      management_default_gateway_ip    = "10.30.229.121"
      management_interface_ip_prefix   = "10.30.229.123/29"
      lan_interface_ip_prefix          = "10.30.229.107/29"
      wan_default_gateway_ip           = "10.30.229.113"
      wan_interface_ip_prefix          = "10.30.229.115/29"
      enable_jumbo_frame               = false
      dns_server_ip                    = "10.138.64.70"
      local_as_number                  = "64999"
      prepend_as_path                  = ["64999", "64999", "64999", "64999", "64999", "64999", "64999", "64999", "64999", "64999", ]
      enable_learned_cidrs_approval    = true
      approved_learned_cidrs           = ["10.200.0.0/24"]
      enable_edge_transitive_routing   = false
      rx_queue_size                    = "2K"
      transit_gws = {
        aws_apse2_transit = {
          spoke_gw_name               = "au-bne-plrs-avx-edge02"
          name                        = "transit-gw"
          attached                    = false
          enable_jumbo_frame          = false
          enable_insane_mode          = true
          enable_over_private_network = true
        },
        azr_ause_transit = {
          spoke_gw_name               = "au-bne-plrs-avx-edge02"
          name                        = "it-azr-ause-prd-transit"
          attached                    = false
          enable_jumbo_frame          = false
          enable_insane_mode          = true
          enable_over_private_network = true
        }
      }
      # bgp_peers = {
      #   plrs_edge_lan_peer = {
      #     connection_name   = "plrs-edge02-wed"
      #     bgp_remote_as_num = "64618"
      #     remote_lan_ip     = "10.30.229.105"
      #   }
      # }
    }
  }
}
