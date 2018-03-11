# Digital Ocean Terraform Example

## Warning

Running this will spin up instances at DigitalOcean that you will be charged for.
When you are done run `terraform destroy` to tear everything back down.

## Usage
First set the environment variable with your DigitalOcean token.

`export TF_VAR_do_token="Your Token Here"`

**IMPORTANT**: Notice the `TF_VAR_` at the beginning. Terraform is goofy in that
it doesn't accept environment variables without that prefix.

Next generate yourself a new SSH key to use with your new droplets.

`ssh-keygen -t rsa -b 2048 -f terraform-key -N ''`

With that done, terraform needs to be initialized in this directory.

`terraform init`

Finally, you're ready to deploy.

`terraform apply`

You will see a bunch of text scroll by before you are prompted to tell it to
continue. If you type anything other than 'yes', it will exit out.

When it drops you back to your command line head over to your DigitalOcean
account and see the results.

## Do You Want To Know More?

The `do-example.tf` file is fairly self-explanatory.  However, I may add more
detail here in the future.

### Additional Reading
* [Official Docs](https://www.terraform.io/)
* [DigitalOcean Provider Docs](https://www.terraform.io/docs/providers/do/index.html)
