// define variables here

variable "instance_type" {
  type    = string
  default = "t3a.micro" // nano might be too small for demo
}

variable "key_name" {
  type    = string
  default = "default-key" // HINT: replace the key name here or pass it with -var/-var-file
}

variable "volume_size" {
  type    = number
  default = 30
}

variable "volume_type" {
  type    = string
  default = "gp3"
}
