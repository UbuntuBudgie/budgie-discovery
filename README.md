# discovery-applet
A budgie-desktop applet to show latest news, weather and custom widgets in a popover

## Dependencies
```
vala
gtk+-3.0
budgie-1.0
```

SOLUS
```
sudo eopkg it budgie-desktop-devel libgnome-desktop-devel vala
```

### Installing from source
```
meson build --prefix /usr --buildtype=plain
ninja -C build
sudo ninja -C build install
```

