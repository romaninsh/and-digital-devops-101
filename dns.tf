
resource "aws_route53_zone" "dns" {
  name = "aa.dekker-and.digital"



  tags = local.tags
}

locals {
  subdomains = {
    "uat-marius" : [
      "ns-1010.awsdns-62.net",
      "ns-1067.awsdns-05.org",
      "ns-1589.awsdns-06.co.uk",
      "ns-67.awsdns-08.com",
    ],

    "uat-andrea" : [
      "ns-89.awsdns-11.com",
      "ns-1968.awsdns-54.co.uk",
      "ns-926.awsdns-51.net",
      "ns-1506.awsdns-60.org",
    ],

    "nyakpo" : [
      "ns-888.awsdns-47.net",
      "ns-1572.awsdns-04.co.uk",
      "ns-1481.awsdns-57.org",
      "ns-266.awsdns-33.com",
    ]
  }
}

resource "aws_route53_record" "rec" {
  zone_id = aws_route53_zone.dns.id
  type = "NS"
  ttl  = "300"

  for_each = local.subdomains

  name = "${each.key}.${var.subdomain}"
  records = each.value
}
