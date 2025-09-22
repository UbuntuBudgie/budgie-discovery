public class ApplicationItem {
    public string label {get; set;}
    public string icon {get; set;}
    public string action {get; set;}
    public string desktopFilePath {get; set;}

    public string toString() {
        return "{\"label\": \"%s\", \"action\": \"%s\", \"icon\": \"%s\", \"desktopFilePath\": \"%s\"}"
            .printf(label, action, icon,desktopFilePath);
    }

    public static ApplicationItem? fromDesktopFile(string path) {
        var file = GLib.File.new_for_path(path);
        if(!file.query_exists(null)) {
            warning("Desktop file %s does not exist", path);
            return null;
        }
        try {
            var parser = new GLib.KeyFile();
            parser.load_from_file(path, GLib.KeyFileFlags.NONE);

            var item = new ApplicationItem();
            item.label = parser.get_string("Desktop Entry", "Name");
            item.icon = parser.get_string("Desktop Entry", "Icon");
            item.action = parser.get_string("Desktop Entry", "Exec");
            item.desktopFilePath = path;
            return item;
        } catch(Error e) {
            warning("Unable to parse desktop file %s: %s", path, e.message);
            return null;
        }   
    }
}