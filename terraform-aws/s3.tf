# S3 Bucket for Static Website
resource "aws_s3_bucket" "main" {
  bucket = "bucket-${var.iam_name}-${random_string.bucket_suffix.result}"

  tags = {
    Name = "bucket-${var.iam_name}"
  }
}

# Random string for unique bucket name
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# S3 Bucket Public Access Block (disable for public website)
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Policy for Public Read Access
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.main.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.main]
}

# Upload index.html to S3
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.main.id
  key          = "index.html"
  content_type = "text/html"
  content      = <<-HTML
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>My Capstone Project Home Page</title>
    </head>
    <body>
      <h1>Welcome to my ${var.iam_name} website</h1>
      <p>Creator of this page: ${var.iam_name}</p>
      <p>Now hosted on Amazon S3!</p>
    </body>
    </html>
  HTML

  depends_on = [aws_s3_bucket_policy.main]
}

# Upload error.html to S3
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.main.id
  key          = "error.html"
  content_type = "text/html"
  content      = <<-HTML
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>Error</title>
    </head>
    <body>
      <h1>Error - Page Not Found</h1>
      <p>The page you requested does not exist.</p>
    </body>
    </html>
  HTML

  depends_on = [aws_s3_bucket_policy.main]
}
