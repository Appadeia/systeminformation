namespace SystemInformation.Views { 
    public class SideBar : Gtk.StackSidebar {
        public SideBar() {
            this.width_request = 200;
            this.vexpand = true;
        }
    }
}
