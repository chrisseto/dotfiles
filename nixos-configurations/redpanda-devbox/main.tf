terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  # NB: only satisfies the provider; IAM is global and everything regional sets
  # its own `region`.
  region  = "us-east-1"
  profile = var.aws_profile

  # Refuse to apply if the resolved credentials point somewhere else.
  allowed_account_ids = [var.account_id]
}

# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------

variable "aws_profile" {
  type = string
}

variable "account_id" {
  description = "Account ID to use"
  type        = string
}

variable "name" {
  description = "Name of shared resources (IAM, per-region networking)."
  type        = string
}

variable "machines" {
  description = <<-EOT
    Each machine is named `<name>-<suffix>`, or `<name>` if `suffix` is empty.
    Names must be unique per region. Removing or disabling an entry leaves the
    others alone.
    `availability_zone` defaults to <region>a. `spot` unset means on-demand.
  EOT
  type = list(object({
    suffix            = optional(string, "")
    instance_type     = string
    region            = string
    availability_zone = optional(string)
    enabled           = optional(bool, true)
    spot = optional(object({
      # Unset caps at the on-demand price.
      max_price = optional(string)
    }))
  }))

  validation {
    condition     = length(var.machines) == length(distinct([for m in var.machines : [m.region, m.suffix]]))
    error_message = "Machine suffixes must be unique per region."
  }
}

variable "tags" {
  description = "Applied to all resources."
  type        = map(string)
  default     = {}
}

# Applied to high-cost resources only
variable "cost_tags" {
  type    = map(string)
  default = {}
}

variable "nixos_release" {
  description = "Selects the AMI and the stage 1 stateVersion."
  type        = string
  default     = "26.05"
}

variable "flake_ref" {
  type = string
}

variable "ssh_user" {
  type    = string
  default = "chrisseto"
}

variable "root_volume_size_gb" {
  description = "Carries the nix store. Building 26.05 from scratch is not small."
  type        = number
  default     = 150
}

variable "home_volume_size_gb" {
  type    = number
  default = 300
}

# The contract between Terraform and NixOS. amazon-image.nix sets
# `services.udev.packages = [ pkgs.amazon-ec2-utils ]`, whose rules run
# ebsnvme-id and create a symlink at this name -- so the guest can mount
# /dev/sdf even though Nitro presents the disk as /dev/nvme1n1. No volume ID
# or filesystem label needs to leak into the flake.
#
# Verify on first boot: `ls -l /dev/sd* /dev/xvd*`. AWS's rules sometimes yield
# xvdf rather than sdf; pin whichever actually appears.
variable "home_device_name" {
  type    = string
  default = "/dev/sdf"
}

locals {
  machines = {
    for m in var.machines : "${m.region}/${join("-", compact([var.name, m.suffix]))}" => merge(m, {
      name = join("-", compact([var.name, m.suffix]))
      az   = coalesce(m.availability_zone, "${m.region}a")
    }) if m.enabled
  }

  # Networking only exists where an enabled machine needs it.
  regions = toset([for m in local.machines : m.region])
  subnets = { for m in local.machines : m.az => m.region... }

  tags      = merge(var.tags, { Name = var.name })
  cost_tags = merge(local.tags, var.cost_tags)
}

# ---------------------------------------------------------------------------
# Lookups
# ---------------------------------------------------------------------------

data "aws_ec2_instance_type" "devbox" {
  for_each = local.machines

  region        = each.value.region
  instance_type = each.value.instance_type
}

