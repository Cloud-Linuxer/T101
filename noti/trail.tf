data "aws_caller_identity" "current" {}


resource "aws_s3_bucket" "linuxer-bucket" {
  bucket        = "linuxer-cloudtrail"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "linuxer-bucket" {
  bucket = aws_s3_bucket.linuxer-bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.linuxer-bucket.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.linuxer-bucket.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_cloudtrail" "linuxer-cloudtrail" {
  name                          = "linuxer-cloudtail"
  s3_bucket_name                = aws_s3_bucket.linuxer-bucket.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false
  depends_on = [aws_s3_bucket_policy.linuxer-bucket]
}
