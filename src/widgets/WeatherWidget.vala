using Config;
using Gee;

public class WeatherWidget: Card {
    private Gtk.Label currentTemperatureLabel = new Gtk.Label("--");
    private Gtk.Label currentDescriptionLabel = new Gtk.Label("");
    private Gtk.Image currentWeatherIcon = new Gtk.Image();
    private Gtk.Label lastUpdatedLabel = new Gtk.Label("");
    private ArrayList <WeatherForecastItem> forecastItems = new ArrayList<WeatherForecastItem>();
    private WeatherService weatherService;
    private static Json.Object weatherCodes;

    public WeatherWidget(LocationItem location) {
        base();

        var locationLabel = new Gtk.Label(location.name);
        locationLabel.set_halign (Gtk.Align.START);
        locationLabel.get_style_context ().add_class ("ps-3");
        locationLabel.get_style_context ().add_class ("pt-3");
        pack_start (locationLabel, false);

        var currentWeatherBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        pack_start(currentWeatherBox, false);

        currentWeatherIcon.set_valign (Gtk.Align.START);
        currentWeatherIcon.set_halign (Gtk.Align.START);
        currentWeatherIcon.margin_end = 7;
        currentWeatherBox.pack_start(currentWeatherIcon, false);

        var currentWeatherTempBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        currentWeatherTempBox.set_valign (Gtk.Align.CENTER);
        currentWeatherBox.pack_start (currentWeatherTempBox,false);

        currentTemperatureLabel.get_style_context().add_class("text-size-medium");
        currentTemperatureLabel.get_style_context().add_class("temperature-current");
        currentTemperatureLabel.set_halign (Gtk.Align.START);
        currentTemperatureLabel.set_valign (Gtk.Align.CENTER);
        currentTemperatureLabel.margin_top = 0;
        currentTemperatureLabel.margin_bottom = 0;
        currentTemperatureLabel.vexpand = false;
        currentTemperatureLabel.single_line_mode = true;
        currentWeatherTempBox.pack_start (currentTemperatureLabel, false);

        currentDescriptionLabel.get_style_context().add_class("text-size-small");
        currentDescriptionLabel.set_valign (Gtk.Align.CENTER);
        currentDescriptionLabel.set_halign (Gtk.Align.START);
        currentDescriptionLabel.margin_top = 0;
        currentDescriptionLabel.margin_bottom = 8;
        currentDescriptionLabel.yalign = 20.0f;
        currentDescriptionLabel.vexpand = false;
        currentDescriptionLabel.single_line_mode = true;
        currentWeatherTempBox.pack_start (currentDescriptionLabel, false);

        var forecastBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 3);
        forecastBox.margin_bottom = 5;
        pack_start(forecastBox, true);

        lastUpdatedLabel.get_style_context().add_class("text-size-small");
        lastUpdatedLabel.get_style_context().add_class("text-color-muted");
        lastUpdatedLabel.set_halign (Gtk.Align.CENTER);
        lastUpdatedLabel.set_valign (Gtk.Align.END);
        pack_end (lastUpdatedLabel,false);

