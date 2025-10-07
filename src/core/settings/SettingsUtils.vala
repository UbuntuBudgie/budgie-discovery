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
    }
}