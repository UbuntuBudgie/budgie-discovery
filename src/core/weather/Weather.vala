public class Weather {
    private static WeatherRepository weatherRepository = new WeatherRepository();
    
    public WeatherCurrent? getCurrent() {
        Json.Node node = weatherRepository.getRoot();
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

        reader.end_element(); // end first array element (current_condition)
        reader.end_member(); // end current_condition
        reader.end_member(); // end data

        var current = new WeatherCurrent();
        current.tempC = temp_C;
        current.weatherDesc = weatherDesc;
        current.weatherCode = weatherCode;
        current.humidity = humidity;
        current.pressure = pressure;

        return current;
    }

    public List<WeatherForecast>? getForecast() {
        Json.Node node = weatherRepository.getRoot();
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

        print("register %d forecast days\n", reader.count_elements());
        for(var i = 0; i < reader.count_elements(); i++) {
            reader.read_element(i);
            WeatherForecast forecast = new WeatherForecast();

            reader.read_member("date");
            forecast.date = reader.get_string_value();
            reader.end_member();

            reader.read_member("maxtempC");
            forecast.maxtempC = reader.get_string_value();
            reader.end_member();

            reader.read_member("mintempC");
            forecast.mintempC = reader.get_string_value();
            reader.end_member();

            reader.end_element(); // end weather element
            forecasts.append(forecast);
        }
        reader.end_member(); // end weather
        reader.end_member(); // end data

        return forecasts;
    }
}