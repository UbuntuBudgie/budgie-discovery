public class SettingsService {
    public signal void settings_changed (string key);
    private static SettingsService instance;

    public static SettingsService getInstance() {
        if(instance == null) {
            instance = new SettingsService();
        }
        return instance;
    }

    public Json.Node? get_value (string key) {
        var file_path = "%s/%s/%s".printf (
            Environment.get_user_config_dir (),
            "discovery-applet",
            "settings.json"
        );

        try {
            checkSettingsFile();
            var parser = new Json.Parser();
            parser.load_from_file (file_path);
            var obj = parser.get_root ().get_object ();

            if (!obj.has_member (key))
                return null;

            return obj.get_member (key);
        } catch (Error e) {
            warning ("unable to read settings from file '%s': %s", file_path, e.message);
            return null;
        }
    }

    public void set_value(string key, Json.Node? value) {
        var file_path = "%s/%s/%s".printf (
            Environment.get_user_config_dir (),
            "discovery-applet",
            "settings.json"
        );

        try {
            checkSettingsFile();
            var parser = new Json.Parser();
            var generator = new Json.Generator();

            parser.load_from_file (file_path);
            var root = parser.get_root();
            var rootObject = root.get_object();
            
            if (value == null)
                rootObject.remove_member(key);
            else
                rootObject.set_member(key, value);

            generator.set_pretty(true);
            generator.set_root(root);
            generator.to_file(file_path);

            settings_changed(key);
        } catch (Error e) {
            warning ("unable to write settings to file '%s': %s", file_path, e.message);
        }
    }

    private void checkSettingsFile() throws Error {
        var dir_path = "%s/%s".printf(Environment.get_user_config_dir(), "discovery-applet");
        DirUtils.create_with_parents(dir_path, 0755);

        var file_path = "%s/%s/%s".printf (
            Environment.get_user_config_dir (),
            "discovery-applet",
            "settings.json"
        );

        if (!FileUtils.test(file_path, FileTest.EXISTS)) {
            var generator = new Json.Generator();
            var root = new Json.Node(Json.NodeType.OBJECT);
            root.set_object(new Json.Object());
            generator.set_root(root);
            generator.to_file(file_path);
        }
    }

    private SettingsService() {}
}