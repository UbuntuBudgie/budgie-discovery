public class WeatherWidget: Gtk.Box {

    public WeatherWidget() {
        Object();
        set_orientation(Gtk.Orientation.HORIZONTAL);
        set_spacing(5);
        get_style_context().add_class("weather-widget");

        var forecastDaysLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
        pack_start(forecastDaysLayout, false, false, 5);

        var weather = new Weather();
        List<WeatherForecast> weatherForecast = weather.getForecast();
        var weatherCurrent = weather.getCurrent();

        foreach(WeatherForecast forecastData in weatherForecast) {
            var widget = new WeatherForecastDayWidget();
            widget.setDayName(forecastData.date.format("%A"));
            widget.setTemperatureHigh(forecastData.mintempC);
            widget.setTemperatureLow(forecastData.maxtempC);
            forecastDaysLayout.pack_start(widget, false, false, 0);
        }
    }
}