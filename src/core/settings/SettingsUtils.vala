using GLib;

public class SettingsUtils {
    public static string getSettingsFilePath() {
        return "%s/%s/%s".printf(Environment.get_user_config_dir(), "discovery-applet", "settings.json").to_string ();
    }

    public static void checkSettingsFile() {
        var settingsPath = "%s/%s".printf(Environment.get_user_config_dir(), "discovery-applet").to_string ();
        if(FileUtils.test(settingsPath, FileTest.IS_DIR) == false) {
            DirUtils.create_with_parents(settingsPath, 0755);
            if(FileUtils.test(settingsPath, FileTest.IS_DIR) == false) {
                stderr.printf("Could not create config directory: %s\n", settingsPath);
                Process.exit (1);
            }
        }

        var filePath = getSettingsFilePath();
        if(FileUtils.test(filePath, FileTest.EXISTS) == false) {
            try {
                var file = File.new_for_path(filePath);
                var outputStream = file.create(FileCreateFlags.NONE);
                outputStream.write("{}".data, null);
                outputStream.close();

                if(FileUtils.test(filePath, FileTest.EXISTS) == false) {
                    stderr.printf("Could not create settings file: %s\n", filePath);
                    Process.exit (1);
                }
            } catch (Error e) {
                stderr.printf("Could not create settings file: %s\n", e.message);
                Process.exit (1);
            }
        }

        Json.Parser parser = new Json.Parser ();
        try {
            if(!parser.load_from_file (filePath)) {
                stderr.printf ("Unable to parse `%s'\n", filePath);
                Process.exit (1);
            }
        } catch (Error e) {
            stderr.printf ("Unable to parse `%s': %s\n", filePath, e.message);
            Process.exit (1);
        }

        // Get the root node:
        var rootNode = parser.get_root ();
        if(rootNode.is_null ()) {
            stderr.printf ("Root node is null\n");
            Process.exit (1);
        }

        Json.Object rootObject = rootNode.get_object ();
        if(rootObject == null) {
            stderr.printf ("Root node is not an object\n");
            Process.exit (1);
        }

        if(!rootObject.has_member ("feeds")) {
            var feeds = new Json.Array ();
            var feeds_node = new Json.Node (Json.NodeType.ARRAY);
            feeds_node.set_array (feeds);
            rootObject.set_member ("feeds", feeds_node);

            var feedNodeObject = new Json.Object();
            var uri = "http://rss.cnn.com/rss/cnn_topstories.rss";
            feedNodeObject.set_string_member ("name", "CNN News");
            feedNodeObject.set_string_member ("uri", uri);

            var digest = new Checksum(ChecksumType.MD5);
            digest.update(uri.data, uri.length);
            feedNodeObject.set_string_member("uid", digest.get_string());

            var feedNode = new Json.Node (Json.NodeType.OBJECT);
            feedNode.set_object (feedNodeObject);
            feeds.add_element (feedNode);
            
            try {
                var generator = new Json.Generator ();
                generator.set_root (rootNode);
                generator.set_pretty (true);
                generator.to_file (filePath);
            } catch (Error e) {
                stderr.printf("Could not write settings file: %s\n", e.message);
                Process.exit (1);
            }
        }
    }
}