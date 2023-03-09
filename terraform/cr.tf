resource "alicloud_cr_namespace" "my-namespace" {
  name               = var.namespace
  auto_create        = false
  default_visibility = "PUBLIC"
}

resource "alicloud_cr_repo" "my-repo" {
  namespace = alicloud_cr_namespace.my-namespace.name
  name      = var.container_repo_name
  summary   = "this is summary of my new repo"
  repo_type = "PUBLIC"
  detail    = "this is a public repo"
}
