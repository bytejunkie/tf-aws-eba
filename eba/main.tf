resource "aws_iam_role" "eba_role" {
  name = "eba_write_logs_role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "eba_policy" {
  name = "eba_policy"
  role = aws_iam_role.eba_role.id

  policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:GetLogEvents",
                    "logs:PutLogEvents",
                    "logs:DescribeLogGroups",
                    "logs:DescribeLogStreams",
                    "logs:PutRetentionPolicy"
                ],
                "Resource": [
                    "*"
                ]
            }
        ]
    }
  EOF
}

resource "aws_iam_instance_profile" "eba_profile" {
  name = "eba_instance_profile"
  role = aws_iam_role.eba_role.name
}

resource "aws_elastic_beanstalk_application" "my_eba" {
  name        = format("%s-%s", local.resource_prefix, "eba-01")
  description = "my elastic beanstalk application"

  appversion_lifecycle {
    #TODO need to define this iam role.
    service_role          = aws_iam_role.eba_role.arn
    max_count             = 28
    delete_source_from_s3 = true
  }
}

resource "aws_elastic_beanstalk_configuration_template" "my_ebe_template" {
  name                = format("%s-%s", local.resource_prefix, "ebe-template-01")
  application         = aws_elastic_beanstalk_application.my_eba.name
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.15.0 running Docker 19.03.6-ce"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }
}

resource "aws_elastic_beanstalk_environment" "my_ebe" {

  name          = format("%s-%s", local.resource_prefix, "ebe-01")
  application   = aws_elastic_beanstalk_application.my_eba.name
  template_name = aws_elastic_beanstalk_configuration_template.my_ebe_template.name


  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eba_profile.name
  }
}

# data "aws_s3_bucket" "carpics" {
#   bucket = "carpics-deploy"
# }

data "aws_s3_bucket_object" "carpics" {
  bucket = "carpics-deploy"
  key    = "source/carpics.zip"
}

resource "aws_elastic_beanstalk_application_version" "carpics" {
  name        = "mycarpics"
  application = aws_elastic_beanstalk_application.my_eba.name
  description = "application version created by terraform"
  bucket      = data.aws_s3_bucket_object.carpics.bucket
  key         = data.aws_s3_bucket_object.carpics.key
}
