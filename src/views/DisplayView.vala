using SystemInformation.Widgets;

namespace SystemInformation.Views {
    public class DisplayView : Gtk.Bin {
        public DisplayView() {
            var col = new Hdy.Column();
            col.maximum_width = 800;
            col.linear_growth_width = 700;
            col.hexpand = true;
            col.halign = Gtk.Align.CENTER;

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
            box.margin_top = 30;

            var scroll = new Gtk.ScrolledWindow(null, null);

            var disp = Gdk.Display.get_default();

            for (int i = 0; i < disp.get_n_monitors(); i++) {
                var mon = disp.get_monitor(i);

                var label = new Gtk.Label("Display %i".printf(i));

                if(mon.is_primary())
                    label.set_text("Display %i (Primary)".printf(i));

                label.get_style_context().add_class("title-4");
                label.xalign = -1;
    
                var dbox = new Gtk.ListBox();
                dbox.selection_mode = Gtk.SelectionMode.NONE;
                dbox.get_style_context().add_class("frame");
    
                { // Model
                    var row = new DataRow("Model", mon.model);
                    dbox.add(row);
                }
                { // Manufacturer
                    var row = new DataRow("Manufacturer", mon.manufacturer);
                    dbox.add(row);
                }
                { // Refresh Rate
                    var row = new DataRow("Refresh Rate", "%i Hz".printf(mon.refresh_rate / 1000));
                    dbox.add(row);
                }
                { // Scaling Factor
                    var row = new DataRow("Scale Factor", "%i".printf(mon.scale_factor));
                    dbox.add(row);
                }
                { // Dimension
                    var row = new DataRow("Dimensions", "%i×%i mm".printf(mon.width_mm, mon.height_mm));
                    dbox.add(row);
                }
                { // Geometry
                    var row = new DataRow("Geometry", "%i×%i at (%i, %i)".printf(mon.geometry.width, mon.geometry.height, mon.geometry.x, mon.geometry.y));
                    dbox.add(row);
                }
                box.add(label);
                box.add(dbox);
            }

            col.add(box);
            scroll.add(col);
            this.add(scroll);
        }
    }
}
