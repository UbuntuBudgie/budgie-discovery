public class Weather {
    private static WeatherRepository weatherRepository = new WeatherRepository();
    
    public WeatherCondition? getCurrent() {
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

            reader.end_element(); // end weather element
            forecasts.append(forecast);
        }
        reader.end_member(); // end weather
        reader.end_member(); // end data

        return forecasts;
    }

    DateTime? parse_ampm_time(string time_str, int year, int month, int day) {
        // Escape-Sequenzen korrekt doppelt
        Regex regex = new Regex("^\\s*(\\d{1,2}):(\\d{2})\\s*([AaPp][Mm])\\s*$");
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