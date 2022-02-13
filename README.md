# AWS S3 UTF-8 Content Disposition - Examples

Sample scripts and AWS infrastructure to generate the AWS S3 UTF-8 content disposition examples outlined in my blog post: [AWS S3 UTF-8 Content Disposition](https://www.cpcwood.com/blog/5-aws-s3-utf-8-content-disposition).

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

### Create The Infrastructure

Fork or clone the project.

IMPORTANT: While the infrastructure required for this example project is covered by the AWS `Always free` tier, high usage or installation on an account with other resource usage may cost you money. Please remember evaluate costs and to teardown project afterwards.

Run build script:

```sh
./bin/build_infrastructure
```

### Teardown The Infrastructure

Run destroy script:

```sh
./bin/destroy_infrastructure
```


## Examples

Once the project infrastructure is build, navigate to the project root directory to run the examples script.

The examples create signed CloudFront URLs to download the sample S3 object `not-a-cat.jpg` with a different filename. The filename is set using the `response-content-disposition` parameter.

The example script is written in Ruby and is run by calling the follow command, replacing `<example-number>` with the number of the example you want to run:

```sh
ruby ./examples.rb <example-number>
```

The script will output a signed URL which will be valid for 600 seconds by default.

Copy and paste the outputted URL into your browser to download the file and test the filename.

Examples:
  - 1: Sets Content-Disposition on request to download object with the filename `jessie.jpg`
  - 2: Sets filename to `"고양이.jpg"`, URL encoding the filename in the `response-content-disposition` parameter once. Results in AWS S3 error.
  - 3: Sets filename to `"고양이.jpg"`, URL encoding the UTF-8 filename in the `response-content-disposition` parameter twice, allowing AWS S3 to return it to the client in ISO-8859-1
