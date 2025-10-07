public class BookmarkService: Service {
    public signal void bookmarksChanged ();
    private uint timer;
    private uint64 last_mtime = 0;

    ~BookmarkService() {
        stop_service();
    }

    public new void start_service () {
        timer = Timeout.add (500, () => {
            checkBookmarks();
            return true;
        });
    }
    public new void stop_service () {
        if (timer != 0) {
            message("stop service");
            Source.remove (timer);
            timer = 0;
        }
    }
    public new void update_service (bool force) {
        if(timer != 0) return;
        checkBookmarks();
    }

    private void checkBookmarks() {
        var filePath = Environment.get_user_config_dir () + "/gtk-3.0/bookmarks";
        var file = File.new_for_path (filePath);

        if (file.query_exists (null)) {
            try {
                var fileInfo = file.query_info ("time::modified", FileQueryInfoFlags.NONE, null);
                var mtime = fileInfo.get_attribute_uint64 ("time::modified");
                if (mtime != last_mtime) {
                    last_mtime = mtime;
                    bookmarksChanged ();
                }
            } catch (Error e) {
                // do nothing
            }
        }
    }
    
}