using Gee;
using GLib;

public class FavoritesRepository {
    public static HashSet<ApplicationItem> getFavorites() {
        var filePath = "%s/budgie-desktop/plugins/discovery-applet/favorites.txt".printf( Environment.get_user_data_dir());
        EqualDataFunc<ApplicationItem> equalFunc = (a, b) => {
            return a.desktopFilePath == b.desktopFilePath;
        };
        HashDataFunc<ApplicationItem> hashFunc = (a) => {
            return str_hash(a.desktopFilePath);
        };

        var favorites = new HashSet<ApplicationItem>(hashFunc, equalFunc);

        FileStream stream = FileStream.open (filePath, "r");
        if(stream == null) {
            warning("Unable to open favorites file %s", filePath);
            return new HashSet<ApplicationItem>();
        }

        string line = null;
        while((line = stream.read_line()) != null) {
            line = line.chomp();
            if(line.length == 0) {
                continue;
            }

            var item = ApplicationItem.fromDesktopFile(line);
            if(item != null && !favorites.contains(item)) {
                favorites.add(item);
            }
        }

        return favorites;
    }

    public static void saveFavorites(HashSet<ApplicationItem> favorites) {
        var filePath = "%s/budgie-desktop/plugins/discovery-applet/favorites.txt".printf( Environment.get_user_data_dir());
        FileStream stream = FileStream.open (filePath, "w");
        if(stream == null) {
            warning("Unable to open favorites file %s", filePath);
            return;
        }
        
        EqualDataFunc<ApplicationItem> equalFunc = (a, b) => {
            return a.desktopFilePath == b.desktopFilePath;
        };
        HashDataFunc<ApplicationItem> hashFunc = (a) => {
            return str_hash(a.desktopFilePath);
        };
        HashSet<ApplicationItem> items = new HashSet<ApplicationItem>(hashFunc, equalFunc);
        foreach(var item in favorites) {
            if(item.desktopFilePath != null &&!items.contains(item))
                items.add(item);
        }

        foreach(var item in items) {
            stream.puts("%s\n".printf(item.desktopFilePath));
        }

        stream.flush();
    }
}