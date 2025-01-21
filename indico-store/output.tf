output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.static_files.bucket
}
