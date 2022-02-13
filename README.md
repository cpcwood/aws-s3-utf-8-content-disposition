# AWS S3 UTF-8 Content Disposition - Examples

**WIP**

Sample scripts and AWS infrastructure to generate AWS S3 UTF-8 content disposition examples as outlined in my blog post: [AWS S3 UTF-8 Content Disposition](https://cpcwood.com/blog). 

## Dependencies

Install required dependencies:
- [bash](https://www.gnu.org/software/bash/) ([command-not-found](https://command-not-found.com/bash))
- [terraform v1.1.5](https://learn.hashicorp.com/tutorials/terraform/install-cli) ([tfenv](https://github.com/tfutils/tfenv) can be useful)
- [ruby v3.1.0](https://www.ruby-lang.org/en/downloads/)

## Building Infrastructure

### AWS Credentials

Create IAM user with relevant permissions for Terraform ECS setup (S3, DynamoDB, CloudFront, etc), or `AdministratorAccess` for quicker setup.

Add access keys for the IAM user to the `aws-s3-utf-8-content-disposition` AWS profile in the credentials list on your machine:

```sh
sudo vim ~/.aws/credentials
```

```
[aws-s3-utf-8-content-disposition]
aws_access_key_id = <iam user access key id>
aws_secret_access_key = <iam user secret key>
```

