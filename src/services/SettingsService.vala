public class SettingsService: IService {
    public signal void settingsChanged ();
    private uint timer;
    private uint64 last_mtime = 0;
    private string filePath;

    public void start_service () {
        timer = Timeout.add (500, () => {
            checkSettings();
            return true;
        });
    }
    public void stop_service () {
        if (timer != 0) {
            Source.remove (timer);
            timer = 0;
        }
    }
    public void update_service (bool force) {
        if(timer != 0) return;
        checkSettings();
    }

    private void checkSettings() {
        SettingsUtils.checkSettingsFile ();

        filePath = SettingsUtils.getSettingsFilePath ();
        var file = File.new_for_path (filePath);

        if (file.query_exists (null)) {
            try {
                var fileInfo = file.query_info ("time::modified", FileQueryInfoFlags.NONE, null);
                var mtime = fileInfo.get_attribute_uint64 ("time::modified");
                if (mtime != last_mtime) {
                    last_mtime = mtime;
                    settingsChanged ();
                }
            } catch (Error e) {
                // do nothing
            }
        }
    }
    
}