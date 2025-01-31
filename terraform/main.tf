terraform {
  required_providers {
    octopusdeploy = {
      source  = "OctopusDeployLabs/octopusdeploy"
    }
  }
}

provider "octopusdeploy" {
  address   = var.serverURL
  api_key   = var.apiKey
  space_id  = var.spaceId
}

resource "octopusdeploy_git_credential" "BuildInfoDemo" {
    name        = var.gitCredsName
    username    = var.gitCredsUsername
    password    = var.gitCredsToken
}

resource "octopusdeploy_environment" "DevEnvironment" {
    name = var.devEnvironmentName

    jira_extension_settings {
        environment_type = var.devEnvironmentJiraEnvironmentType
    }
}

resource "octopusdeploy_environment" "TestEnvironment" {
    name = var.testEnvironmentName

    jira_extension_settings {
        environment_type = var.testEnvironmentJiraEnvironmentType
    }
}

resource "octopusdeploy_environment" "ProdEnvironment" {
    name = var.prodEnvironmentName

    jira_extension_settings {
        environment_type = var.prodEnvironmentJiraEnvironmentType
    }
}

resource "octopusdeploy_lifecycle" "BuildInfoDemo" {
    name = var.buildInfoLifecycleName
    
    release_retention_policy {
        quantity_to_keep    = var.buildInfoLifecycleRetentionPolicyQuantityToKeep
        unit                = var.buildInfoLifecycleRetentionPolicyUnit
    }

    phase {
      name = octopusdeploy_environment.DevEnvironment.name
      automatic_deployment_targets = [octopusdeploy_environment.DevEnvironment.id]
    }

    phase {
      name = octopusdeploy_environment.TestEnvironment.name
      optional_deployment_targets           = [octopusdeploy_environment.TestEnvironment.id]
      is_optional_phase = true
    }

    phase {
      name = octopusdeploy_environment.ProdEnvironment.name
      optional_deployment_targets           = [octopusdeploy_environment.ProdEnvironment.id]
    }

    depends_on = [octopusdeploy_environment.DevEnvironment, octopusdeploy_environment.TestEnvironment, octopusdeploy_environment.ProdEnvironment]
}

resource "octopusdeploy_lifecycle" "BuildInfoDemoPreRelease" {
    name = var.buildInfoLifecyclePreReleaseName
    
    release_retention_policy {
        quantity_to_keep    = var.buildInfoLifecycleRetentionPolicyQuantityToKeep
        unit                = var.buildInfoLifecycleRetentionPolicyUnit
    }

    phase {
      name = octopusdeploy_environment.DevEnvironment.name
      automatic_deployment_targets = [octopusdeploy_environment.DevEnvironment.id]
    }

    phase {
      name = octopusdeploy_environment.TestEnvironment.name
      optional_deployment_targets           = [octopusdeploy_environment.TestEnvironment.id]
      is_optional_phase = true
    }

    depends_on = [octopusdeploy_environment.DevEnvironment, octopusdeploy_environment.TestEnvironment]
}

resource "octopusdeploy_project_group" "BuildInfoDemo" {
    name = var.buildInfoProjectGroupName
}

resource "octopusdeploy_project" "BuildInfoDemo" {
    name                    = var.buildInfoProjectName
    project_group_id        = octopusdeploy_project_group.BuildInfoDemo.id
    lifecycle_id            = octopusdeploy_lifecycle.BuildInfoDemo.id

    git_library_persistence_settings {
        default_branch      = var.buildInfoProjectGitSettingsBranch
        git_credential_id   = octopusdeploy_git_credential.BuildInfoDemo.id
        url                 = var.buildInfoProjectGitSettingsUrl
        base_path           = var.buildInfoProjectGitSettingsBasePath
    }

    depends_on              = [octopusdeploy_project_group.BuildInfoDemo, octopusdeploy_git_credential.BuildInfoDemo, octopusdeploy_lifecycle.BuildInfoDemo]
}

