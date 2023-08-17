locals{
    vms_metadata = {
      serial-port-enable = 1
      ssh-keys  = file("~/.ssh/id_rsa.pub") 
    }
}