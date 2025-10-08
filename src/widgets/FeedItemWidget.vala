public class FeedItemWidget: Card {
    private FeedItem itemData;
    public signal void clicked();

    public FeedItemWidget(FeedItem feedItem) {
        base();
        get_style_context().add_class ("feed-item");
        itemData = feedItem;

        var cardBody = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
        cardBody.get_style_context ().add_class ("card-body");
        
        var eventBox = new Gtk.EventBox ();
        eventBox.set_visible_window(true);
        eventBox.add_events(Gdk.EventMask.POINTER_MOTION_MASK |
                Gdk.EventMask.ENTER_NOTIFY_MASK |
                Gdk.EventMask.LEAVE_NOTIFY_MASK);

        eventBox.add (cardBody);
        pack_start(eventBox, false, false,0);

        var image = new FeedItemImageWidget(feedItem);
        image.set_sensitive (false);
        image.set_size_request(-1, 100);
        cardBody.pack_start(image, false);

        var pubDate = parseDate1(feedItem.pubDate);
        var dateLabel = new Gtk.Label(pubDate);
        dateLabel.get_style_context().add_class("text-size-small");
        dateLabel.get_style_context().add_class("text-secondary");
        dateLabel.halign = Gtk.Align.START;
        cardBody.pack_start(dateLabel, false);

        var titleLabel = new Gtk.Label("");
        titleLabel.get_style_context().add_class("card-title");
        titleLabel.set_label(feedItem.title);
        titleLabel.set_line_wrap(true);
        titleLabel.set_line_wrap_mode(Pango.WrapMode.WORD);
        titleLabel.set_lines(3);
        titleLabel.set_ellipsize(Pango.EllipsizeMode.END);
        titleLabel.set_justify(Gtk.Justification.LEFT);
        titleLabel.set_halign(Gtk.Align.START);
        titleLabel.set_valign(Gtk.Align.START);
        titleLabel.hexpand = true;
        titleLabel.xalign = 0;
        cardBody.pack_start(titleLabel,true);

        eventBox.button_press_event.connect((event) => {
            clicked();
            Idle.add(() => {
                try {
                    AppInfo.launch_default_for_uri (itemData.link, null);
                } catch(Error e) {
                    message ("unable to open url for %s: %s", itemData.link, e.message);
                }
                return false;
            });
            return true;
        });

        eventBox.enter_notify_event.connect((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) return false;
            var display = Gdk.Display.get_default();
            var cursor = new Gdk.Cursor.from_name(display, "pointer");
            eventBox.get_window().set_cursor(cursor);

            get_style_context().add_class("hover");
            return false;
        });
        eventBox.leave_notify_event.connect((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) return false;
            eventBox.get_window().set_cursor(null);

            get_style_context().remove_class("hover");
            return false;
        });
    }

    private string parseDate1(string date) {
        var day = 0;
        var month = 0;
        var year = 0;
        var hour = 0;
        var minute = 0;
        var second = 0;

        try {
            var iso8601_1_regex = new Regex("[a-zA-Z]{3,3}, [0-9]{2,2} [a-zA-Z]{3,3} [0-9]{4,4} [0-9]{2,2}:[0-9]{2,2}:[0-9]{2,2} [\\+|\\-][0-9]{4,4}");
            var iso8601_2_regex = new Regex("\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(?:\\.\\d+)?(?:Z|[+-]\\d{2}:\\d{2})");
            var rfc_1123_regex = new Regex("[a-zA-Z]{3,3}, [0-9]{2,2} [a-zA-Z]{3,3} [0-9]{4,4} [0-9]{2,2}:[0-9]{2,2}:[0-9]{2,2} [a-zA-Z]{3,3}");
            
            if(iso8601_1_regex.match(date)) {
                var parts = date.split(" ");
                for(var i = 0; i < parts.length; i++) {
                    if(i == 0) continue;

                    if(i == 1) {
                        day = int.parse(parts[i]);
                    }

                    if(i == 2) {
                        switch(parts[i]) {
                            case "Jan":
                                month = 1;
                                break;
                            case "Feb":
                                month = 2;
                                break;
                            case "Mar":
                                month = 3;
                                break;
                            case "Apr":
                                month = 4;
                                break;
                            case "May":
                                month = 5;
                                break;
                            case "Jun":
                                month = 6;
                                break;
                            case "Jul":
                                month = 7;
                                break;
                            case "Aug":
                                month = 8;
                                break;
                            case "Sep":
                                month = 9;
                                break;
                            case "Oct":
                                month = 10;
                                break;
                            case "Nov":
                                month = 11;
                                break;
                            case "Dec":
                                month = 12;
                                break;
                        }
                    }

                    if(i == 3) {
                        year = int.parse(parts[i]);
                    }

                    if(i == 4) {
                        var timeParts = parts[i].split(":");
                        hour = int.parse(timeParts[0]);
                        minute = int.parse(timeParts[1]);
                        second = int.parse(timeParts[2]);
                    }
                }
            }
            else
            if(iso8601_2_regex.match(date)) {
                var parts = date.split("T");
                var dateParts = parts[0].split("-");
                year = int.parse(dateParts[0]);
                month = int.parse(dateParts[1]);
                day = int.parse(dateParts[2]);

                var timeParts = parts[1].split(".")[0].split(":");
                hour = int.parse(timeParts[0]);
                minute = int.parse(timeParts[1]);
                second = int.parse(timeParts[2]);
            }
            else
            if(rfc_1123_regex.match(date)) {
                var parts = date.split(" ");
                for(var i = 0; i < parts.length; i++) {
                    if(i == 0) continue;

                    if(i == 1) {
                        day = int.parse(parts[i]);
                    }

                    if(i == 2) {
                        switch(parts[i]) {
                            case "Jan":
                                month = 1;
                                break;
                            case "Feb":
                                month = 2;
                                break;
                            case "Mar":
                                month = 3;
                                break;
                            case "Apr":
                                month = 4;
                                break;
                            case "May":
                                month = 5;
                                break;
                            case "Jun":
                                month = 6;
                                break;
                            case "Jul":
                                month = 7;
                                break;
                            case "Aug":
                                month = 8;
                                break;
                            case "Sep":
                                month = 9;
                                break;
                            case "Oct":
                                month = 10;
                                break;
                            case "Nov":
                                month = 11;
                                break;
                            case "Dec":
                                month = 12;
                                break;
                        }
                    }

                    if(i == 3) {
                        year = int.parse(parts[i]);
                    }

                    if(i == 4) {
                        var timeParts = parts[i].split(":");
                        hour = int.parse(timeParts[0]);
                        minute = int.parse(timeParts[1]);
                        second = int.parse(timeParts[2]);
                    }
                }
            }
            else {
                message("UNABLE TO PARSE DATE: %s", date);
            }
        } catch(Error e) {
            warning("unable to parse date '%s': %s", date, e.message);
        }

        var formattedDate = "%4d-%02d-%02d %02d:%02d:%02d".printf(year,month,day, hour, minute, second);
        return new DateTime.from_iso8601(formattedDate, new TimeZone.local()).to_local().format ("%x %H:%M");
    }
}