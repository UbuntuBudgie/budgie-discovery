public class ChatGptWidget: Gtk.ScrolledWindow {
    private WebKit.WebView webView;

    public ChatGptWidget() {
        Object();
        set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        get_style_context().add_class("chatgpt-widget");
        set_shadow_type(Gtk.ShadowType.NONE);

        webView = new WebKit.WebView();
        webView.get_style_context().add_class("webview");
        webView.load_uri("https://www.chatgpt.com");
        add(webView);
    }
}