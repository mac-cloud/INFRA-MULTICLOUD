variable "cloudflare_api_token" {
    type = string
    sensitive = true  
}

variable "cloudflare_zone_id" {
    type = string
    description = "00551866de631b76912fe8aea09bcbea"
}
variable "domain_name" {
  type = string
  default = "afritrekclub.com"
}
variable "aws_ingress_url" {
    type = string
    description = "" //The public ingress URL or Loadbalancer DNS name from AWS cluster
  
}
variable "azure_ingress_url" {
    type = string
    description =""  // The public ingress URL or Loadbalancer DNS name from Azure cluster
  
}
// To use Cloudflare's failover, we need to know our cluster will expose our service publicly. Typically, each cluster will have an ingress controller eg (nginx ingress) or loadblancer services fronting the application .so we have set up a public ingress  of loadbalancer service in each cluster that provides a DNS endpoint:




// S8jTNEoCUI_f6nyfA3j2Sx-IC4nMu_5Rp9Sgeb2c