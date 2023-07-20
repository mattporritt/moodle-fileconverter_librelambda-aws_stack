# AWS Stack for Libre Lambda Document Converter #

This is the Amazon Web Services (AWS) stack infrastructure for the Libre Officefile converter plugin for the Moodle (https://github.com/catalyst/moodle-fileconverter_librelambda). The primary function of this plugin is to convert student submissions into the PDF file format, to allow teachers to use the annotate PDF functionality of Moodle.

This contains binaries and scripts necessary for AWS services to provide the conversion to PDF, the primary AWS services used are [Lambda](https://aws.amazon.com/lambda/) and [S3](https://aws.amazon.com/s3/). The root of this repository is given to the plugin `provision.php` script.

## Libre Office Archive and Compliation
This plugin includes precompiled LibreOffice archives as a compressed archive in the */libre* folder of this repository. The archive is uploaded to AWS as part of the provisioning process. Lambda uses the uncompressed binaries to do the actual conversion of the uploaded documents to PDF.

The precompiled binary archive for LibreOffice is provided as a convienence to make setting everything up easier. However, you can obtain the LibreOffice source code and compile it yourself. See the section: *Compiling Libre Office* for instructions on how to do this.

### Compiling Libre Office
This section will outline how to compile LibreOffice for yourself to be used by AWS Lambda to convert files.

There are two main reasons why we need to custom compile LibreOffice to work with AWS Lambda. The first is we need to compile LibreOffice so it works in the same runtime environment as Lambda. The second is that Lambda has very limited disk space (512MB) which we can use to store and execute binaries. So we need to create a very minimal version of LibreOffice to stay under the disk space limits.

Knowledge of Docker as well as command line Linux administration is required to compile your own LibreOffice installation.

The process to create your own compiled LibreOffice binary archive is:
* Get the LibreOffice code from the LibreOffice project
* Compile LibreOffice binaries in a container based on one used for AWS Lambda
* Create the LibreOffice archive

Following steps are done in the `librelambda/build` directory.

#### Get the LibreOffice code from the LibreOffice project

    wget https://download.documentfoundation.org/libreoffice/src/6.4.7/libreoffice-6.4.7.2.tar.xz

This is the latest version in the 6 family at the time of writing. Amazon 2 image is based on Centos 7,
which proved challenging enough to make us not even consider trying with LibreOffice 7.

In (unlikely) case that another minor version is requested, `docker build` observes `lo_ver` env var, eg
    lo_ver=6.4.7.5 docker build ...

#### Compile LibreOffice binaries
Build the image and launch a container. Depending on your circumnstances/preferences you may use
slightly different arguments with `docker` commands:

    docker build -t lo-build .
    # OR for arm64/aarch64 (graviton):
    docker build -t lo-build --build-arg ARCH=aarch64 .
    docker run -it --rm lo-build bash

This should give you a shell in a running container. In the container shell:

    make
    # OR for arm64/aarch64 (graviton):
  :w  CPPFLAGS="-DPNG_ARM_NEON_OPT=0" make
    strip instdir/program/*

Once the binaries are compiled (and stripped) you can run the following commands (still in the container shell)
to test the conversion. You will probably get a fontconfig warning, ignore:

    echo "hello world" > /tmp/a.txt
    ./instdir/program/soffice.bin --headless --invisible --nodefault --nofirststartwizard \
        --nolockcheck --nologo --norestore --convert-to pdf --outdir /tmp /tmp/a.txt
    ls -l /tmp/a.pdf

**Note:** For some reason conversion may silently do nothing. In that case just re-run it.

If everything seems fine, pack it up:

    tar -cf /lo.tar instdir

Now you have lo.tar in the running container. Do not exit it yet. In another terminal on your computer:

    docker ps
    docker cp <container id>:/lo.tar .
`docker ps` should give you the id of the `lo-build` running container that you will use for copying.

After checking that you have `lo.tar` you can leave the container.

**NOTE:** Compiling LibreOffice will take time.

**If something goes wrong:**

    docker run -it --rm --cap-add=SYS_PTRACE --security-opt seccomp=unconfined lo-build bash

If you are rebuilding the `lo-build` image, you can copy tarballs from the running container's
`<build dir>/external/tarballs/` to the `tarballs` directory. That will save you downloading each time you start new container.

After the above steps are completed follow the instructions in the next section, to create the LibreOffice archive.

#### Create the LibreOffice archive
Now is time to remove unneeded things from lo.tar if you wish
(share/gallery,template,fonts/truetype/EmojiOneColor-SVGinOT.ttf...). Either untar/remove/tar back, or

    tar -f lo.tar --delete xyz...

Once you are happy with the content of `lo.tar`:

    xz -e9 lo.tar

And replace the existing `lo.tar.xz`:

    mv lo.tar.xz ..

Next time you run the provisioning script to setup the environment it will use the newly created LibreLambda archive for Lambda.

## Lambda Function
TODO: this

## License ##

2018 Matt Porritt <mattp@catalyst-au.net>

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.