resource "octopusdeploy_channel" "BuildInfoDemoDefaultChannel" {
  name = "Default"
  is_default = true
  project_id = octopusdeploy_project.BuildInfoDemo.id
  rule {
    action_package {
      deployment_action = "Deploy an Azure App Service"
    }
    tag = "^$"
  }

  depends_on = [ octopusdeploy_project.BuildInfoDemo ]
}

resource "octopusdeploy_channel" "BuildInfoDemoPreReleaseChannel" {
  name = "PreRelease"
  project_id = octopusdeploy_project.BuildInfoDemo.id
  lifecycle_id = octopusdeploy_lifecycle.BuildInfoDemoPreRelease.id
  rule {
    action_package {
      deployment_action = "Deploy an Azure App Service"
    }
    tag = "^[^\\+].*"
  }

  depends_on = [ octopusdeploy_project.BuildInfoDemo, octopusdeploy_lifecycle.BuildInfoDemoPreRelease ]
}

resource "octopusdeploy_project" "BuildInfoDemo2" {
    name                    = var.buildInfoProject2Name
    project_group_id        = octopusdeploy_project_group.BuildInfoDemo.id
    lifecycle_id            = octopusdeploy_lifecycle.BuildInfoDemo.id

    git_library_persistence_settings {
        default_branch      = var.buildInfoProjectGitSettingsBranch
        git_credential_id   = octopusdeploy_git_credential.BuildInfoDemo.id
        url                 = var.buildInfoProjectGitSettingsUrl
        base_path           = var.buildInfoProject2GitSettingsBasePath
    }

    depends_on              = [octopusdeploy_project_group.BuildInfoDemo, octopusdeploy_git_credential.BuildInfoDemo, octopusdeploy_lifecycle.BuildInfoDemo]
}

resource "octopusdeploy_channel" "BuildInfoDemo2DefaultChannel" {
  name = "Default"
  is_default = true
  project_id = octopusdeploy_project.BuildInfoDemo2.id
  rule {
    action_package {
      deployment_action = "Deploy an Azure App Service"
    }
    tag = "^$"
  }

  depends_on = [ octopusdeploy_project.BuildInfoDemo2 ]
}

resource "octopusdeploy_channel" "BuildInfoDemo2PreReleaseChannel" {
  name = "PreRelease"
  project_id = octopusdeploy_project.BuildInfoDemo2.id
  lifecycle_id = octopusdeploy_lifecycle.BuildInfoDemoPreRelease.id
  rule {
    action_package {
      deployment_action = "Deploy an Azure App Service"
    }
    tag = "^[^\\+].*"
  }

  depends_on = [ octopusdeploy_project.BuildInfoDemo2, octopusdeploy_lifecycle.BuildInfoDemoPreRelease ]
}

resource "octopusdeploy_project" "BuildInfoDemoTenanted" {
    name = var.buildInfoProjectTenantedName
    project_group_id = octopusdeploy_project_group.BuildInfoDemo.id
    lifecycle_id = octopusdeploy_lifecycle.BuildInfoDemo.id
    tenanted_deployment_participation = "Tenanted"

    git_library_persistence_settings {
        default_branch = var.buildInfoProjectGitSettingsBranch
        git_credential_id = octopusdeploy_git_credential.BuildInfoDemo.id
        url = var.buildInfoProjectGitSettingsUrl
        base_path = var.buildInfoProjectTenantedGitSettingsBasePath
    }

    depends_on = [ octopusdeploy_project_group.BuildInfoDemo, octopusdeploy_git_credential.BuildInfoDemo, octopusdeploy_lifecycle.BuildInfoDemo ]
}

resource "octopusdeploy_channel" "BuildInfoDemoTenantedDefaultChannel" {
  name = "Default"
  is_default = true
  project_id = octopusdeploy_project.BuildInfoDemoTenanted.id
  rule {
    action_package {
      deployment_action = "Deploy an Azure App Service"
    }
    tag = "^$"
  }

  depends_on = [ octopusdeploy_project.BuildInfoDemoTenanted ]
}

