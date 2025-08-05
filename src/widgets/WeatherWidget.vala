using Config;

public class WeatherWidget: Gtk.Box {
    private WeatherRepository weather;
    private WeatherCondition weatherCurrent;
    private List<WeatherForecast> weatherForecast;

    private Gtk.Box forecastDaysLayout;
    private Gtk.Label lastUpdatedLabel;

    private Gtk.Label currentDateLabel;
    private Gtk.Label currentWeatherTemp;
    private Gtk.Label currentWeatherDesc;
    private Gtk.Image currentWeatherIcon;
    private Gtk.Label currentWeatherMin;
    private Gtk.Label currentWeatherMax;

    public WeatherWidget() {
        Object();
        set_orientation(Gtk.Orientation.HORIZONTAL);
        set_spacing(5);
        get_style_context().add_class("weather-widget");

        forecastDaysLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
        pack_start(forecastDaysLayout, false, false, 5);

        for(var i = 0; i < 5; i++) {
            var widget = new WeatherForecastDayWidget();
            forecastDaysLayout.pack_start(widget, false, false, 0);
        }
        forecastDaysLayout.show_all();
        
        weather = WeatherRepository.getInstance();
        weather.weatherUpdated.connect(onWeatherUpdated);

        var currentWeatherLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
        currentWeatherLayout.get_style_context().add_class("weather-current");
        pack_start(currentWeatherLayout, true, true, 0);

        lastUpdatedLabel = new Gtk.Label("");
        lastUpdatedLabel.get_style_context().add_class("text-small");
        lastUpdatedLabel.set_halign(Gtk.Align.END);
        currentWeatherLayout.pack_end(lastUpdatedLabel, false, true, 0);

        currentDateLabel   = new Gtk.Label("");
        currentDateLabel.set_halign(Gtk.Align.START);

        currentWeatherTemp = new Gtk.Label("--°C");
        currentWeatherTemp.set_halign(Gtk.Align.START);
        currentWeatherTemp.get_style_context().add_class("weather-current-temp");

        currentWeatherDesc = new Gtk.Label("");
        currentWeatherDesc.set_halign(Gtk.Align.START);
        currentWeatherDesc.get_style_context().add_class("text-blue");

        currentWeatherMin  = new Gtk.Label("");
        currentWeatherMax  = new Gtk.Label("");

        var currentWeatherBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        currentWeatherLayout.pack_start(currentWeatherBox, false, false, 0);

        currentWeatherBox.pack_start(currentDateLabel, false, false, 0);
        currentWeatherBox.pack_start(currentWeatherTemp, false, false, 0);
        currentWeatherBox.pack_start(currentWeatherDesc, false, false, 0);
    }

    public void onWeatherUpdated() {
        weatherCurrent = weather.getCurrent();
        weatherForecast = weather.getForecast();

        updateForecast();
        updateCurrent();

        lastUpdatedLabel.set_text("Updated: " + new DateTime.now_local().format("%d.%m.%Y %H:%M"));
    }

    private void updateForecast() {
        for(var i = 0; i < 5; i++) {
            WeatherForecast forecastData = weatherForecast.nth_data(i);
            WeatherForecastDayWidget widget = (WeatherForecastDayWidget)forecastDaysLayout.get_children().nth_data(i);
            widget.setDayName(forecastData.date.format("%A"));
            widget.setTemperatureHigh(forecastData.mintempC);
            widget.setTemperatureLow(forecastData.maxtempC);

            foreach(WeatherCondition f in forecastData.hourlyForecast) {
                if(f.date.format("%H") == "12") {
                    widget.setCondition(f.weatherDesc);
                    int pos = f.weatherIconUrl.last_index_of("/");
                    var file = f.weatherIconUrl.substring(pos+1);
                    widget.setWeatherIcon(ICONS_DIR + "/weather/" + file);
                    break; // Only set condition for the 12:00 hour
                }
            }
        }
    }

    private void updateCurrent() {
        currentDateLabel.set_text(weatherCurrent.date.to_local().format("%A, %d.%m.%Y %H:%M"));
        currentWeatherTemp.set_text(weatherCurrent.tempC + "°C");
        currentWeatherDesc.set_text(weatherCurrent.weatherDesc);
        currentWeatherMin.set_text(weatherCurrent.mintempC + "°C");
        currentWeatherMax.set_text(weatherCurrent.maxtempC + "°C");
    }
}