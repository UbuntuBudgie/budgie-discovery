# discovery-applet
A budgie-desktop applet to show latest news, weather and favorite locations and applications in a popover

### Screenshots

![image 1](https://github.com/k8s-cloud-io/budgie-discovery/blob/development/screenshots/1.png)
![image 2](https://github.com/k8s-cloud-io/budgie-discovery/blob/development/screenshots/2.png)
![image 3](https://github.com/k8s-cloud-io/budgie-discovery/blob/development/screenshots/3.png)
![image 4](https://github.com/k8s-cloud-io/budgie-discovery/blob/development/screenshots/4.png)

### Dependencies
```
budgie-1.0
gee-0.8
gio-2.0
goa-1.0
gtk+-3.0
json-glib-1.0
libpeas-1.0
libsoup-3.0
libxml-2.0
vala
```

### Installing from source
```
meson build --prefix /usr --buildtype=plain
ninja -C build
sudo ninja -C build install
```

