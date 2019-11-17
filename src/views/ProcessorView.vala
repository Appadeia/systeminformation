using SystemInformation.Configs;
using SystemInformation.Widgets;
using Gee;

namespace SystemInformation.Views {
    public class ProcessorView : Gtk.Bin {
        public GLib.List<HashMap<string,string>> cpus;

        protected void parse_cpuinfo() {
            File file = File.new_for_path("/proc/cpuinfo");
            cpus = new GLib.List<HashMap<string, string>> ();
            var output = "";

            try {
                FileInputStream @is = file.read();
                DataInputStream dis = new DataInputStream (@is);
                string line;

                while((line = dis.read_line()) != null) {
                    output += line + "\n";
                }
            } catch (Error e) {
                print("Error: %s\n", e.message);
            }

            var lines = output.split("\n\n");

            foreach(var _string in lines) {
                var _split_lines = _string.split("\n");
                var cpuinfo = new HashMap<string, string>();
                foreach (var _string_ in _split_lines) {
                    string[] keyval = _string_.split(":");
                    cpuinfo.set(keyval[0].strip().replace(" ", "_"),keyval[1].strip().replace("\t", " ").replace("           ", " "));
                }
                if (!cpuinfo.has_key("processor"))
                    continue;
                cpus.append(cpuinfo);
            }
        }
        public ProcessorView() {
            this.parse_cpuinfo();

            var col = new Hdy.Column();
            col.maximum_width = 800;
            col.linear_growth_width = 700;
            col.hexpand = true;
            col.halign = Gtk.Align.CENTER;

            var scroll = new Gtk.ScrolledWindow(null, null);

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
            box.margin_top = 30;

            foreach(var cpu in this.cpus) { // details box
                var label = new Gtk.Label("Processor %s".printf(cpu["processor"]));
                label.get_style_context().add_class("title-4");
                label.xalign = -1;
                var dbox = new Gtk.ListBox();
                dbox.selection_mode = Gtk.SelectionMode.NONE;
                dbox.get_style_context().add_class("frame");
                { // Vendor ID
                    var row = new DataRow("Vendor ID", cpu["vendor_id"]);
                    dbox.add(row);
                }
                { // Model Name
                    var row = new DataRow("Model Name", cpu["model_name"]);
                    dbox.add(row);
                }
                { // Clock Speed
                    var row = new DataRow("Clock Speed (MHz)", cpu["cpu_MHz"]);
                    dbox.add(row);
                }
                { // Flags
                    var row = new DataRow("Flags", cpu["flags"], true, true, " ", true);
                    dbox.add(row);
                }
                { // Cache Size
                    var row = new DataRow("Cache Size", cpu["cache_size"]);
                    dbox.add(row);
                }
                { // Address Sizes
                    var row = new DataRow("Address Sizes", cpu["address_sizes"]);
                    dbox.add(row);
                }
                { // Microcode
                    var row = new DataRow("Microcode", cpu["microcode"].replace("x","×"));
                    dbox.add(row);
                }
                { // Physical Core ID
                    var row = new DataRow("Physical Core ID", cpu["physical_id"]);
                    dbox.add(row);
                }
                { // Virtual Core ID
                    var row = new DataRow("Virtual Core ID", cpu["core_id"]);
                    dbox.add(row);
                }
                { // Write Protect
                    var row = new DataRow("Write Protect", cpu["wp"].replace("y","Y").replace("n","N"));
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
