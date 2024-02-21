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