data "aws_ami" "nixos" {
  for_each = local.machines

  region      = each.value.region
  owners      = ["427812963091"]
  most_recent = true

  filter {
    name   = "name"
    values = ["nixos/${var.nixos_release}*"]
  }

  filter {
    name = "architecture"
    # NB: older x86 types also list i386, so `one()` won't do.
    values = [contains(data.aws_ec2_instance_type.devbox[each.key].supported_architectures, "arm64") ? "arm64" : "x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ---------------------------------------------------------------------------
# Access
# ---------------------------------------------------------------------------

resource "aws_security_group" "devbox" {
  for_each = local.regions

  region      = each.key
  name        = var.name
  description = "SSH in from trusted CIDRs, all egress"
  vpc_id      = aws_vpc.devbox[each.key].id

  # Everything comes in over SSM, which the agent dials out to establish.
  # Satisfies IMS-POL-011 Section 4.10 by having no allow rule at all rather
  # than an explicit one.
  #
  # NB: must be an explicit empty list, not an omitted block. `ingress` is
  # Optional+Computed, so dropping the block means "leave the live rules alone"
  # and silently plans no change.
  ingress = []

  # NB: `description` above is stale. It is immutable in the AWS API, so
  # changing it forces a replacement of the group -- which fails while the
  # instance references it, given the explicit `name`. Fixing it needs
  # `name_prefix` + `create_before_destroy`.

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

# ---------------------------------------------------------------------------
# SSM
# ---------------------------------------------------------------------------
#
# The only way in -- the security group has no ingress. The agent is enabled
# guest-side by the flake (`services.ssm-agent.enable`); this supplies the
# credentials it needs to register. Losing the instance profile locks you out,
# so the box has to be reachable here before this apply lands.
#
# No VPC endpoints: the box has a public IP and all-egress, so the agent reaches
# the SSM endpoints over the IGW for free.

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "devbox" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = local.tags
}

# AWS-managed. Grants exactly the ssm/ssmmessages/ec2messages calls the agent
# makes, nothing else.
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.devbox.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "devbox" {
  name = var.name
  role = aws_iam_role.devbox.name

  tags = local.tags
}

# ---------------------------------------------------------------------------
# Persistent /home
# ---------------------------------------------------------------------------

resource "aws_ebs_volume" "home" {
  for_each = local.machines

  region            = each.value.region
  availability_zone = each.value.az
  size              = var.home_volume_size_gb
  type              = "gp3"
  encrypted         = true

  tags = merge(local.cost_tags, { Name = "${each.value.name}-home" })

  # Survives `terraform destroy`. Remove this block if you want it gone.
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_volume_attachment" "home" {
  for_each = local.machines

  region      = each.value.region
  device_name = var.home_device_name
  volume_id   = aws_ebs_volume.home[each.key].id
  instance_id = aws_instance.devbox[each.key].id
}

# ---------------------------------------------------------------------------
# Bootstrap script, delivered as user-data
# ---------------------------------------------------------------------------
#
# Must start with `#!` or amazon-init treats it as a NixOS module instead. The
# shebang is only a sentinel: amazon-init execs this via pkgs.runtimeShell and
# ignores the interpreter you name.
#
# This script only *queues* the rebuilds. Running them inline does not work:
# amazon-init.service is a `Type=oneshot` unit and systemd terminated the first
# boot 10s into activation, after a 3m16s build ("start operation timed out").
# The unit sets no TimeoutStartSec and we do not own it, so the work is handed
# to a transient unit that PID 1 owns instead, where no start-job clock applies
# and amazon-init returns immediately.
#
# Two stages, because there is no inbound access at all: stage 1 brings up the
# SSM agent from the AMI's own channel, so a stage 2 that fails to build or
# evaluate still leaves a way in. Stage 2 is the real switch and is what
# retires amazon-init.
#
# --flake takes a flake reference, not a path, so nothing is cloned here --
# nix fetches the repo into the store itself. Seeding an editable ~/.nixpkgs is
# the flake's job, via a systemd unit, where it belongs.
#
# Follow along with `journalctl -u devbox-bootstrap -f`; flakes are off in the
# AMI's nix.conf, so they are enabled for the one call that needs them.

locals {
  bootstrap = <<-BOOTSTRAP
    #!/usr/bin/env bash
    set -euo pipefail

    install -d /etc/nixos
    cat > /etc/nixos/stage1.nix <<'STAGE1'
    { modulesPath, ... }:
    {
      imports = [ "$${modulesPath}/virtualisation/amazon-image.nix" ];
      services.amazon-ssm-agent.enable = true;

      # Throwaway generation; the manual is the slowest thing in it.
      documentation.enable = false;

      system.stateVersion = "${var.nixos_release}";
    }
    STAGE1

    # PATH and HOME are amazon-init's; a transient unit inherits PID 1's
    # environment, not this shell's, and that PATH is where nixos-rebuild and
    # the right nix live. NIX_PATH mirrors what amazon-init sets so stage 1 can
    # resolve <nixpkgs/nixos> from the AMI's channel.
    # amazon-init re-runs user-data on every boot until stage 2 retires it, and
    # a lingering failed unit would make --unit collide.
    systemctl reset-failed devbox-bootstrap.service 2>/dev/null || true

    systemd-run \
      --unit=devbox-bootstrap \
      --no-block \
      --property=Type=oneshot \
      --property=TimeoutStartSec=infinity \
      --setenv=HOME=/root \
      --setenv=PATH="$PATH" \
      --setenv=NIX_PATH=nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:/nix/var/nix/profiles/per-user/root/channels \
      /bin/sh -xc '
        # Non-fatal: if this fails, stage 2 is the only way to a working box.
        nixos-rebuild switch -I nixos-config=/etc/nixos/stage1.nix \
          || echo "stage 1 failed, continuing to stage 2"

        exec nixos-rebuild switch \
          --refresh \
          --option experimental-features "nix-command flakes" \
          --flake ${var.flake_ref}
      '
  BOOTSTRAP
}

# ---------------------------------------------------------------------------
# Instance
# ---------------------------------------------------------------------------

resource "aws_vpc" "devbox" {
  for_each = local.regions

  region     = each.key
  cidr_block = "172.16.0.0/24"

  tags = local.tags
}

resource "aws_subnet" "devbox" {
  for_each = local.subnets

  region = each.value[0]
  vpc_id = aws_vpc.devbox[each.value[0]].id
  # NB: indexed by AZ letter so adding an AZ never renumbers existing subnets.
  cidr_block        = cidrsubnet("172.16.0.0/24", 4, index(["a", "b", "c", "d", "e", "f"], substr(each.key, -1, 1)))
  availability_zone = each.key

  tags = local.tags
}

resource "aws_internet_gateway" "devbox" {
  for_each = local.regions

  region = each.key
  vpc_id = aws_vpc.devbox[each.key].id

  tags = local.tags
}

# A new VPC's main route table carries only the local CIDR route. Adding the
# default route here rather than to a separate table means every subnet in the
# VPC picks it up without an explicit association.
resource "aws_default_route_table" "devbox" {
  for_each = local.regions

  region                 = each.key
  default_route_table_id = aws_vpc.devbox[each.key].main_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devbox[each.key].id
  }

  tags = local.tags
}

resource "aws_instance" "devbox" {
  for_each = local.machines

  region            = each.value.region
  ami               = data.aws_ami.nixos[each.key].id
  instance_type     = each.value.instance_type
  subnet_id         = aws_subnet.devbox[each.value.az].id
  availability_zone = each.value.az

  iam_instance_profile = aws_iam_instance_profile.devbox.name

  vpc_security_group_ids      = [aws_security_group.devbox[each.value.region].id]
  associate_public_ip_address = true

  # Stop, don't terminate, on an in-guest `shutdown`.
  # instance_initiated_shutdown_behavior = "stop"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
    encrypted   = true

    # Billed separately from the instance, so it carries the tag too.
    tags = merge(local.cost_tags, { Name = each.value.name })
  }

  user_data = local.bootstrap

  # Editing the script must not silently replace a box you have work on. Note
  # that once devbox.nix has retired amazon-init, edits here have no effect on
  # a running instance anyway -- the flake owns the config from then on.
  user_data_replace_on_change = false

  tags = merge(local.cost_tags, { Name = each.value.name })

  lifecycle {
    # Don't roll the box just because a newer NixOS AMI shipped.
    ignore_changes = [ami]
  }

  dynamic "instance_market_options" {
    for_each = each.value.spot == null ? [] : [each.value.spot]

    content {
      market_type = "spot"

      spot_options {
        max_price                      = instance_market_options.value.max_price
        spot_instance_type             = "persistent"
        instance_interruption_behavior = "stop"
      }
    }
  }
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

# Tunnels sshd over SSM, so -L and -A keep working with no inbound rule. Needs
# session-manager-plugin on the client.
output "machines" {
  value = {
    for k, m in local.machines : k => {
      name        = m.name
      region      = m.region
      az          = m.az
      ami_id      = data.aws_ami.nixos[k].id
      ami_name    = data.aws_ami.nixos[k].name
      instance_id = aws_instance.devbox[k].id
      public_ip   = aws_instance.devbox[k].public_ip
      ssm         = "aws ssm start-session --profile ${var.aws_profile} --region ${m.region} --target ${aws_instance.devbox[k].id}"
      ssh_ssm     = "ssh -o ProxyCommand='aws ssm start-session --profile ${var.aws_profile} --region ${m.region} --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p' ${var.ssh_user}@${aws_instance.devbox[k].id}"
    }
  }
}

locals {
  ssh_config = join("\n", [
    for k, m in local.machines : <<-EOT
      Host ${join(".", compact(["devbox", m.region, m.suffix]))}
      	User ${var.ssh_user}
      	HostName ${aws_instance.devbox[k].id}
      	ProxyCommand aws ssm start-session --profile ${var.aws_profile} --region ${m.region} --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p
    EOT
  ])
}

# Requires `Include ~/.ssh/config_devbox` at the top of ~/.ssh/config.
resource "terraform_data" "ssh_config" {
  triggers_replace = local.ssh_config

  provisioner "local-exec" {
    command = "printf '%s' \"$SSH_CONFIG\" > ~/.ssh/config_devbox"

    environment = {
      SSH_CONFIG = local.ssh_config
    }
  }
}

output "ssh_config" {
  value = local.ssh_config
}
