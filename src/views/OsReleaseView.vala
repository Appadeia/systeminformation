using SystemInformation.Widgets;
using Gee;

namespace SystemInformation.Views {
    public class OsReleaseView : Gtk.Bin {
        protected HashMap<string, string> os_release;
        protected HashMap<string, int> pkgs;

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

        protected bool has_prog(string prog) {
            string output;
            string stderr;

            try {
                Process.spawn_command_line_sync(prog, out output, out stderr);
            } catch (Error e) {
                return false;
            }

            return true;
        }
        protected int count_lines(string prog) {
            string output;
            string stderr;

            try {
                Process.spawn_command_line_sync(prog, out output, out stderr);
                var split = output.split("\n");
                var len = split.length;
                return len;
            } catch (Error e) {
                return -1;
            }
        }

        protected async void parse_pkgs() {
            new Thread<int?>(null, () => {
                pkgs = new HashMap<string, int>();

                if (has_prog("rpm")) { // RPM
                    pkgs.set("rpm", count_lines("rpm -qa"));
                }
                if (has_prog("flatpak")) { // Flatpak
                    pkgs.set("flatpak_runtimes", count_lines("flatpak list --runtime") - 1);
                    pkgs.set("flatpak_apps", count_lines("flatpak list --app") - 1);
                }
                parse_pkgs.callback();
                return null;
            });
            yield;
        }

        public OsReleaseView() {
            this.parse_os_release();

            var col = new Hdy.Column();
            col.maximum_width = 800;
            col.linear_growth_width = 700;
            col.hexpand = true;
            col.halign = Gtk.Align.CENTER;

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
            box.margin_top = 30;

            var scroll = new Gtk.ScrolledWindow(null, null);

            {
                var label = new Gtk.Label("Release Information");
                label.get_style_context().add_class("title-4");
                label.xalign = -1;
    
                var dbox = new Gtk.ListBox();
                dbox.selection_mode = Gtk.SelectionMode.NONE;
                dbox.get_style_context().add_class("frame");
    
                { // Pretty Name
                    var row = new DataRow("Name", os_release["PRETTY_NAME"]);
                    dbox.add(row);
                }
                { // Version ID
                    var row = new DataRow("Version ID", os_release["VERSION_ID"]);
                    dbox.add(row);
                }
                { // Distribution ID
                    var row = new DataRow("Distribution ID", os_release["ID"]);
                    dbox.add(row);
                }
                { // Similar ID
                    var row = new DataRow("Similar IDs", os_release["ID_LIKE"], true, true, " ");
                    dbox.add(row);
                }
                box.add(label);
                box.add(dbox);
            }

            this.parse_pkgs.begin((obj, res) => {
                {
                    var label = new Gtk.Label("Packages");
                    label.get_style_context().add_class("title-4");
                    label.xalign = -1;
    
                    var dbox = new Gtk.ListBox();
                    dbox.selection_mode = Gtk.SelectionMode.NONE;
                    dbox.get_style_context().add_class("frame");
    
                    if (pkgs.has_key("rpm")) {
                        var row = new DataRow("RPM Packages", pkgs["rpm"].to_string());
                        dbox.add(row);
                    }
                    if (pkgs.has_key("flatpak_runtimes")) {
                        var row = new DataRow("Flatpak Runtimes", pkgs["flatpak_runtimes"].to_string());
                        dbox.add(row);
                    }
                    if (pkgs.has_key("flatpak_apps")) {
                        var row = new DataRow("Flatpak Apps", pkgs["flatpak_apps"].to_string());
                        dbox.add(row);
                    }

                    box.add(label);
                    box.add(dbox);

                    box.show_all();
                }
            });

            col.add(box);
            scroll.add(col);
            this.add(scroll);
        }
    }
}
