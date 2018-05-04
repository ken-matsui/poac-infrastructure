resource "aws_db_subnet_group" "default" {
  name       = "rds_subnet_group"
  subnet_ids = ["${aws_subnet.priv1.id}", "${aws_subnet.priv2.id}"]
  tags {
    Project = "poacpm"
  }
}
resource "aws_rds_cluster" "cluster" {
  cluster_identifier        = "poacpm-cluster"
  database_name             = "poacpmcore"
  engine                    = "aurora"
  master_username           = "${var.rds_username}"
  master_password           = "${var.rds_password}"
  availability_zones        = ["${var.regions["tokyo"]}a", "${var.regions["tokyo"]}c"]
  db_subnet_group_name      = "${aws_db_subnet_group.default.name}"
  storage_encrypted         = true
  backup_retention_period   = 5
  final_snapshot_identifier = "poacpm-cluster"
}
resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "${aws_rds_cluster.cluster.cluster_identifier}-${count.index}"
  cluster_identifier = "${aws_rds_cluster.cluster.id}"
  instance_class     = "db.t2.small"
}
