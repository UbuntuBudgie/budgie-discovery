using Config;
using Gee;

public class WeatherWidget: Card {
    private WeatherRepository weatherRepository;
    private Gtk.Label currentTemperatureLabel = new Gtk.Label("--");
    private Gtk.Label currentDescriptionLabel = new Gtk.Label("");
    private Gtk.Image currentWeatherIcon = new Gtk.Image();
    private ArrayList <WeatherForecastItem> forecastItems = new ArrayList<WeatherForecastItem>();

    public WeatherWidget() {
        base();
        get_style_context ().add_class ("no-border");
        get_style_context ().add_class ("weather-widget");
        get_style_context ().add_class ("weather-widget-night");

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

        var layout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        layout.get_style_context ().add_class("card-body");
        layout.get_style_context ().add_class("pt-2");
        layout.get_style_context ().add_class("pb-2");
        pack_start (layout, true);

        var currentWeatherBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        layout.pack_start(currentWeatherBox, false);

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
        currentDescriptionLabel.margin_bottom = 15;
        currentDescriptionLabel.yalign = 30.0f;
        currentDescriptionLabel.vexpand = false;
        currentDescriptionLabel.single_line_mode = true;
        currentWeatherTempBox.pack_start (currentDescriptionLabel, false);

        var forecastBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 3);
        layout.pack_start(forecastBox, true);

        var weatherCodes = weatherCodesJson.get_object();

        weatherRepository = WeatherRepository.getInstance();
        weatherRepository.weatherUpdated.connect(() => {
            forecastItems.clear();
            forecastBox.get_children().foreach((child) => {
                forecastBox.remove(child);
            });

            var root = weatherRepository.getRoot();
            if (root != null) {
                var current = root.get_object ().get_member ("current").get_object();
                int currentTemperature = (int)Math.ceil(current.get_member("temperature_2m").get_int ());
                string currentWeatherCode = current.get_member("weather_code").get_int().to_string();
                bool isDay = current.get_member("is_day").get_int() == 1;

                currentTemperatureLabel.set_text(currentTemperature.to_string() + "°C");

                var currentDate = new DateTime.now().format ("%Y-%m-%d %H:%M");
                message("Updated weather widget: %s\n", currentDate);

                var weatherCodeEntry = weatherCodesJson.get_object().get_member(currentWeatherCode);
                if (weatherCodeEntry != null) {
                    var weatherCodeObject = weatherCodeEntry.get_object();
                    var dayObject = weatherCodeObject.get_member("day").get_object();
                    var nightObject = weatherCodeObject.get_member("night").get_object();

                    if(isDay) {
                        get_style_context ().remove_class ("weather-widget-night");
                        get_style_context ().add_class ("weather-widget-day");
                        currentDescriptionLabel.set_text(dayObject.get_member("description").get_string());
                    } else {
                        get_style_context ().remove_class ("weather-widget-day");
                        get_style_context ().add_class ("weather-widget-night");
                        currentDescriptionLabel.set_text(nightObject.get_member("description").get_string());
                    }
                }

                var daily = root.get_object ().get_member ("daily").get_object();
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
                    forecastBox.pack_start(forcastWidget, true);
                }
                forecastBox.show_all();

            } else {
                // Handle the case where no data is available
            }
        });
    }
}