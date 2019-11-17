using SystemInformation.Configs;
using Gee;

namespace SystemInformation.Views {
    public class SimpleView : Gtk.Bin {
        protected HashMap<string, string> os_release;
        protected HashMap<string, string> cpuinfo;

        protected void parse_os_release() {
            File file = File.new_for_path("/etc/os-release");
            os_release = new HashMap<string, string>();

            try {
                FileInputStream @is = file.read();
                DataInputStream dis = new DataInputStream (@is);
                string line;

                while((line = dis.read_line()) != null) {
                    string[] keyval = line.split("=");
                    os_release.set(keyval[0],keyval[1].replace("\"", ""));
                }
            } catch (Error e) {
                print("Error: %s\n", e.message);
            }
        }
        protected void parse_cpuinfo() {
            File file = File.new_for_path("/proc/cpuinfo");
            cpuinfo = new HashMap<string, string>();

            try {
                FileInputStream @is = file.read();
                DataInputStream dis = new DataInputStream (@is);
                string line;

                while((line = dis.read_line()) != null) {
                    if (line == "")
                        continue;
                    string[] keyval = line.split(":");
                    cpuinfo.set(keyval[0].strip().replace(" ", "_"),keyval[1].strip().replace("\t", " ").replace("           ", " "));
                }
            } catch (Error e) {
                print("Error: %s\n", e.message);
            }
        }
        protected GLib.List<string> read_file(string path) {
            File file = File.new_for_path(path);
            GLib.List<string> strings = new GLib.List<string>();

            try {
                FileInputStream @is = file.read();
                DataInputStream dis = new DataInputStream (@is);
                string line;

                while((line = dis.read_line()) != null) {
                    strings.append(line);
                }
            } catch (Error e) {
                print("Error: %s\n", e.message);
            }

            return strings;
        }
        protected string get_output(string cmd) {
            string stdout = null;

            Process.spawn_command_line_sync(cmd, out stdout);

            return stdout.strip();
        }
        protected string get_ram() {
            string ram;
            var output = get_output("cat /proc/meminfo").split(":")[1].strip();
            var start = output.index_of("k");
            output = output.splice(start, -1);
            output = output.split(" ")[0];
            var kb = int.parse(output);
            var gb = kb / 1e6;
            ram = gb.to_string();
            if(ram.length > 4) {
                ram = ram.slice(0, 4);
            }
            return ram + " GB";
        }

        public SimpleView() {
            this.parse_os_release();
            this.parse_cpuinfo();

            var col = new Hdy.Column();
            col.maximum_width = 800;
            col.linear_growth_width = 700;
            col.hexpand = true;
            col.halign = Gtk.Align.CENTER;

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
            box.margin_top = 30;
            
            { // distro title
                var h1 = new Gtk.Label(os_release["PRETTY_NAME"]);
                h1.get_style_context().add_class("title-1");
                box.add(h1);
            }
            { // distro logo
                var img = new Gtk.Image.from_icon_name("distributor-logo-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
                img.pixel_size = 128;
                box.add(img);
            }

            { // details box
                var dbox = new Gtk.ListBox();
                dbox.selection_mode = Gtk.SelectionMode.NONE;
                dbox.get_style_context().add_class("frame");
                { // hostname
                    var row = new Hdy.ActionRow();
                    row.set_title("Device name");

                    var label = new Gtk.Label(read_file("/proc/sys/kernel/hostname").nth_data(0));
                    row.add_action(label);

                    dbox.add(row);
                }
                { // CPU
                    var row = new Hdy.ActionRow();
                    row.set_title("Processor");


                    var label = new Gtk.Label(cpuinfo["model_name"]);
                    row.add_action(label);

                    dbox.add(row);
                }
                { // CPU
                    var row = new Hdy.ActionRow();
                    row.set_title("Processor Cores");


                    var label = new Gtk.Label(cpuinfo["cpu_cores"]);
                    row.add_action(label);

                    dbox.add(row);
                }
                { // CPU
                    var row = new Hdy.ActionRow();
                    row.set_title("Processor Architecture");


                    var label = new Gtk.Label(get_output("uname -m"));
                    row.add_action(label);

                    dbox.add(row);
                }
                { // Memory
                    var row = new Hdy.ActionRow();
                    row.set_title("Memory");


                    var label = new Gtk.Label(get_ram());
                    row.add_action(label);

                    dbox.add(row);
                }
                { // Graphics
                    var row = new Hdy.ActionRow();
                    row.set_title("Graphics");


                    var label = new Gtk.Label(get_output("neofetch gpu").split(":")[1].strip());
                    row.add_action(label);

                    dbox.add(row);
                }
                box.add(dbox);
            }

            col.add(box);
            this.add(col);
        }
    }
}
