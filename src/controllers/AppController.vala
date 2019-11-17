/*
* Copyright (C) 2019  Carson Black <uhhadd@gmail.com>
* 
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
* 
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* 
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

using SystemInformation.Views;

namespace SystemInformation.Controllers {

    /**
     * The {@code AppController} class.
     *
     * @since 1.0.0
     */
    public class AppController {

        private Gtk.Application             application;
        private Gtk.ApplicationWindow       window { get; private set; default = null; }
        
        private Gtk.SizeGroup lsize;
        private Gtk.SizeGroup rsize;

        private Gtk.Button backbutton;

        public Gtk.HeaderBar                lhb;
        public Gtk.HeaderBar                rhb;
        public Hdy.Leaflet                  hb_leaflet;
        public Hdy.TitleBar                 hb_container;

        public Hdy.Leaflet                  app_leaflet;

        public SideBar                      sidebar;
        public AppView                      app_stack;

        /**
         * Constructs a new {@code AppController} object.
         */
        public AppController (Gtk.Application application) {
            this.application = application;
            this.window = new Window (this.application);
            this.app_stack = new AppView ();

            this.window.set_default_size (800, 640);
            this.window.set_size_request(320, -1);
            this.application.add_window (window);

            { // Headerbar
                var hgroup = new Hdy.HeaderGroup();
                { // Left headerbar
                    this.lhb = new Gtk.HeaderBar();
                    this.lhb.set_title("System Information");
                }
                { // Right headerbar
                    this.rhb = new Gtk.HeaderBar();
                    this.rhb.expand = true;
                }
                { // Hamberder Menu
                    var hamberder = new Gtk.MenuButton();
                    var himage = new Gtk.Image.from_icon_name("open-menu-symbolic", Gtk.IconSize.BUTTON);
                    var menu = new Menu();
                    hamberder.use_popover = true;
                    hamberder.image = himage;
                    hamberder.menu_model = menu;
                    menu.append("Keyboard Shortcuts", "app.shortcuts");
                    menu.append("About System Information", "app.about");

                    this.lhb.pack_end(hamberder);
                }
                { // Back Button
                    backbutton = new Gtk.Button.from_icon_name("go-previous-symbolic");
                    backbutton.valign = Gtk.Align.CENTER;
                    backbutton.visible = false;
        
                    backbutton.clicked.connect(() => {
                        this.hb_leaflet.set_visible_child(this.lhb);
                        this.app_leaflet.set_visible_child(this.sidebar);
                    });

                    this.rhb.pack_start(backbutton);
                }
                { // Leaflet
                    var sep = new Gtk.Separator(Gtk.Orientation.VERTICAL);
                    sep.get_style_context().add_class("sidebar");

                    this.hb_leaflet = new Hdy.Leaflet();
                    this.hb_leaflet.add(this.lhb);
                    this.hb_leaflet.add(sep);
                    this.hb_leaflet.add(this.rhb);
        
                    this.hb_leaflet.expand = true;
                    this.hb_leaflet.child_transition_type = Hdy.LeafletChildTransitionType.OVER;
                    this.hb_leaflet.mode_transition_type = Hdy.LeafletModeTransitionType.SLIDE;
                }
                { // Headerbar group
                    this.lhb.show_close_button = true;
                    this.rhb.show_close_button = true;
                    hgroup.add_header_bar(this.lhb);
                    hgroup.add_header_bar(this.rhb);
                }
            }
            { // View
                { // Stack switcher
                    this.sidebar = new SideBar();
                }
                { // Stack
                    this.app_stack = new AppView();
                    this.sidebar.set_stack(this.app_stack);
                    this.app_stack.notify.connect((s, p) => {
                        if (p.name == "visible-child") {
                            this.app_leaflet.set_visible_child(this.app_stack);
                            this.hb_leaflet.set_visible_child(this.rhb);
                        }
                    });
                }
                { // Leaflet
                    var sep = new Gtk.Separator(Gtk.Orientation.VERTICAL);
                    sep.get_style_context().add_class("sidebar");

                    this.app_leaflet = new Hdy.Leaflet();

                    this.app_leaflet.add(this.sidebar);
                    this.app_leaflet.add(sep);
                    this.app_leaflet.add(this.app_stack);

                    this.app_leaflet.expand = true;
                    this.app_leaflet.child_transition_type = Hdy.LeafletChildTransitionType.OVER;
                    this.app_leaflet.mode_transition_type = Hdy.LeafletModeTransitionType.SLIDE;

                    this.app_leaflet.bind_property(
                        "folded", 
                        backbutton,
                        "visible",
                        BindingFlags.DEFAULT
                    );

                    this.window.add(this.app_leaflet);
                }
                { // Size Group
                    { // Left
                        this.lsize = new Gtk.SizeGroup(Gtk.SizeGroupMode.HORIZONTAL);
                        this.lsize.add_widget(this.sidebar);
                        this.lsize.add_widget(this.lhb);
                    }
                    { // Right
                        this.rsize = new Gtk.SizeGroup(Gtk.SizeGroupMode.HORIZONTAL);
                        this.rsize.add_widget(this.app_stack);
                        this.rsize.add_widget(this.rhb);
                    }
                }
            }
            { // Views 
                this.app_stack.add_titled(new SimpleView(), "simple-view", "Basic Information");
                this.app_stack.add_titled(new ProcessorView(), "proc-view", "Processors");
                this.app_stack.add_titled(new OsReleaseView(), "os-view", "Operating System");
            }
            
            this.hb_container = new Hdy.TitleBar();
            this.hb_container.add(this.hb_leaflet);
            this.window.set_titlebar(this.hb_container);

            Gtk.Settings.get_default ().set ("gtk-application-prefer-dark-theme", false);
            Gtk.Settings.get_default ().set ("gtk-theme-name", "Adwaita");
            Gtk.Settings.get_default ().set ("gtk-icon-theme-name", "Adwaita");
            Gtk.Settings.get_default ().set ("gtk-font-name", "Cantarell 11");
            Gtk.Settings.get_default ().set ("gtk-decoration-layout", ":close");
        }

        public void activate () {
            window.show_all ();
            app_stack.activate ();
        }

        public void quit () {
            window.destroy ();
        }
    }
}
