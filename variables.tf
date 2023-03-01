variable "aws_profile" {
  type    = string
  default = "default"
}

variable "on-permise_ip"{
	default="ec2-100-25-222-234.compute-1.amazonaws.com"
}

variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
    default = "us-east-1"
}

variable "AWS_AMIS" {
    type = map(string)
    default = {
        "us-east-1" = "ami-0557a15b87f6559cf"
        "us-east-2" = "ami-00eeedc4036573771"
    }
}

variable "password" {
  description = "password to set for both databases - source & target, ideally should be fetched via Vault"
  type        = string
  default     = "Cbi_12345"
  sensitive   = true
}

variable "external_ip" {
  description = "The IP which we want to allow to access the simulated source MySQL hosted on EC2"
  type        = string
  validation {
    condition     = can(var.external_ip) && can(regex("[^0.0.0.0/0]", var.external_ip))
    error_message = "External IP should not be 0.0.0.0/0. Please change or set the default external_ip variable in variables.tf to your public IP - or do something like 'terraform plan|apply -var external_ip=$(curl -s ifconfig.me)/32'."
  }

}

variable "private-key-file" {
  description = "Path to SSH private key file. Override the default path if at a custom location OR if it doesn't exist use 'ssh-keygen -t rsa' to generate it"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
