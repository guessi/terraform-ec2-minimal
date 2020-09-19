// define variables here

variable "instance_type" {
  type    = string
  default = "t3.nano"
}

variable "key_name" {
  type    = string
  default = "default-key" // FIXME: replace the key name here
}