resource "octopusdeploy_channel" "BuildInfoDemoTenantedPreReleaseChannel" {
  name = "PreRelease"
  project_id = octopusdeploy_project.BuildInfoDemoTenanted.id
  lifecycle_id = octopusdeploy_lifecycle.BuildInfoDemoPreRelease.id
  rule {
    action_package {
      deployment_action = "Deploy an Azure App Service"
    }
    tag = "^[^\\+].*"
  }

  depends_on = [ octopusdeploy_project.BuildInfoDemoTenanted, octopusdeploy_lifecycle.BuildInfoDemoPreRelease ]
}

resource "octopusdeploy_project" "BuildInfoDemoTenanted2" {
    name = var.buildInfoProjectTenanted2Name
    project_group_id = octopusdeploy_project_group.BuildInfoDemo.id
    lifecycle_id = octopusdeploy_lifecycle.BuildInfoDemo.id
    tenanted_deployment_participation = "Tenanted"
    discrete_channel_release = true

    git_library_persistence_settings {
        default_branch = var.buildInfoProjectGitSettingsBranch
        git_credential_id = octopusdeploy_git_credential.BuildInfoDemo.id
        url = var.buildInfoProjectGitSettingsUrl
        base_path = var.buildInfoProjectTenanted2GitSettingsBasePath
    }

    depends_on = [ octopusdeploy_project_group.BuildInfoDemo, octopusdeploy_git_credential.BuildInfoDemo, octopusdeploy_lifecycle.BuildInfoDemo, octopusdeploy_project.BuildInfoDemoTenanted ]
}

resource "octopusdeploy_channel" "BuildInfoDemoTenanted2DefaultChannel" {
  name = "Default"
  is_default = true
  project_id = octopusdeploy_project.BuildInfoDemoTenanted2.id
  rule {
    action_package {
      deployment_action = "Deploy an Azure App Service"
    }
    tag = "^$"
  }

  depends_on = [ octopusdeploy_project.BuildInfoDemoTenanted2 ]
}

resource "octopusdeploy_channel" "BuildInfoDemoTenanted2PreReleaseChannel" {
  name = "PreRelease"
  project_id = octopusdeploy_project.BuildInfoDemoTenanted2.id
  lifecycle_id = octopusdeploy_lifecycle.BuildInfoDemoPreRelease.id
  rule {
    action_package {
      deployment_action = "Deploy an Azure App Service"
    }
    tag = "^[^\\+].*"
  }

  depends_on = [ octopusdeploy_project.BuildInfoDemoTenanted2, octopusdeploy_lifecycle.BuildInfoDemoPreRelease ]
}

resource "octopusdeploy_tenant" "BuildInfoDemoTenantA" {
    name = var.buildInfoTenantAName
    project_environment {
      environments = [octopusdeploy_environment.DevEnvironment.id, octopusdeploy_environment.TestEnvironment.id, octopusdeploy_environment.ProdEnvironment.id ]
      project_id = octopusdeploy_project.BuildInfoDemoTenanted.id
    }

    depends_on = [ octopusdeploy_project.BuildInfoDemoTenanted, octopusdeploy_environment.DevEnvironment, octopusdeploy_environment.TestEnvironment, octopusdeploy_environment.ProdEnvironment ]
}

resource "octopusdeploy_tenant" "BuildInfoDemoTenantB" {  
    name = var.buildInfoTenantBName

    project_environment {
      environments = [octopusdeploy_environment.DevEnvironment.id, octopusdeploy_environment.TestEnvironment.id, octopusdeploy_environment.ProdEnvironment.id]
      project_id = octopusdeploy_project.BuildInfoDemoTenanted2.id
    }

    depends_on = [ octopusdeploy_project.BuildInfoDemoTenanted2, octopusdeploy_environment.DevEnvironment, octopusdeploy_environment.TestEnvironment, octopusdeploy_environment.ProdEnvironment ]
}