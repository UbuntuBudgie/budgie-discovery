using Config;

public class WeatherForecastWidget: Card {
    private Gtk.Label tempMinLabel = new Gtk.Label("--");
    private Gtk.Label tempMaxLabel = new Gtk.Label("--");
    private Gtk.Label dateLabel = new Gtk.Label("--");
    private Gtk.Image weatherIcon = new Gtk.Image();

    public WeatherForecastWidget(WeatherForecastItem item) {
        base();
        get_style_context().add_class("no-border");
        get_style_context().add_class("no-shadow");
        get_style_context().add_class("weather-forecast-widget");
        set_spacing (3);

        pack_start(dateLabel, false);
        dateLabel.get_style_context().add_class("text-size-small");
        dateLabel.get_style_context().add_class("fw-600");
        dateLabel.set_halign(Gtk.Align.CENTER);

        weatherIcon.set_halign(Gtk.Align.CENTER);
        pack_start(weatherIcon, false);

        pack_start(tempMaxLabel, false);
        tempMaxLabel.get_style_context().add_class("text-size-small");
        tempMaxLabel.set_halign(Gtk.Align.CENTER);

        pack_start(tempMinLabel, false);
        tempMinLabel.get_style_context().add_class("text-size-small");
        tempMinLabel.set_halign(Gtk.Align.CENTER);

        var dayName = new DateTime.from_iso8601(item.date + "T00:00:00", new GLib.TimeZone.local()).format("%a");
        dateLabel.set_text(dayName);

        tempMinLabel.set_text(item.tempMin);
        tempMaxLabel.set_text(item.tempMax);

        string iconColor = item.isDay ? "black" : "white";
        var iconPath = ICONS_DIR + "/weather/" + iconColor + "/svg/" + item.weatherIconDay + ".svg";

        try {
            var iconFile = File.new_for_path(iconPath);
            var pixbuf = new Gdk.Pixbuf.from_stream(iconFile.read()).scale_simple(22, 22, Gdk.InterpType.HYPER);
            weatherIcon.set_from_pixbuf(pixbuf);
        } catch (Error e) {
            warning("Failed to load weather icon %s: %s\n", iconPath, e.message);
        }
    }
}
