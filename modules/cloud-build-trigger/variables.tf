variable "project" {
  type        = string
  description = "The project ID to create the cloud build trigger"
}
variable "disabled" {
  type = bool
  description = "cloud build trigger will be enabled"
}
variable "name" {
 type =  string
 default = "Cloud build trigger name"
}
variable "path" {
  type = string
}

variable "owner" {
 type = string 
}
variable "github_reponame" {
  
}
variable "branch" {
  
}
variable "invert_regex" {
  
}
variable "service_account" {
  type = string
  description = "service account for cloud build trigger"
}
# variable "substitutions" {
#   type = object({
#     _TFACTION = string
#   })
#   description = "substitutions variable for cloud build"
#     default = {
#     _TFACTION = "apply"
#   }
# }
variable "_TFACTION" {
  
}