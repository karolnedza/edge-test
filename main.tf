
locals {
  edge_iso = ["${path.cwd}/au-bne-plrs-avx-edge01-BHPB1076.iso"]
}


resource "aws_s3_bucket" "avx-edge-iso" {
  bucket = "it-bhp-aws-avx-edge-iso-karol"

  tags = {
    Name        = "avx-edge-iso"
    Environment = "prd"
  }
}


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
    aviatrix_edge_gateway_selfmanaged.test
  ] 
}

####################################################


resource "aviatrix_edge_gateway_selfmanaged" "test" {
  gw_name         = "au-bne-plrs-avx-edge01"
  site_id                 = "BHPB1076"
  ztp_file_type           = "iso"
  ztp_file_download_path = path.cwd
  dns_server_ip           = "8.8.8.8"
  secondary_dns_server_ip = "8.8.6.6"

  interfaces {
    name          = "eth0"
    type          = "WAN"
    ip_address    = "10.230.6.32/24"
    gateway_ip    = "10.230.6.100"
    wan_public_ip = "64.71.25.221"
  }

  interfaces {
    name       = "eth1"
    type       = "LAN"
    ip_address = "10.220.11.20/24"
    gateway_ip = "10.220.11.1"
  }

  interfaces {
    name        = "eth2"
    type        = "MANAGEMENT"
    enable_dhcp = true
  }
}
