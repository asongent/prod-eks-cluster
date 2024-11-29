output "public_subnet" {
  value = aws_subnet.public.id
}

output "private_subnet" {
  value = aws_subnet.private.id
}

output "nat_gw" {
  value = aws_nat_gateway.nat_gw.id
}

output "private_route_table" {
  value = aws_route_table.private.id
}

output "rt_association_public" {
  value = aws_route_table_association.public.id
}

output "rt_association_private" {
  value = aws_route_table_association.private.id
}
