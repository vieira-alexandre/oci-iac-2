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
}

resource "oci_core_instance" "this" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name
  shape               = var.instance_shape

  source_details {
    source_type             = "image"
    source_id               = local.effective_image_id
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
      condition     = local.effective_image_id != null && local.effective_image_id != ""
      error_message = "No image ID resolved. Provide variable image_id or ensure data source returns at least one image."
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
