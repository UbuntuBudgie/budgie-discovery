using Config;
using GLib;
using Posix;

public class WeatherRepository {
    private string filePath = null;
    private static string cacheDir;
    private Json.Parser parser = new Json.Parser();
    private Json.Node root = null;
    private static WeatherRepository instance = null;

    public signal void weatherUpdated();

    public static WeatherRepository getInstance() {
        if(instance == null) {
            instance = new WeatherRepository();
        }
        return instance;
    }

    private WeatherRepository() {
        if (filePath == null) {
            cacheDir = "%s/%s".printf(Environment.get_user_cache_dir(), PACKAGE_NAME);
            if( !FileUtils.test(cacheDir, FileTest.IS_DIR)) {
                DirUtils.create_with_parents(cacheDir, 0755);
                if(FileUtils.test(cacheDir, FileTest.IS_DIR)) {
                    filePath = cacheDir + "/weather.json";
                }
            }
        }
    }

    public Json.Node getRoot() {
        if (root == null) {
            load();
        }
        return root;
    }
    
    public void save(string data) {
        if (filePath == null) {
            warning("File path is not set. Cannot save data.\n");
            return;
        }
        
        try {
            FileUtils.set_contents(filePath, data);
            load(); // Load the data after saving
        } catch (Error e) {
            warning("Failed to save weather data: %s\n", e.message);
        }
        
    }

    public void load() {
        if (filePath == null) {
            warning("File path is not set. Cannot load data.\n");
            return;
        }
        
        try {
            parser.load_from_file(filePath);
            root = parser.get_root();
            weatherUpdated();
        } catch (Error e) {
            warning("Failed to load weather data: %s\n", e.message);
        }
    }
}
