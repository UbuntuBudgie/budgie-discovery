using Config;
using GLib;
using Posix;

public class WeatherRepository {
    private string filePath = null;
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
            print("WEATHER UPDATED! (Repository)\n");
            weatherUpdated();
        } catch (Error e) {
            warning("Failed to load weather data: %s\n", e.message);
        }
    }

    public WeatherCondition? getCurrent() {
        Json.Node node = getRoot();
        if (node == null || node.is_null()) {
            warning("Failed to load current weather data.\n");
            return null;
        }
        
        Json.Reader reader = new Json.Reader(node);

        if (!reader.read_member("data")) {
            warning("Expected 'data' to be an element.\n");
            return null;
        }

        reader.read_member("current_condition");
        if (!reader.is_array()) {
            warning("Expected 'current_condition' to be an array.\n");
            return null;
        }

        reader.read_element(0); // Read the first element of the array
        string temp_C = "";
        string weatherDesc = "";
        string weatherCode = "";
        string humidity = "";
        string pressure = "";
        string weatherIconUrl = "";
        DateTime? date = null;

        if (reader.read_member("observation_time")) {
            date = new DateTime.from_iso8601(reader.get_string_value() + "Z", null);
            reader.end_member();
        }

        reader.read_member("temp_C");
        temp_C = reader.get_string_value();
        reader.end_member();

        if (reader.read_member("weatherDesc") && reader.is_array()) {
            reader.read_element(0);
            reader.read_member("value");
            weatherDesc = reader.get_string_value();
            reader.end_member();
            reader.end_element();
        }
        reader.end_member(); // end weatherDesc
        reader.read_member("weatherCode");
        weatherCode = reader.get_string_value();
        reader.end_member(); // end weatherCode

        reader.read_member("humidity");
        humidity = reader.get_string_value();
        reader.end_member(); // end humidity    

        reader.read_member("pressure");
        pressure = reader.get_string_value();
        reader.end_member(); // end pressure

        reader.read_member("weatherIconUrl");
        if (reader.is_array()) {
            reader.read_element(0);
            reader.read_member("value");
            weatherIconUrl = reader.get_string_value();
            reader.end_member();
            reader.end_element(); // end weatherIconUrl array element
        }
        reader.end_member(); // end weatherIconUrl

        reader.end_element(); // end first array element (current_condition)
        reader.end_member(); // end current_condition
        reader.end_member(); // end data

        var current = new WeatherCondition();
        current.date = date;
        current.tempC = temp_C;
        current.weatherDesc = weatherDesc;
        current.weatherCode = weatherCode;
        current.humidity = humidity;
        current.pressure = pressure;
        current.weatherIconUrl = weatherIconUrl;

        return current;
    }

    public List<WeatherForecast>? getForecast() {
        Json.Node node = getRoot();
        if (node == null || node.is_null()) {
            warning("Failed to load weather forecast data.\n");
            return null;
        }

        Json.Reader reader = new Json.Reader(node);
        if (!reader.read_member("data")) {
            warning("Expected 'data' to be an element.\n");
            return null;
        }

        if (!reader.read_member("weather") || !reader.is_array()) {
            warning("Expected 'weather' to be an array.\n");
            return null;
        }

        List<WeatherForecast> forecasts = new List<WeatherForecast>();

        for(var i = 0; i < reader.count_elements(); i++) {
            reader.read_element(i);
            WeatherForecast forecast = new WeatherForecast();

            reader.read_member("date");
            forecast.date = new DateTime.from_iso8601(reader.get_string_value() + "T00:00:00Z", null);
            reader.end_member();

            reader.read_member("maxtempC");
            forecast.maxtempC = reader.get_string_value();
            reader.end_member();

            reader.read_member("mintempC");
            forecast.mintempC = reader.get_string_value();
            reader.end_member();

            var year = int.parse(forecast.date.format("%Y"));
            var month = int.parse(forecast.date.format("%m"));
            var day = int.parse(forecast.date.format("%d"));

            if (reader.read_member("astronomy")) {
                if (reader.is_array()) {
                    reader.read_element(0);
                    WeatherAstronomy astronomy = new WeatherAstronomy();

                    reader.read_member("sunrise");
                    astronomy.sunrise = parse_ampm_time(reader.get_string_value(), year, month, day);
                    reader.end_member();

                    reader.read_member("sunset");
                    astronomy.sunset = parse_ampm_time(reader.get_string_value(), year, month, day);
                    reader.end_member();

                    reader.read_member("moonrise");
                    astronomy.moonrise = parse_ampm_time(reader.get_string_value(), year, month, day);
                    reader.end_member();

                    reader.read_member("moonset");
                    astronomy.moonset = parse_ampm_time(reader.get_string_value(), year, month, day);
                    reader.end_member();

                    reader.end_element(); // end astronomy array element
                    forecast.astronomy = astronomy;
                }
                reader.end_member(); // end astronomy
            }

            if(reader.read_member("hourly")) {
                if (reader.is_array()) {
                    forecast.hourlyForecast = new List<WeatherCondition>();
                    for (var j = 0; j < reader.count_elements(); j++) {
                        reader.read_element(j);
                        WeatherCondition hourlyCondition = new WeatherCondition();

                        reader.read_member("time");
                        string h = reader.get_string_value();
                        if(h.length == 1) h = "0"+h;
                        if(h.length == 3) h = "0"+h;
                        if(h == "24") h = "0001";

                        while (h.length < 4) {
                            h += "0"; // Ensure time is in HH:MM format
                        }
                        h = h.substring(0, 2) + ":00:00Z"; // Extract only the hour part

                        var date = forecast.date.format("%Y-%m-%d") + "T" + h;
                        hourlyCondition.date = new DateTime.from_iso8601(date, null);
                        reader.end_member();

                        reader.read_member("tempC");
                        hourlyCondition.tempC = reader.get_string_value();
                        reader.end_member();

                        if (reader.read_member("weatherDesc") && reader.is_array()) {
                            reader.read_element(0);
                            reader.read_member("value");
                            hourlyCondition.weatherDesc = reader.get_string_value();
                            reader.end_member();
                            reader.end_element(); // end weatherDesc array element
                        }
                        reader.end_member(); // end weatherDesc

                        reader.read_member("weatherCode");
                        hourlyCondition.weatherCode = reader.get_string_value();
                        reader.end_member(); // end weatherCode

                        if (reader.read_member("weatherIconUrl") && reader.is_array()) {
                            reader.read_element(0);
                            reader.read_member("value");
                            hourlyCondition.weatherIconUrl = reader.get_string_value();
                            reader.end_member();
                            reader.end_element(); // end weatherIconUrl array element
                        }
                        reader.end_member(); // end weatherIconUrl

                        forecast.hourlyForecast.append(hourlyCondition);
                        reader.end_element(); // end hourly condition element
                    }
                }
            }
            reader.end_member(); // end hourly

            reader.end_element(); // end weather element
            forecasts.append(forecast);
        }
        reader.end_member(); // end weather
        reader.end_member(); // end data

        return forecasts;
    }

    DateTime? parse_ampm_time(string time_str, int year, int month, int day) {
        // Escape-Sequenzen korrekt doppelt
        GLib.Regex regex = new GLib.Regex("^\\s*(\\d{1,2}):(\\d{2})\\s*([AaPp][Mm])\\s*$");
        MatchInfo match_info;

        if (regex.match(time_str, 0, out match_info)) {
            int hour = int.parse(match_info.fetch(1));
            int minute = int.parse(match_info.fetch(2));
            string meridian = match_info.fetch(3).up();

            // AM/PM konvertieren
            if (meridian == "PM" && hour != 12)
                hour += 12;
            else if (meridian == "AM" && hour == 12)
                hour = 0;

            return new DateTime.local(year, month, day, hour, minute, 0.0);
        }

        return null;
    }
}
