using Config;
using Posix;

public class WeatherRepository {
    private static Sqlite.Database? db = null;

    public WeatherRepository() {
        print("PACKAGE NAME = %s", PACKAGE_NAME + "\n");
        if (db == null) {
            string localSharePackageDir = Environment.get_home_dir() + "/.local/share/budgie-desktop/plugins/" + PACKAGE_NAME;
            if( !FileUtils.test(localSharePackageDir, FileTest.IS_DIR)) {
                mkdir(localSharePackageDir, 0755);
            }
            print("localSharePackageDir = %s\n", localSharePackageDir);
            string dbPath = localSharePackageDir + "/data.db";

            Sqlite.Database.open(dbPath, out db);

            string query = "CREATE TABLE IF NOT EXISTS current_weather (" +
                "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                "location TEXT, " +
                "temperature TEXT, " +
                "condition TEXT, " +
                "weather_code TEXT, " +
                "humidity TEXT, " +
                "pressure TEXT, " +
                "timestamp DATETIME DEFAULT CURRENT_TIMESTAMP" +
                ");";
            db.exec(query);
        }
    }
}