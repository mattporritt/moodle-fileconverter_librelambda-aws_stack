# AWS Stack for Libre Lambda Document Converter #

This is the Amazon Web Services (AWS) stack infrastructure for the [LibreOffice file converter plugin](https://github.com/catalyst/moodle-fileconverter_librelambda) for Moodle LMS.
The primary function of this plugin is to convert student submissions into the PDF file format, to allow teachers to use the annotate PDF functionality of Moodle.

This stack primarily consists of an "input" [S3](https://aws.amazon.com/s3/) bucket, a file converting [Lambda](https://aws.amazon.com/lambda/) function and an "output" S3 bucket.
Once the stack is setup the associated Moodle plugin uploads files to be converted to the input S3 bucket.  The uploading of these
input files trigger the Lambda function. The Lambda function uses LibreOffice to convert the file to PDF. Once the files are converted
the Lambda function moves the converted PDF to the output bucket. The Moodle plugin then downloads the PDF from the output bucket.
The Lambda function also handles the cleanup of the input bucket and the temporary files.

## Lambda Function and LibreOffice ##
AWS Lambda functions are able to be built from [custom Docker images](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html).
This allows for the use of custom binaries and libraries that are not available in the standard Lambda environment.
This stack uses this feature to build a custom Docker image that includes a custom compiled version of LibreOffice
that is compatible with the Lambda environment.

This is an improvement over other approaches, which used a pre-built version of LibreOffice that is
added to the Lambda function as a layer.

**Note:** Custom Docker Images for Lambda have a maximum size of 10GB.

## Build and Push Image ##
Before the image can be used in the Lambda function it must be built and pushed to the AWS Elastic Container Registry (ECR).
The following commands can be used to build and push the image.

**Note:** The following commands assume that the [AWS CLI is installed and configured](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) with the appropriate permissions.

If the AWS account you're using doesn't have an ECR registry will need to create one and the link Docker to it,
so images can then be pushed to ECR.

To create the ECR repository you will need to choose a name for the repository and decide a region to create it in.
For example, to create a repository called "pdf-repo" in the "ap-southeast-2" region you would use the following command:
```bash
aws ecr create-repository --repository-name pdf-repo --region ap-southeast-2
```
Next we Authenticate your Docker client to the ECR registry.
You will need to know your AWS account ID and the region you created the repository in. This should be returned from the create repository command.
The following command will authenticate your Docker client to the ECR registry:
```bash
aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.ap-southeast-2.amazonaws.com
```
This second command should return: Login succeeded.

Now you can build the Docker image and tag it with the ECR repository URI.
First, navigate to the `lambda` directory containing the Dockerfile and run the following command to build the image:
```bash 
docker build -t libreoffice-lambda .
```

Before pushing, tag your Docker image with your ECR repository URI:
```bash
docker tag libreoffice-lambda:latest <account_id>.dkr.ecr.<region>.amazonaws.com/libreoffice-lambda:latest
```

Finally, push the image to the ECR repository:
```bash
docker push <account_id>.dkr.ecr.<region>.amazonaws.com/libreoffice-lambda:latest
```

## Deploy Stack ##


## License ##

2018 Matt Porritt <matt.porritt@moodle.com>

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.
