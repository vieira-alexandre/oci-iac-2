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
  effective_image_id = var.image_id != "" ? var.image_id : (length(data.oci_core_images.os.images) > 0 ? data.oci_core_images.os.images[0].id : null)
  is_flex_shape      = can(regex(".*Flex$", var.instance_shape))
  boot_size_override = var.boot_volume_size_gbs > 0 ? var.boot_volume_size_gbs : null
}

resource "oci_core_instance" "this" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name
  shape               = var.instance_shape

  source_details {
    source_type = "image"
    source_id   = local.effective_image_id
    dynamic "boot_volume_size_in_gbs" {
      for_each = local.boot_size_override != null ? [local.boot_size_override] : []
      content  = boot_volume_size_in_gbs.value
    }
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
  }

  lifecycle {
    precondition {
      condition     = local.effective_image_id != null && local.effective_image_id != ""
      error_message = "No image ID resolved. Provide variable image_id or ensure data source returns at least one image."
    }
    precondition {
      condition     = var.boot_volume_size_gbs == 0 || var.boot_volume_size_gbs >= 50
      error_message = "boot_volume_size_gbs precisa ser >= 50 ou 0 para usar default da imagem."
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
