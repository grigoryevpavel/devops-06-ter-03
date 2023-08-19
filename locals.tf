locals{
    vms_metadata = {
      serial-port-enable = 1
      ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")} " 
    }
}