using Soup;
using GLib;

public class WeatherService {
    Session session ;
    private static string API_KEY = "320846ac29674a36ac491420250603";

    public WeatherService() {
        session = new Session();
        session.timeout = 10; // Set a timeout for the session
        session.add_feature(new Soup.ContentSniffer());
    }

    public void start_service() {
        string url = "https://api.worldweatheronline.com/premium/v1/weather.ashx?num_of_days=5&fx24=yes&format=json&key=" + API_KEY + "&q=Miesbach,Germany";
        fetch_weather_data("GET", url);

        // Set up a periodic fetch every hour
        Timeout.add_seconds(60 * 60, () => {
            fetch_weather_data("GET", url);
            return true; // Continue the timeout
        });
    }

    private async void fetch_weather_data(string method, string location) {
        var message = new Message (method, location);
        try {
            var bytes = yield session.send_and_read_async(message, 0, null);
            if (bytes != null) {
                
                size_t size = 0;
                uint8[] data = bytes.get_data();
                var builder = new StringBuilder.sized(data.length);
                for(int i=0; i<data.length; i++) {
                    builder.append_c((char)data[i]);
                }
                string response = builder.str;
                print("Weather data received: %s", response);
            } else {
                warning("No data received from weather service.");
            }
        } catch (Error e) {
            warning("Error fetching weather data: %s", e.message);
        }
    }
}