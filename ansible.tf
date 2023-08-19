# Создаем inventory файл в папке ansible
resource  "local_file" "inventoryfile" {
     filename="${abspath(path.module)}/ansible/hosts.cfg"
     content= templatefile("${abspath(path.module)}/ansible/hosts.tftpl",{
        webservers= [for i in yandex_compute_instance.web: i ] 
        databases=  [for k,v in yandex_compute_instance.database: v ] 
        storages= tolist( [yandex_compute_instance.storage])  
     })  
 }

resource "null_resource" "web_hosts_provision" {
#Ждем создания инстанса
 depends_on = [yandex_compute_instance.web,yandex_compute_instance.database,yandex_compute_instance.storage ]


#Добавление ПРИВАТНОГО ssh ключа в ssh-agent. В Windows используем powershell.
  provisioner "local-exec" {
    command = "powershell \"cat ~/.ssh/id_rsa | ssh-add -\""
  }

#Костыль!!! Даем ВМ 60 сек на первый запуск. Лучше выполнить это через wait_for port 22 на стороне ansible
# В случае использования cloud-init может потребоваться еще больше времени
 provisioner "local-exec" {
    command = "powershell \"sleep 60\""
  } 
 
#Запуск ansible-playbook
  provisioner "local-exec" {                  
    command  = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i \"${abspath(path.module)}/ansible/hosts.cfg\" \"${abspath(path.module)}/ansible/playbook.yml\""
    on_failure = continue #Продолжить выполнение terraform pipeline в случае ошибок
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
    #срабатывание триггера при изменении переменных
  }


    triggers = {  
      always_run         = "${timestamp()}" #всегда т.к. дата и время постоянно изменяются
      playbook_src_hash  = file("${abspath(path.module)}/ansible/playbook.yml") # при изменении содержимого playbook файла
      ssh_public_key     = var.public_key # при изменении ssh ключа  
    }

}