variable "region" {
  type        = string
  description = "Defines to which organisation the sub account shall belong to."
  default     = "us10"
}

variable "subaccount_name" {
  type        = string
  description = "Defines the name of the sub account."
  default     = "Demo CAP app"
}

variable "app_admins" {
  type        = list(string)
  description = "Defines the administrators for the sub account and app."
  default     = ["rui.nogueira@sap.com","jeremias.roessler@sap.com"]
}

variable "repo_name" {
  type        = string
  description = "Defines the GitHub repository name for the sub account"
  default     = "temp"
}
