[DBus (name="org.gnome.ScreenSaver")]
public interface ScreenSaver : Object
{
    public abstract async void lock() throws Error;
}

[DBus (name = "org.freedesktop.login1.Manager")]
public interface LogindInterface : Object {
    public abstract void suspend(bool interactive) throws Error;
    public abstract void hibernate(bool interactive) throws Error;
}

[DBus (name="org.gnome.SessionManager")]
public interface SessionManager : Object
{
    public abstract async void Logout (uint mode) throws Error;
    public abstract async void Reboot() throws Error;
    public abstract async void Shutdown() throws Error;
}

public class PowerMenu : Gtk.Menu {
    private ScreenSaver? saver = null;
    private SessionManager? session = null;
    private LogindInterface? logind_interface = null;
    private const string LOGIND_LOGIN = "org.freedesktop.login1";
    private const string UNABLE_CONTACT = "Unable to contact ";

    public signal void invoke_action();

    async void setup_dbus()
    {
        try {
            saver = yield Bus.get_proxy(BusType.SESSION, "org.gnome.ScreenSaver", "/org/gnome/ScreenSaver");
        } catch (Error e) {
            warning(UNABLE_CONTACT + "login manager: %s", e.message);
            return;
        }
        try {
            session = yield Bus.get_proxy(BusType.SESSION, "org.gnome.SessionManager", "/org/gnome/SessionManager");
        } catch (Error e) {
            warning(UNABLE_CONTACT + "GNOME Session: %s", e.message);
        }
        try {
            logind_interface = yield Bus.get_proxy(BusType.SYSTEM, LOGIND_LOGIN, "/org/freedesktop/login1");
        } catch (Error e) {
            warning(UNABLE_CONTACT + "logind: %s", e.message);
        }
    }

    public PowerMenu(Budgie.Popover popover) {
        Object();

        var item1 = createPowerMenuItem(_("Standby"), "system-lock-screen-symbolic");
        item1.activate.connect (() => {
            if (logind_interface == null) {
                return;
            }

            hide();
            Timeout.add(100, ()=> {
                try {
                    logind_interface.suspend(false);
                } catch (Error e) {
                    warning("Cannot suspend: %s", e.message);
                }
                return false;
            });
        });
        append (item1);

        var item5 = createPowerMenuItem(_("Logout"), "system-log-out-symbolic");
        item5.activate.connect (() => {
            if (session == null) {
                return;
            }

            popover.hide();
            Timeout.add(100, ()=> {    
                session.Logout.begin(0);
                return false;
            });
        });
        append (item5);

        var divider = new Gtk.SeparatorMenuItem();
        append(divider);

        var item3 = createPowerMenuItem(_("Shut Down"), "system-shutdown-symbolic");
        item3.activate.connect (() => {
            if (session == null) {
                return;
            }

            popover.hide();
            Timeout.add(100, ()=> {
                session.Shutdown.begin();
                return false;
            });
        });
        append (item3);

        var item4 = createPowerMenuItem(_("Reboot"), "system-reboot-symbolic");
        item4.activate.connect (() => {
            if (session == null) {
                return;
            }

            popover.hide();
            Timeout.add(100, ()=> {
                session.Reboot.begin();
                return false;
            });
        });
        append (item4);

        setup_dbus.begin((obj,res)=> {});
    }

    private Gtk.MenuItem createPowerMenuItem(string text, string? iconName) {
        var item = new Gtk.ImageMenuItem.with_label(text);
        var image = new Gtk.Image.from_icon_name(iconName, Gtk.IconSize.MENU);
        image.get_style_context().add_class("ms-4");
        image.valign = Gtk.Align.CENTER;
        item.image = image;
        item.always_show_image = true;
        return item;
    }
}