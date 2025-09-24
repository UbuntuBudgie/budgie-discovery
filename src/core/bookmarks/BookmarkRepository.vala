using Gee;
using GLib;

public class BookmarkRepository {
    public static ArrayList<BookmarkItem> getBookmarks() {
        var bookmarks = new ArrayList<BookmarkItem>();
        var filePath = Environment.get_user_config_dir () + "/gtk-3.0/bookmarks";
        var file = File.new_for_path (filePath);

        if (file.query_exists (null)) {
            try {
                var inputStream = file.read (null);
                var reader = new DataInputStream (inputStream);
                string? line = null;

                while ((line = reader.read_line ()) != null) {
                    line = line.chomp();
                    if (line.length == 0 || line.index_of("#") == 0) {
                        continue;
                    }

                    // Format is: file:///path/to/dir Optional Name
                    var parts = line.split(" ", 2);
                    var uri = parts[0];
                    string name;

                    if (parts.length > 1) {
                        name = parts[1];
                    } else {
                        var gfile = File.new_for_uri(uri);
                        name = gfile.get_basename();
                    }

                    var bookmark = new BookmarkItem();
                    bookmark.uri = uri;
                    bookmark.name = name;
                    bookmarks.add(bookmark);
                }

                reader.close();
                inputStream.close();
            } catch (Error e) {
                // do nothing
            }
        }

        return bookmarks;
    }
}