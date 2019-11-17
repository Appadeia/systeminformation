namespace SystemInformation.Widgets {
    public class DataRow : Gtk.Bin {
        public DataRow(string title, string info, bool expander = false, bool list = false, string? list_split = null, bool sort_list = false) {
            var label = new Gtk.Label(info);
            label.wrap_mode = Pango.WrapMode.WORD_CHAR;
            label.max_width_chars = 30;
            label.wrap = true;
            this.width_request = 400;

            if (!expander) {
                var row = new Hdy.ActionRow();
                row.selectable = false;
                row.set_title(title);
                row.add_action(label);
                this.add(row);
            } else {
                var row = new Hdy.ExpanderRow();
                row.selectable = false;
                GLib.Timeout.add(200, () => {
                    row.set_show_enable_switch(false);
                    return true;
                }, GLib.Priority.DEFAULT);
                if (list_split != null && list) {
                    var dbox = new Gtk.ListBox();
                    dbox.get_style_context().add_class("frame");

                    var strings = info.split(list_split);
                    List<string> strlist = new List<string>();

                    foreach (var str in strings) {
                        strlist.append(str);
                    }

                    if (sort_list) {
                        strlist.sort(strcmp);
                    }

                    foreach(var str in strlist) {
                        var a_row = new Hdy.ActionRow();
                        a_row.selectable = false;
                        a_row.set_title(str);
                        dbox.add(a_row);
                    }
                    row.add(dbox);
                } else {
                    row.add(label);
                }
                row.set_title(title);
                this.add(row);
            }
        }
    }
}
