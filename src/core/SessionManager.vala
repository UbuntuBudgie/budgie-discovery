using Soup;

public class SessionManager: Object {
    private static Soup.Session? _session;
    public static uint max_conns_per_host = 6;

    public static Soup.Session get_default () {
        if (_session == null) {
            // ALPN aktivieren
            GLib.Environment.set_variable ("GIO_USE_TLS_ALPN", "1", true);
            GLib.Environment.set_variable ("SOUP_FORCE_HTTP2", "1", true);

            // Property-Namen (müssen exakt so heißen wie in libsoup)
            string[] names = {
                "user-agent",
                "max-conns",
                "max-conns-per-host",
                "timeout",
                "idle-timeout"
            };

            Value[] vals = new Value[names.length];
            vals[0] = Value (typeof (string));
            vals[0].set_string (
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0 Safari/537.36");

            vals[1] = Value (typeof (int));
            vals[1].set_int (20);   // max-conns

            vals[2] = Value (typeof (int));
            vals[2].set_int (6);    // max-conns-per-host

            vals[3] = Value (typeof (uint));
            vals[3].set_uint (20);  // timeout

            vals[4] = Value (typeof (uint));
            vals[4].set_uint (10);  // idle-timeout

            // Session mit allen construct-only Properties erzeugen
            _session = (Soup.Session) Object.new_with_properties (typeof (Soup.Session), names, vals);
            
            // Features hinzufügen (CookieJar, HSTS, usw.)
            var jar = new Soup.CookieJarText (Path.build_filename (Environment.get_user_cache_dir(), "cookies.txt"), false);
            jar.set_accept_policy (Soup.CookieJarAcceptPolicy.ALWAYS);
            _session.add_feature (jar);
            _session.add_feature (new Soup.HSTSEnforcer ());
        }

        return _session;
    }
}