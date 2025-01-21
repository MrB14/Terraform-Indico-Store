resource "aws_s3_bucket" "static_files" {
  bucket = "indico-store-static-files-${random_string.suffix.result}"
  acl    = "public-read"
}
