data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_core_images" "os" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.image_operating_system
  operating_system_version = var.image_operating_system_version
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

locals {
  effective_image_id       = var.boot_volume_id != "" ? null : (var.image_id != "" ? var.image_id : (length(data.oci_core_images.os.images) > 0 ? data.oci_core_images.os.images[0].id : null))
  effective_source_type    = var.boot_volume_id != "" ? "bootVolume" : "image"
  effective_boot_volume_id = var.boot_volume_id != "" ? var.boot_volume_id : null
  is_flex_shape            = can(regex(".*Flex$", var.instance_shape))
}

resource "oci_core_instance" "this" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name
  shape               = var.instance_shape

  source_details {
    source_type             = local.effective_source_type
    source_id               = local.effective_source_type == "bootVolume" ? local.effective_boot_volume_id : local.effective_image_id
    boot_volume_size_in_gbs = var.boot_volume_size_gbs == null ? null : var.boot_volume_size_gbs
  }

  dynamic "shape_config" {
    for_each = local.is_flex_shape ? [1] : []
    content {
      ocpus         = var.ocpus
      memory_in_gbs = var.memory_in_gbs
    }
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
    nsg_ids          = var.network_security_group_ids
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }

  lifecycle {
    precondition {
      condition     = (local.effective_source_type == "bootVolume" && local.effective_boot_volume_id != "") || (local.effective_source_type == "image" && local.effective_image_id != null && local.effective_image_id != "")
      error_message = "Nenhuma origem válida resolvida: defina boot_volume_id ou image_id / filtros de imagem válidos."
    }
    precondition {
      condition     = var.boot_volume_size_gbs == null || var.boot_volume_size_gbs >= 50
      error_message = "boot_volume_size_gbs precisa ser >= 50 ou null para usar default da imagem."
    }
    precondition {
      condition     = var.ssh_authorized_keys != ""
      error_message = "Forneça pelo menos uma chave pública SSH em ssh_authorized_keys para acessar a instância."
    }
  }
}

data "oci_core_vnic_attachments" "instance_vnics" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.this.id
}

data "oci_core_vnic" "primary" {
  vnic_id = data.oci_core_vnic_attachments.instance_vnics.vnic_attachments[0].vnic_id
}

resource "oci_core_volume" "data" {
  count               = var.data_volume_size_gbs == null || var.data_volume_size_gbs == 0 ? 0 : 1
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = coalesce(var.data_volume_display_name, "${var.instance_display_name}-data")
  size_in_gbs         = var.data_volume_size_gbs
  lifecycle {
    precondition {
      condition     = var.data_volume_size_gbs == null || var.data_volume_size_gbs == 0 || var.data_volume_size_gbs >= 50
      error_message = "data_volume_size_gbs deve ser null, 0 ou >= 50."
    }
  }
}

resource "oci_core_volume_attachment" "data_attach" {
  count           = var.data_volume_size_gbs == null || var.data_volume_size_gbs == 0 ? 0 : 1
  instance_id     = oci_core_instance.this.id
  volume_id       = oci_core_volume.data[count.index].id
  attachment_type = var.data_volume_attachment_type
}

resource "oci_core_volume_backup_policy_assignment" "data_policy" {
  count     = var.data_volume_backup_policy_id != null && var.data_volume_backup_policy_id != "" && var.data_volume_size_gbs != null && var.data_volume_size_gbs != 0 ? 1 : 0
  asset_id  = oci_core_volume.data[count.index].id
  policy_id = var.data_volume_backup_policy_id
}
