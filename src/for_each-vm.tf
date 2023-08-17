#создаем 2 идентичные ВМ
resource "yandex_compute_instance" "example" {
  depends_on  = [yandex_compute_instance.web ]
  for_each = { for s in var.vms_settings: index(var.vms_settings,s)=> s }
  name        = each.value.vm_name
  platform_id = var.vms_defaultsettings.platform_id
   

  resources {
    cores  = each.value.cpu
    memory = each.value.ram
    core_fraction = 20 
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type =  var.vms_defaultsettings.disktype
      size = each.value.disk
    }   
  }

  metadata = local.vms_metadata

  scheduling_policy { preemptible = true }

  network_interface { 
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }
  allow_stopping_for_update = true
}