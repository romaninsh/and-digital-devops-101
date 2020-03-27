
resource "aws_route53_zone" "dns" {
  name = "aa.dekker-and.digital"

  tags = local.tags
}

resource "aws_route53_record" "rec" {
  name = "uat-marius.aa.dekker-and.digital"
  type = "NS"
  ttl     = "300"

  zone_id = aws_route53_zone.dns.id
  records = [
    "ns-1010.awsdns-62.net",
    "ns-1067.awsdns-05.org",
    "ns-1589.awsdns-06.co.uk",
    "ns-67.awsdns-08.com",
  ]
}
