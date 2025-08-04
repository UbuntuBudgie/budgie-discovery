using Config;
using Posix;

public class WeatherRepository {
    private static string filePath = null;
    private static Json.Parser parser = new Json.Parser();
    private static Json.Node root = null;

    public WeatherRepository() {
        if (filePath == null) {
            string localSharePackageDir = Environment.get_home_dir() + "/.local/share/budgie-desktop/plugins/" + PACKAGE_NAME;
            if( !FileUtils.test(localSharePackageDir, FileTest.IS_DIR)) {
                mkdir(localSharePackageDir, 0755);
            }
            filePath = localSharePackageDir + "/weather.json";
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
        } catch (Error e) {
            warning("Failed to load weather data: %s\n", e.message);
        }
    }
}
