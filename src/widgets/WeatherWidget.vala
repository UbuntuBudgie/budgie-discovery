public class WeatherWidget: Gtk.Box {
    private Gtk.Label weatherLabel;

    public WeatherWidget() {
        Object();
        set_orientation(Gtk.Orientation.VERTICAL);
        set_spacing(5);
        get_style_context().add_class("weather-widget");

        weatherLabel = new Gtk.Label("Weather information will be displayed here.");
        weatherLabel.set_halign(Gtk.Align.CENTER);
        weatherLabel.set_valign(Gtk.Align.CENTER);
        pack_start(weatherLabel, true, true, 0);
    }

    public void update_weather(string weatherInfo) {
        weatherLabel.set_text(weatherInfo);
    }
}