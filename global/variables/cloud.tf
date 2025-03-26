provider "aws" {
        shared_config_files      = ["$HOME/.aws/config"]
        shared_credentials_files = ["$HOME/.aws/credentials"]
        alias  = "Infrastructure"
        profile  = "Infrastructure"
        }

provider "aws" {
        shared_config_files      = ["$HOME/.aws/config"]
        shared_credentials_files = ["$HOME/.aws/credentials"]
        alias  = "Domain"
        profile  = "Domain"
        }
