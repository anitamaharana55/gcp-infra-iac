resource "google_secret_manager_secret" "github-token-secret" {
  secret_id = "github-token-secret"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "github-token-secret-version" {
  secret = google_secret_manager_secret.github-token-secret.id
  secret_data = file("my-github-token.txt")
}

data "google_iam_policy" "p4sa-secretAccessor" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    // Here, 123456789 is the Google Cloud project number for the project that contains the connection.
    members = ["serviceAccount:service-123456789@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
  }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  secret_id = google_secret_manager_secret.github-token-secret.secret_id
  policy_data = data.google_iam_policy.p4sa-secretAccessor.policy_data
}

resource "google_cloudbuildv2_connection" "my-connection" {
  location = "us-central1"
  name = "my-connection"

  github_config {
    app_installation_id = 123123
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github-token-secret-version.id
    }
  }
}

resource "google_cloudbuildv2_repository" "my-repository" {
  location = "us-central1"
  name = "my-repo"
  parent_connection = google_cloudbuildv2_connection.my-connection.name
  remote_uri = "https://github.com/myuser/myrepo.git"
}


resource "google_cloudbuild_trigger" "trigger" {
  name = var.name
  location = "us-central1"
  project  = var.project
  disabled = var.disabled
  source_to_build {
    repo_type = "GITHUB"
    ref = "refs/heads/main"
    uri       = "https://github.com/UmeshBuraWissen/gcp-infra-iac.git"
  }
  github {
    owner = var.owner
    name  = var.github_reponame
    push {
      branch       = var.branch
      invert_regex = var.invert_regex
    }
  }
  # dynamic "substitutions" {
  #   for_each = var.substitutions 
  #     content {
  #       _TFACTION = substitutions.value["_TFACTION"]
  #     }
  # }
  substitutions = {
    _TFACTION = var._TFACTION
  }

  # git_file_source {
  #   path      = "devops/infra_cloudbuild.yaml"
  #   uri       = "https://github.com/UmeshBuraWissen/gcp-infra-iac.git"
  #   revision  = "refs/heads/main"
  #   repo_type = "GITHUB"
  # }


  service_account = "projects/${var.project}/serviceAccounts/${var.service_account}"
  filename = var.path
}
