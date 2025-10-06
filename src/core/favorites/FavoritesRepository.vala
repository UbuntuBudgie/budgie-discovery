using Gee;
using GLib;

public class FavoritesRepository {
    public static HashSet<ApplicationItem> getFavorites() {
        var filePath = SettingsUtils.getSettingsFilePath();
        EqualDataFunc<ApplicationItem> equalFunc = (a, b) => {
            return a.desktopFilePath == b.desktopFilePath;
        };
        HashDataFunc<ApplicationItem> hashFunc = (a) => {
            return str_hash(a.desktopFilePath);
        };

        var favorites = new HashSet<ApplicationItem>(hashFunc, equalFunc);
        if(!GLib.FileUtils.test(filePath, GLib.FileTest.EXISTS)) {
            return favorites;
        }

        try {
            var parser = new Json.Parser();
            parser.load_from_file(filePath);

            var root = parser.get_root().get_object();
            var favoritesElements = root.has_member("favorites") ?
                root.get_array_member("favorites") : new Json.Array();

            favoritesElements.foreach_element((element, index) => {
                var line = element.get_string_element(index);
                var item = ApplicationItem.fromDesktopFile(line);
                if(item != null && !favorites.contains(item)) {
                    item.isFavorite = true;
                    favorites.add(item);
                }
            });
        } catch(Error e) {
            // do nothing
        }

        return favorites;
    }

    public static void saveFavorites(HashSet<ApplicationItem> favorites) {
        var filePath = SettingsUtils.getSettingsFilePath();
        if(!GLib.FileUtils.test(filePath, GLib.FileTest.EXISTS)) {
            return;
        }

        var list = new Json.Array();
        foreach(var item in favorites) {
            if(item.desktopFilePath != null) {
                list.add_string_element(item.desktopFilePath);
            }
        }

        try {
            var parser = new Json.Parser();
            parser.load_from_file(filePath);

            var root = parser.get_root().get_object();
            root.set_array_member("favorites", list);

            var node = new Json.Node(Json.NodeType.OBJECT);
            node.set_object(root);
            var generator = new Json.Generator();
            generator.set_root(node);
            generator.set_pretty(true);
            generator.to_file(filePath);
        } catch(Error e) {
            warning(e.message);
        }

    }
}