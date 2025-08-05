using GLib;
using Gdk;

public class WeatherForecastDayWidget: Gtk.Box {
    private Gtk.Image weatherIcon;
    private Gtk.Label dayLabel;
    private Gtk.Label conditionLabel;
    private Gtk.Label temperatureHighLabel;
    private Gtk.Label temperatureLowLabel;

    public WeatherForecastDayWidget() {
        Object();
        set_orientation(Gtk.Orientation.HORIZONTAL);
        set_spacing(0);
        get_style_context().add_class("weather-forecast-day");

        weatherIcon = new Gtk.Image();
        weatherIcon.set_pixel_size(48);
        weatherIcon.set_size_request(48, 48);
        pack_start(weatherIcon, false, false, 0);

        var vBox1 = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        vBox1.get_style_context().add_class("forecast-day-details");
        vBox1.set_halign(Gtk.Align.START);
        vBox1.set_valign(Gtk.Align.CENTER);
        pack_start(vBox1, true, true, 0);
        
        dayLabel = new Gtk.Label("");
        dayLabel.set_halign(Gtk.Align.START);
        vBox1.pack_start(dayLabel, false, false, 0);

        conditionLabel = new Gtk.Label("");
        conditionLabel.set_halign(Gtk.Align.START);
        conditionLabel.get_style_context().add_class("text-secondary");
        vBox1.pack_start(conditionLabel, false, false, 0);
        
        var vBox2 = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        vBox2.set_halign(Gtk.Align.START);
        vBox2.set_valign(Gtk.Align.CENTER);
        pack_start(vBox2, false, false, 0);

        temperatureHighLabel = new Gtk.Label("");
        temperatureHighLabel.set_halign(Gtk.Align.START);
        vBox2.pack_start(temperatureHighLabel, false, false, 0);

        temperatureLowLabel = new Gtk.Label("");
        temperatureLowLabel.get_style_context().add_class("text-secondary");
        temperatureLowLabel.set_halign(Gtk.Align.END);
        vBox2.pack_start(temperatureLowLabel, false, false, 0);
    }

    public void setDayName(string dayName) {
        dayLabel.set_text(dayName);
    }

    public void setCondition(string condition) {
        conditionLabel.set_text(condition);
    }

    public void setTemperatureHigh(string temperatureHigh) {
        temperatureHighLabel.set_text(temperatureHigh + "°C");
    }

    public void setTemperatureLow(string temperatureLow) {
        temperatureLowLabel.set_text(temperatureLow + "°C");
    }

    public void setWeatherIcon(string fileName) {
        if (fileName == null) {
            weatherIcon.set_from_icon_name("weather-clear", Gtk.IconSize.BUTTON);
            return;
        }
    
        try {
            File file = File.new_for_path (fileName);
		    InputStream ios = file.read(null);

            if (ios != null) {
                var pixbuf = new Gdk.Pixbuf.from_stream(ios, null).scale_simple(48, 48, InterpType.HYPER);
                weatherIcon.set_from_pixbuf(pixbuf);   
            } else {
                warning("Failed to load weather icon: empty response\n");
                weatherIcon.set_from_icon_name("weather-clear", Gtk.IconSize.BUTTON);  
            }
        } catch (Error e) {
            warning("Failed to load weather icon: %s\n", e.message);
            weatherIcon.set_from_icon_name("weather-clear", Gtk.IconSize.BUTTON);  
        }
    }
}   