        weatherService = new WeatherService(location);
        weatherService.weatherUpdated.connect((weather) => {

            forecastItems.clear();
            forecastBox.get_children().foreach((child) => {
                forecastBox.remove(child);
            });

            var current = weather.get_member ("current").get_object();
            int currentTemperature = (int)Math.ceil(current.get_member("temperature_2m").get_int ());
            string currentWeatherCode = current.get_member("weather_code").get_int().to_string();
            bool isDay = current.get_member("is_day").get_int() == 1;

            currentTemperatureLabel.set_text(currentTemperature.to_string() + "°");
            var weatherCodeEntry = weatherCodes.get_member(currentWeatherCode);
            if (weatherCodeEntry != null) {
                var weatherCodeObject = weatherCodeEntry.get_object();
                var dayObject = weatherCodeObject.get_member("day").get_object();
                var nightObject = weatherCodeObject.get_member("night").get_object();

                if(isDay) {
                    get_style_context ().remove_class ("weather-widget-night");
                    get_style_context ().add_class ("weather-widget-day");
                    currentDescriptionLabel.set_text(_(dayObject.get_member("description").get_string()));
                } else {
                    get_style_context ().remove_class ("weather-widget-day");
                    get_style_context ().add_class ("weather-widget-night");
                    currentDescriptionLabel.set_text(_(nightObject.get_member("description").get_string()));
                }
            }

            var daily = weather.get_member ("daily").get_object();
            daily.get_member ("time")
                .get_array ()
                .get_elements ()
                .foreach ((date) => {
                    var dateString = date.get_string ();
                    WeatherForecastItem item = new WeatherForecastItem();
                    item.date = dateString;
                    item.isDay = isDay;
                    forecastItems.add(item);
            });

            var index = 0;
            daily.get_member("temperature_2m_max")
                .get_array()
                .get_elements()
                .foreach((temp) => {
                    var tempValue = (int)Math.ceil(temp.get_double());
                    var item = forecastItems.get(index);
                    item.tempMax = tempValue.to_string() + "°";
                    index++;
            });

            index = 0;
            daily.get_member("temperature_2m_min")
                .get_array()
                .get_elements()
                .foreach((temp) => {
                    var tempValue = (int)Math.ceil(temp.get_double());
                    var item = forecastItems.get(index);
                    item.tempMin = tempValue.to_string() + "°";
                    index++;
            });

            index = 0;
            daily.get_member("weather_code")
                .get_array()
                .get_elements()
                .foreach((codeData) => {
                    var code = codeData.get_int().to_string();
                    var item = forecastItems.get(index);
                    item.weatherCode = code;

                    var entry = weatherCodes.get_member(code);
                    var dayIcon = entry.get_object().get_member("day").get_object().get_member("icon").get_string();
                    var nightIcon = entry.get_object().get_member("night").get_object().get_member("icon").get_string();

                    item.weatherIconDay = dayIcon;
                    item.weatherIconNight = nightIcon;

                    index++;
            });

            var entry = weatherCodes.get_member(currentWeatherCode);
            var memberName = isDay ? "day" : "night";
            var iconName = entry.get_object().get_member(memberName).get_object().get_member("icon").get_string();

            string iconColor = isDay ? "black" : "white";
            var iconPath = ICONS_DIR + "/weather/" + iconColor + "/png/64x64/" + iconName + ".png";

            try {
                var iconFile = File.new_for_path(iconPath);
                var pixbuf = new Gdk.Pixbuf.from_stream(iconFile.read())
                    .scale_simple(48, 48, Gdk.InterpType.HYPER);
                currentWeatherIcon.set_from_pixbuf(pixbuf);
            } catch (Error e) {
                warning("Failed to load weather icon %s: %s\n", iconPath, e.message);
            }

            for(var i = 0; i < 5; i++) {
                var item = forecastItems.get(i);
                var forcastWidget = new WeatherForecastWidget(item);
                forecastBox.pack_start(forcastWidget, true, true, 2);
            }
            forecastBox.show_all();

            var currentDate = new DateTime.now_local().format ("%x %H:%M");
            lastUpdatedLabel.set_label (_("updated at").concat(": %s").printf(currentDate));
        });

        Idle.add(() => {
            if(weatherCodes == null) {
                string weatherCodesFile = RESOURCES_DIR + "/weather-codes.json";
                Json.Parser parser = new Json.Parser();

                try {
                    parser.load_from_file(weatherCodesFile);
                } catch(Error e) {
                    warning("Failed to load weather codes from %s: %s\n", weatherCodesFile, e.message);
                }   
                
                var weatherCodesJson = parser.get_root();
                if (weatherCodesJson == null) {
                    warning("Failed to load weather codes from %s\n", weatherCodesFile);
                }
                weatherCodes = weatherCodesJson.get_object();
            }

            get_style_context ().add_class ("weather-widget");
            get_style_context ().add_class ("weather-widget-night");

            weatherService.stop_service ();
            weatherService.start_service ();
            return false;
        });
    }

    ~WeatherWidget() {
        weatherService.stop_service();
    }
}