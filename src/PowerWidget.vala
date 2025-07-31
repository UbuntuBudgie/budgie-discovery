[DBus (name="org.gnome.ScreenSaver")]
public interface ScreenSaver : Object
{
    public abstract async void lock() throws Error;
}

/* logind */
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

public class PowerWidget : Gtk.Box {
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

    public PowerWidget() {
        Object(
            orientation: Gtk.Orientation.HORIZONTAL,
            spacing: 5
        );

        var powerButton = new Gtk.Button.from_icon_name("system-shutdown-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        var rebootButton = new Gtk.Button.from_icon_name("system-restart-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        var suspendButton = new Gtk.Button.from_icon_name("system-suspend-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        var logoutButton = new Gtk.Button.from_icon_name("system-log-out-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

        this.pack_start(powerButton, false);
        this.pack_start(rebootButton, false);
        this.pack_start(suspendButton, false);
        this.pack_start(logoutButton, false);
        this.get_style_context().add_class("power-widget");

        powerButton.clicked.connect(() => {
            if (session == null) {
                return;
            }

            invoke_action();
            Timeout.add(100, ()=> {
                try {
                    session.Shutdown.begin();
                } catch (Error e) {
                    warning("Cannot shutdown: %s", e.message);
                }
                return false;
            });
        });
        rebootButton.clicked.connect(() => {
            if (session == null) {
                return;
            }

            invoke_action();
            Timeout.add(100, ()=> {
                try {
                    session.Reboot.begin();
                } catch (Error e) {
                    warning("Cannot reboot: %s", e.message);
                }
                return false;
            });
        });
        suspendButton.clicked.connect(() => {   
            if (logind_interface == null) {
                return;
            }

            invoke_action();
            Timeout.add(100, ()=> {
                try {
                    logind_interface.suspend(false);
                } catch (Error e) {
                    warning("Cannot suspend: %s", e.message);
                }
                return false;
            });
        });
        logoutButton.clicked.connect(() => { 
            if (session == null) {
                return;
            }

            invoke_action();
            Timeout.add(100, ()=> {    
                try {
                    session.Logout.begin(0);
                } catch (Error e) {
                    warning("Cannot logout: %s", e.message);
                }
                return false;
            });
        });

        setup_dbus.begin((obj,res)=> {
            print ("DBUS SETUP OK\n");
        });
    }
}