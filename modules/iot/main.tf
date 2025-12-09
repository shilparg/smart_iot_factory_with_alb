# modules/iot/main.tf

############################################
# IoT Resources
############################################
data "aws_iot_endpoint" "iot" {
  endpoint_type = "iot:Data-ATS"
}

resource "aws_iot_thing" "simulator" {
  name = "${var.environment}-iot-simulator"
  attributes = {
    Owner = var.tags["Owner"] # Pass owner tag to IoT attribute
  }
}

resource "aws_iot_policy" "sim_policy" {
  name   = "iot-sim-policy-${var.environment}"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iot:Connect",
          "iot:Publish",
          "iot:Subscribe",
          "iot:Receive"
        ]
        # Resource = [
        #   "arn:aws:iot:${var.region}:*:client/*",
        #   "arn:aws:iot:${var.region}:*:topic/${var.iot_topic}/*",
        #   "arn:aws:iot:${var.region}:*:topicfilter/${var.iot_topic}/*"
        # ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iot_certificate" "sim_cert" {
  active = true
}

resource "aws_iot_policy_attachment" "attach" {
  policy = aws_iot_policy.sim_policy.name
  target = aws_iot_certificate.sim_cert.arn
}

resource "aws_iot_thing_principal_attachment" "attach_cert" {
  thing     = aws_iot_thing.simulator.name
  principal = aws_iot_certificate.sim_cert.arn
}
