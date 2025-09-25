public class FileWatcherSevice: IService {
    public signal void fileChanged (string path);
    private uint timer;
    private static HashTable<string, uint64?> files = new GLib.HashTable<string, uint64?> (GLib.str_hash, GLib.str_equal);

    public void start_service () {
        timer = Timeout.add (500, () => {
            checkFiles();
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
        checkFiles();
    }

    public void watchFile (string path) {
        if (!files.contains (path)) {
            files.insert (path, 0);
        }
    }

    public void unwatchFile (string path) {
        if (files.contains (path)) {
            files.remove (path);
        }
    }

    private void checkFiles() {
        foreach (var path in files.get_keys ()) {
            var file = File.new_for_path (path);

            if (file.query_exists (null)) {
                try {
                    var fileInfo = file.query_info ("time::modified", FileQueryInfoFlags.NONE, null);
                    var mtime = fileInfo.get_attribute_uint64 ("time::modified");
                    if (mtime != files.lookup (path)) {
                        files.insert (path, mtime);
                        fileChanged (path);
                    }
                } catch (Error e) {
                    // do nothing
                }
            }
        }
    }
}