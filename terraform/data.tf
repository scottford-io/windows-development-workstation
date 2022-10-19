////////////////////////////////
// Instance Data

# data "aws_ami" "win19_dev_workstation" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["win19-dev-workstation-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["177043759486"]
# }

data "aws_ami" "win2022_dev_workstation" {
  most_recent = true

  filter {
    name   = "name"
    values = ["windows2022-dev-workstation-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["177043759486"]
}
