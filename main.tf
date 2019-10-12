# modules:
# use git::git@github.com:maciej-wawrzynczuk/terraform-lib.git//
# for stable or
# ../terrafrom-lib/ (or wherever you clone it)
# for devel

variable project {}
variable region {}

provider "aws" {
  region = "${var.region}"
}

module "key" {
  source = "../terraform-lib/ssh-key"
  project = "${var.project}"
}

module "vpc" {
  source = "../terraform-lib/vpc"
  project = "${var.project}"
}

module "xenial" {
  source = "../terraform-lib/xenial"
}

module "host" {
  source = "../terraform-lib/host"
  ami_id = "${module.xenial.id}"
  project = "${var.project}"
  subnet_id = "${module.vpc.subnet_id}"
  key_name = "${module.key.name}"
  number = 1
  tcp_ports = ["22"]
}

module "dns" {
  source = "../terraform-lib/dns"
  domain = "lamamind.com."
  hostnames = ["docker"]
  addresses = "${module.host.ips}"
  addresses6 = "${module.host.ips6}"
}

module "provision" {
  source = "../terraform-lib/provision"
  hosts = "${module.host.ips}"
  playbook = "docker.yml"
}
