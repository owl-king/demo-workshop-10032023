data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}
data "alicloud_instance_types" "default" {
  availability_zone    = data.alicloud_zones.default.zones.0.id
  cpu_core_count       = 2
  memory_size          = 4
  kubernetes_node_role = "Worker"
}
resource "alicloud_vpc" "default" {
  vpc_name   = var.name
  cidr_block = "10.1.0.0/21"
}
resource "alicloud_vswitch" "default" {
  vswitch_name = var.name
  vpc_id       = alicloud_vpc.default.id
  cidr_block   = "10.1.1.0/24"
  zone_id      = data.alicloud_zones.default.zones.0.id
}
resource "alicloud_key_pair" "default" {
  key_pair_name = var.name
}
resource "alicloud_cs_managed_kubernetes" "default" {
  name         = var.name
  count        = 1
  cluster_spec = "ack.pro.small"
  #is_enterprise_security_group = true
  pod_cidr           = "172.20.0.0/16"
  service_cidr       = "172.21.0.0/20"
  worker_vswitch_ids = [alicloud_vswitch.default.id]
}
resource "alicloud_cs_kubernetes_node_pool" "default" {
  name           = var.name
  cluster_id     = alicloud_cs_managed_kubernetes.default.0.id
  vswitch_ids    = [alicloud_vswitch.default.id]
  instance_types = [data.alicloud_instance_types.default.instance_types.0.id]

  system_disk_category = "cloud_efficiency"
  system_disk_size     = 40
  key_name             = alicloud_key_pair.default.key_name

  # you need to specify the number of nodes in the node pool, which can be 0
  desired_size = 1
}
