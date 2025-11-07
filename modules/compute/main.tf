data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_core_images" "os" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.image_operating_system
  operating_system_version = var.image_operating_system_version
  shape                    = var.instance_shape
  # Observação: O provedor não garante ordenação; caso precise imagem específica use filter ou passe image_id diretamente via variável.
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
  subnet_id           = var.subnet_id

  source_details {
    source_type = "image"
    source_id   = local.effective_image_id // changed from image_id per provider schema
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
  }
}

data "oci_core_vnic_attachments" "instance_vnics" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.this.id
}

data "oci_core_vnic" "primary" {
  vnic_id = data.oci_core_vnic_attachments.instance_vnics.vnic_attachments[0].vnic_id
}
