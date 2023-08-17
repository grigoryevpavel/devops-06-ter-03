# Задание 1

1. Изучите проект.
2. Заполните файл personal.auto.tfvars.
3. Инициализируйте проект, выполните код. Он выполнится, даже если доступа к preview нет.

Примечание. Если у вас не активирован preview-доступ к функционалу «Группы безопасности» в Yandex Cloud, запросите доступ у поддержки облачного провайдера. Обычно его выдают в течение 24-х часов.

Приложите скриншот входящих правил «Группы безопасности» в ЛК Yandex Cloud или скриншот отказа в предоставлении доступа к preview-версии.

# Решение 1

В подсети **develop** располагаются **Группы безопасности**. Там была создана единственная группа **example_dynamic**. Внутри неё располаются входящие(ingress) и исходящие правила(egress) доступа к подсети
Вид **ingress** правил представлен на скриншоте ниже:
<img src='images/IngressRules.png'/> 

Решение находится в [файле](https://github.com/grigoryevpavel/devops-06-ter-03/blob/master/src/count-vm.tf) 

# Задание 2

1. Создайте файл count-vm.tf. Опишите в нём создание двух **одинаковых** ВМ  web-1 и web-2 (не web-0 и web-1) с минимальными параметрами, используя мета-аргумент **count loop**. Назначьте ВМ созданную в первом задании группу безопасности.(как это сделать узнайте в документации провайдера yandex/compute_instance )
2. Создайте файл for_each-vm.tf. Опишите в нём создание двух ВМ с именами "main" и "replica" **разных** по cpu/ram/disk , используя мета-аргумент **for_each loop**. Используйте для обеих ВМ одну общую переменную типа list(object({ vm_name=string, cpu=number, ram=number, disk=number  })). При желании внесите в переменную все возможные параметры.
3. ВМ из пункта 2.2 должны создаваться после создания ВМ из пункта 2.1.
4. Используйте функцию file в local-переменной для считывания ключа ~/.ssh/id_rsa.pub и его последующего использования в блоке metadata, взятому из ДЗ 2.
5. Инициализируйте проект, выполните код.

# Решение 2

<img src='images/terrafrom2.png'/>

Решение находится в [файле](https://github.com/grigoryevpavel/devops-06-ter-03/blob/master/src/for_each-vm.tf) 

# Задание 3

1. Создайте 3 одинаковых виртуальных диска размером 1 Гб с помощью ресурса yandex_compute_disk и мета-аргумента count в файле **disk_vm.tf** .
2. Создайте в том же файле одну ВМ c именем "storage" . Используйте блок **dynamic secondary_disk{..}** и мета-аргумент for_each для подключения созданных вами дополнительных дисков.

# Решение 3

1. Результат выполнения **terraform apply**:
   <img src='images/terraform3.png'/>
2. Созданные виртульные машины:
   <img src='images/VM3.png'/>
3. Решение находится в [файле](https://github.com/grigoryevpavel/devops-06-ter-03/blob/master/src/disk_vm.tf) 

# Задание 4

1. В файле ansible.tf создайте inventory-файл для ansible.
Используйте функцию tepmplatefile и файл-шаблон для создания ansible inventory-файла из лекции.
Готовый код возьмите из демонстрации к лекции [**demonstration2**](https://github.com/netology-code/ter-homeworks/tree/main/demonstration2).
Передайте в него в качестве переменных группы виртуальных машин из задания 2.1, 2.2 и 3.2, т. е. 5 ВМ.
2. Инвентарь должен содержать 3 группы [webservers], [databases], [storage] и быть динамическим, т. е. обработать как группу из 2-х ВМ, так и 999 ВМ.
4. Выполните код. Приложите скриншот получившегося файла. 

Для общего зачёта создайте в вашем GitHub-репозитории новую ветку terraform-03. Закоммитьте в эту ветку свой финальный код проекта, пришлите ссылку на коммит.   
**Удалите все созданные ресурсы**.

# Решение 4

1. Для генерации inventory файла используем resource "local_file" с атрибутами filename и content:
   > filename="${abspath(path.module)}/ansible/hosts.cfg"
   > content= templatefile("${abspath(path.module)}/ansible/hosts.tftpl",{
   >     webservers= [for i in yandex_compute_instance.web: i ] 
   >     databases=  [for k,v in yandex_compute_instance.database: v ] 
   >     storages= tolist( [yandex_compute_instance.storage])  
   >  }) 
2. Атрибут content инициализируем значением функции templatefile

В итоге получился следующий inventory файл:
<img src='images/inventoryfile.png'/>



