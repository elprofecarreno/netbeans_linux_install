# INSTALACIÓN DE APACHE NETBEANS EN LINUX

Para instalar Apache NetBeans 31 con Oracle JDK 26, ejecuta los siguientes comandos:

```shell
chmod +x install.sh
./install.sh
```

## Configuración (`config.env`)

Puedes personalizar la versión y las URLs de descarga para NetBeans y el JDK editando `config.env`:

- `URL_NETBEANS`: URL para descargar el paquete zip de Apache NetBeans.
- `URL_JDK`: URL para descargar el paquete tar.gz del JDK.

Para desinstalar:

```shell
chmod +x uninstall.sh
./uninstall.sh
```

![01.png](./img/netbeans.png)
