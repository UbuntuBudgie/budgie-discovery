/*
 * This file is part of discovery-applet
 *
 * Copyright (C) 2025 Andreas Bratfisch <duskman72@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

namespace DiscoveryApplet {
    public class Plugin : Budgie.Plugin, Peas.ExtensionBase {
        public Budgie.Applet get_panel_widget (string uuid) {
            return new Applet ();
        }
    }

    public class Applet : Budgie.Applet {
        protected Gtk.EventBox widget;
        protected Gtk.Box layout;
        protected Gtk.Label label;

        Budgie.Popover ? popover = null;
        Gtk.Orientation orient = Gtk.Orientation.HORIZONTAL;

        private unowned Budgie.PopoverManager ? manager = null;

        public override void panel_position_changed (Budgie.PanelPosition position) {
            if (position == Budgie.PanelPosition.LEFT || position == Budgie.PanelPosition.RIGHT) {
                this.orient = Gtk.Orientation.VERTICAL;
            } else {
                this.orient = Gtk.Orientation.HORIZONTAL;
            }
        }

        public Applet () {
            widget = new Gtk.EventBox ();
            layout = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            widget.add (layout);

            label = new Gtk.Label ("APPLET");
            layout.pack_start (label, false, false, 0);
            add(widget);

            get_style_context ().add_class ("discovery-applet");

            // Create popup
            popover = new DiscoveryPopup(widget).getPopover();

            widget.button_press_event.connect ((e)=> {
                if (e.button != 1) {
                    return Gdk.EVENT_PROPAGATE;
                }
                if (popover.get_visible ()) {
                    popover.hide ();
                } else {
                    this.manager.show_popover (widget);
                }
                return Gdk.EVENT_STOP;
            });

            popover.get_child ().show_all ();
            show_all ();
        }

        public override void update_popovers (Budgie.PopoverManager ? manager) {
            this.manager = manager;
            manager.register_popover (widget, popover);
        }
    }
}

[ModuleInit]
public void peas_register_types (TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Budgie.Plugin), typeof (DiscoveryApplet.Plugin));
}