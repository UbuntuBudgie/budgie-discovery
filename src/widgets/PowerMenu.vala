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
public interface GLib.SessionManager : Object
{
    public abstract async void Logout (uint mode) throws Error;
    public abstract async void Reboot() throws Error;
    public abstract async void Shutdown() throws Error;
}

public class PowerMenu : Gtk.Menu {
    private ScreenSaver? saver = null;
    private GLib.SessionManager? session = null;
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
        var item1 = createPowerMenuItem(_("Logout"), "system-log-out-symbolic");
        item1.activate.connect (() => {
            if (session == null) {
                return;
            }

            popover.hide();
            Timeout.add(100, ()=> {    
                session.Logout.begin(0);
                return false;
            });
        });
        append (item1);

        /********************************************************/
        var item6 = createPowerMenuItem(_("Lock Screen"), "system-lock-screen-symbolic");
        item6.activate.connect (() => {
            if (saver == null) {
                return;
            }

            popover.hide();
            Timeout.add(100, ()=> {    
                saver.lock.begin();
                return false;
            });
        });
        append (item6);
        /********************************************************/

        var divider = new Gtk.SeparatorMenuItem();
        append(divider);

        var item2 = createPowerMenuItem(_("Standby"), "system-suspend-symbolic");
        item2.activate.connect (() => {
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
        append (item2);

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
        var image = new Gtk.Image.from_icon_name(iconName, Gtk.IconSize.MENU);
        image.get_style_context().add_class("ms-4");
        image.valign = Gtk.Align.CENTER;

        var label = new Gtk.Label(text);
        label.halign = Gtk.Align.START;
        label.valign = Gtk.Align.CENTER;

        var item = new Gtk.MenuItem();
        item.set_use_underline (false);
        item.set_label (""); 

        var itemLayout = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
        itemLayout.pack_start(image, false);
        itemLayout.pack_start(label, true);

        item.get_children().foreach(child => item.remove(child));
        item.add(itemLayout);

        return item;
    }
}