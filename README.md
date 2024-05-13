# generate-debian-preseed-iso

This Bash script generates Debian ISOs with preseed for multiple environments. With this script, you can automate the process of generating custom Debian images with preconfigured settings for various environments.

## Requirements

To use this script, you need to install the following packages:

    $ sudo apt install wget curl p7zip-full genisoimage syslinux-utils

## Usage

To use this script, follow these steps:
1. Clone this repository using Git:

       $ git clone https://github.com/bergmann-max/debain-preseed-iso-generator.git

1.  Navigate to the cloned directory:

        $ cd debain-pressed-iso-generator

1. Put your <code>preseed.cfg</code> files in the <code>DMZ</code> and <code>INSIDE</code> directories.
1. Make the script executable:

       $ chmod +x debian-preseed-iso-generator.sh

1. Run the script:

       $ ./debian-preseed-iso-generator.sh

1. After the script has finished running, you will find the generated ISO images in the <code>DMZ</code> and <code>ISNIDE</code> directories, respectively. These ISOs contain the preconfigured settings specified in the <code>preseed.cfg</code> files.

That's it! Now you can use the generated ISOs to install Debian on multiple machines with the same preconfigured settings.
