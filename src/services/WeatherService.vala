using Soup;
using GLib;

public class WeatherService: IService {
    Session session;
    Json.Parser jsonParser;
    private static string API_KEY = "320846ac29674a36ac491420250603";
    private WeatherRepository? weatherRepository = null;

    public WeatherService() {
        session = new Session();
        session.timeout = 10; // Set a timeout for the session
        session.add_feature(new Soup.ContentSniffer());

        jsonParser = new Json.Parser();
        weatherRepository = new WeatherRepository();
    }

    public void start_service() {
        string url = "https://api.worldweatheronline.com/premium/v1/weather.ashx?num_of_days=5&fx24=yes&format=json&key=" + API_KEY + "&q=Miesbach,Germany";
        fetch_weather_data.begin("GET", url);

        // Set up a periodic fetch every hour
        Timeout.add_seconds(60 * 60, () => {
            fetch_weather_data.begin("GET", url);
            return true; // Continue the timeout
        });
    }

    public void stop_service() {
        // Clean up resources if necessary
        session = null;
        jsonParser = null;
    }

    public void update_service() {
        // do nothing
    }

    private async void fetch_weather_data(string method, string location) {
        var message = new Message (method, location);
        try {
            var bytes = yield session.send_and_read_async(message, 0, null);
            if (bytes != null) {
                uint8[] data = bytes.get_data();
                var builder = new StringBuilder.sized(data.length);
                for(int i=0; i<data.length; i++) {
                    builder.append_c((char)data[i]);
                }
                string response = builder.str;
                weatherRepository.save(response);

                var weather = new Weather();
                List<WeatherForecast> foreCasts = weather.getForecast();
                if (foreCasts != null) {
                    foreach (var forecast in foreCasts) {
                        print("Forecast for %s: Max Temp: %s, Min Temp: %s\n",
                                forecast.date, forecast.maxtempC, forecast.mintempC);
                    }
                } else {
                    warning("No forecasts available.");
                }

            } else {
                warning("No data received from weather service.");
            }
        } catch (Error e) {
            warning("Error fetching weather data: %s", e.message);
        }
    }
}