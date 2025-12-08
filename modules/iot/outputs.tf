# modules/iot/outputs.tf

output "iot_endpoint" {
  value = data.aws_iot_endpoint.iot.endpoint_address
}

output "iot_thing_name" {
  value = aws_iot_thing.simulator.name
}

output "iot_policy_name" {
  value = aws_iot_policy.sim_policy.name
}

output "certificate_arn" {
  value = aws_iot_certificate.sim_cert.arn
}

output "certificate_id" {
  value = aws_iot_certificate.sim_cert.id
}
