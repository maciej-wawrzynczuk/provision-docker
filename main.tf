# modules:
# use git::git@github.com:maciej-wawrzynczuk/terraform-lib.git//ssh-key?ref=v1
# for stable or
# ../terrafrom-lib/ (or wherever you clone it)
# for devel

variable project {}
variable region {}

provider "aws" {
  region = "${var.region}"
}

module "key" {
  source = "git::git@github.com:maciej-wawrzynczuk/terraform-lib.git//ssh-key?ref=v1"
  project = "${var.project}"
}

module "vpc" {
  source = "git::git@github.com:maciej-wawrzynczuk/terraform-lib.git//vpc?ref=v1"
  project = "${var.project}"
}

module "xenial" {
  source = "git::git@github.com:maciej-wawrzynczuk/terraform-lib.git//xenial?ref=v1"
}

module "host" {
  source = "git::git@github.com:maciej-wawrzynczuk/terraform-lib.git//host?ref=v1"
  ami_id = "${module.xenial.id}"
  project = "${var.project}"
  subnet_id = "${module.vpc.subnet_id}"
  key_name = "${module.key.name}"
  number = 1
  tcp_ports = ["22"]
}

module "dns" {
  source = "git::git@github.com:maciej-wawrzynczuk/terraform-lib.git//dns?ref=v1"
  domain = "lamamind.com."
  hostnames = ["docker"]
  addresses = "${module.host.ips}"
  addresses6 = "${module.host.ips6}"
}

module "provision" {
  source = "git::git@github.com:maciej-wawrzynczuk/terraform-lib.git//provision?ref=v1"
  #  trigger = "${timestamp()}"
  trigger = "${join("," , module.host.ids)}"
  hosts = "${module.host.ips}"
  playbook = "docker.yml"
}
