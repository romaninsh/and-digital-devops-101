
resource "aws_route53_zone" "dns" {
  name = "aa.dekker-and.digital"

  tags = local.tags
}

locals {
  subdomains = {
    "uat-marius.aa.dekker-and.digital" : [
      "ns-1010.awsdns-62.net",
      "ns-1067.awsdns-05.org",
      "ns-1589.awsdns-06.co.uk",
      "ns-67.awsdns-08.com",
    ],

    "uat-andrea.aa.dekker-and.digital" : [
      "ns-89.awsdns-11.com",
      "ns-1968.awsdns-54.co.uk",
      "ns-926.awsdns-51.net",
      "ns-1506.awsdns-60.org",
    ]
  }
}

resource "aws_route53_record" "rec" {
  zone_id = aws_route53_zone.dns.id
  type = "NS"
  ttl  = "300"

  for_each = local.subdomains

  name = each.key
  records = each.value
}
