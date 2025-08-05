using Config;

public class WeatherWidget: Gtk.Box {
    private WeatherRepository weather;
    private Gtk.Box forecastDaysLayout;

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
    }

    public void onWeatherUpdated() {
        List<WeatherForecast> weatherForecast = weather.getForecast();
        var weatherCurrent = weather.getCurrent();

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
}