resource "cloudflare_load_balancer_pool" "aws_pool" {
    name = "aws-pool"

    origin {
        name = "aws-origin"
        address = var.aws_ingress_url
    }
}

resource "cloudflare_load_balancer_pool" "azure_pool" {
    name = "azure-pool"

    origin {
        name = "azure-origin"
        address = var.azure_ingress_url
    }
}

resource "cloudflare_load_balancer" "this" {
    zone_id = var.cloudflare_zone_id
    name = "app.${var.domain_name}"
    fallback_pools = [cloudflare_load_balancer_pool.azure_pool.id]
    default_pools  = [cloudflare_load_balancer_pool.aws_pool.id]
    proxied        = true
}

resource "cloudflare_record" "lb_dns_record" {
    zone_id = var.cloudflare_zone_id
    name    = "app"
    type    = "CNAME"
    value   = cloudflare_load_balancer.this.name
    proxied = true
}
