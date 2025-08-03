public class WeatherWidget: Gtk.Box {

    public WeatherWidget() {
        Object();
        set_orientation(Gtk.Orientation.HORIZONTAL);
        set_spacing(5);
        get_style_context().add_class("weather-widget");

        var forecastDaysLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
        pack_start(forecastDaysLayout, false, false, 5);

        var forecastDay1 = new WeatherForecastDayWidget();
        forecastDay1.setDayName("Day Name");
        forecastDay1.setCondition("Condition String");
        forecastDay1.setTemperatureHigh("00°C");
        forecastDay1.setTemperatureLow("00°C");
        forecastDay1.setWeatherIcon("weather");

        var forecastDay2 = new WeatherForecastDayWidget();
        forecastDay2.setDayName("Day Name");
        forecastDay2.setCondition("Condition String");
        forecastDay2.setTemperatureHigh("00°C");
        forecastDay2.setTemperatureLow("00°C");
        forecastDay2.setWeatherIcon("weather");

        var forecastDay3 = new WeatherForecastDayWidget();
        forecastDay3.setDayName("Day Name");
        forecastDay3.setCondition("Condition String");
        forecastDay3.setTemperatureHigh("00°C");
        forecastDay3.setTemperatureLow("00°C");
        forecastDay3.setWeatherIcon("weather");

        var forecastDay4 = new WeatherForecastDayWidget();
        forecastDay4.setDayName("Day Name");
        forecastDay4.setCondition("Condition String");
        forecastDay4.setTemperatureHigh("00°C");
        forecastDay4.setTemperatureLow("00°C");
        forecastDay4.setWeatherIcon("weather");

        var forecastDay5 = new WeatherForecastDayWidget();
        forecastDay5.setDayName("Day Name");
        forecastDay5.setCondition("Condition String");
        forecastDay5.setTemperatureHigh("00°C");
        forecastDay5.setTemperatureLow("00°C");
        forecastDay5.setWeatherIcon("weather");

        forecastDaysLayout.pack_start(forecastDay1, false);
        forecastDaysLayout.pack_start(forecastDay2, false);
        forecastDaysLayout.pack_start(forecastDay3, false);
        forecastDaysLayout.pack_start(forecastDay4, false);
        forecastDaysLayout.pack_start(forecastDay5, false);
    }
}