# discovery-applet
A budgie-desktop applet to show latest news, weather and custom widgets in a popover

### Screenshots

[here](/k8s-cloud-io/budgie-discovery/tree/development/screenshots)

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

