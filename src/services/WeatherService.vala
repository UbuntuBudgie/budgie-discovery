using Soup;
using GLib;

public class WeatherService: IService {
    private static Session session = new Session();
    private static Json.Parser jsonParser = new Json.Parser();
    private static string API_KEY = "320846ac29674a36ac491420250603";
    private static WeatherRepository weatherRepository;

    private static bool fetching = false;
    private static DateTime lastFetched;

    public WeatherService() {
        session.timeout = 10; // Set a timeout for the session
        session.add_feature(new Soup.ContentSniffer());
        weatherRepository = WeatherRepository.getInstance();
    }

    public void start_service() {
        string url = "https://api.worldweatheronline.com/premium/v1/weather.ashx?lang=de&tp=1&date_format=iso8601&extra=utcDateTime&num_of_days=5&fx24=yes&format=json&key=" + API_KEY + "&q=Miesbach,Germany";
        fetch_weather_data.begin("GET", url);

        // Set up a periodic fetch every minute
        Timeout.add_seconds(60, () => {
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
        if(fetching) return;

        DateTime current = new DateTime.now_local();
        if(lastFetched != null) {
            if(lastFetched.add_hours(1).to_unix() > current.to_unix() ) {
                return;
            }
        }

        fetching = true;
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

            } else {
                warning("No data received from weather service.");
            }
        } catch (Error e) {
            warning("Error fetching weather data: %s", e.message);
        }

        lastFetched = current;
        fetching = false;
    }
}