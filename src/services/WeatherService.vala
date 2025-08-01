using Soup;
using GLib;

public class WeatherService: IService {
    Session session;
    Json.Parser jsonParser;
    private static string API_KEY = "320846ac29674a36ac491420250603";

    public WeatherService() {
        session = new Session();
        session.timeout = 10; // Set a timeout for the session
        session.add_feature(new Soup.ContentSniffer());

        jsonParser = new Json.Parser();
    }

    public override void start_service() {
        string url = "https://api.worldweatheronline.com/premium/v1/weather.ashx?num_of_days=5&fx24=yes&format=json&key=" + API_KEY + "&q=Miesbach,Germany";
        fetch_weather_data("GET", url);

        // Set up a periodic fetch every hour
        Timeout.add_seconds(60 * 60, () => {
            fetch_weather_data("GET", url);
            return true; // Continue the timeout
        });
    }

    public override void stop_service() {
        // Clean up resources if necessary
        session = null;
        jsonParser = null;
    }

    public override void update_service() {
        // do nothing
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
                jsonParser.load_from_data(response);

                Json.Node node = jsonParser.get_root ();
	            Json.Reader reader = new Json.Reader (node);
                
                foreach (string member in reader.list_members ()) {
                    if (member == "data") {
                        if (reader.read_member(member)) {
                            if (reader.read_member("current_condition")) {
                                if (reader.is_array()) {
                                    reader.read_element(0);

                                    reader.read_member("temp_C");
                                    string temp_C = reader.get_string_value();
                                    reader.end_member();

                                    string weatherDesc = "";
                                    if(reader.read_member("weatherDesc") && reader.is_array()) {
                                        reader.read_element(0);
                                        reader.read_member("value");
                                        weatherDesc = reader.get_string_value();
                                        reader.end_member();
                                        reader.end_element();
                                    }
                                    reader.end_member(); // end weatherDesc
                                    reader.end_element(); // end first array element (current_condition)

                                    print("Current temperature: %s°C, Condition: %s\n", temp_C, weatherDesc);
                                }
                                reader.end_member(); // end current_condition
                            }
                            reader.end_member(); // end data
                        } else {
                            warning("Expected 'data' to be an element.");
                        }
                    }
                }

            } else {
                warning("No data received from weather service.");
            }
        } catch (Error e) {
            warning("Error fetching weather data: %s", e.message);
        }
    }
}