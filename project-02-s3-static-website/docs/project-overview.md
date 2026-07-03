# Project Overview

## The Business Problem
Serving a static website directly from a single web server or an S3 bucket can be slow for users located geographically far from the server. Furthermore, serving directly from S3 does not support custom SSL certificates natively.

## The Solution
This project uses Amazon CloudFront (a global CDN) to cache the S3 website content at edge locations worldwide. This ensures lightning-fast delivery to users regardless of their location, while also enabling enforced HTTPS using AWS edge SSL certificates.