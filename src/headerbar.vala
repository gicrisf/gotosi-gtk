namespace GotosiGtk {

  private Gtk.HeaderBar build_headerbar () {
    var bar = new Gtk.HeaderBar ();
    var button_burger = new Gtk.MenuButton ();

    /* Popover from model
     * Temporarily dismissed: wdf doesn't it work?
     * var pop_builder = new Gtk.Builder.from_resource ("/com/github/mr-chrome/gotosi/ui/header_popover.ui");
     * var pop_menu = pop_builder.get_object("app-menu") as GLib.MenuModel;
     * var popover = new Gtk.Popover.from_model ( button_burger, pop_menu );
     */

    // Popover vertical box
    var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);

    /// About button
    var button_about = new Gtk.Button.with_label ("About");
    button_about.margin = 3;
    button_about.clicked.connect (on_about);
    vbox.add (button_about);

    /// Dataset check
    var check_dataset = new Gtk.CheckButton.with_label ("Extended datset");
    check_dataset.margin = 3;
    // TODO temporarily disabled, remove widget
    check_dataset.sensitive = false;

    check_dataset.toggled.connect(() => {
      // TODO: remove change dataset!
    });

    vbox.add (check_dataset);

    /// TODO Quit button

    var popover = new Gtk.Popover ( button_burger );
    popover.add (vbox);
    popover.set_position (Gtk.PositionType.BOTTOM);
    button_burger.set_popover (popover);

    // Add stuff to HeaderBar
    bar.add (button_burger);
    vbox.show_all ();
    button_burger.show();
    bar.set_show_close_button (true);

    return bar;
  }  // build_headerbar

  // Actions
  public void on_about () {
    // TODO move this info to the Application class or to gresources
    string program_name = "Gotosi";
    string version = "0.1.0";
    string copyright = "(C) 2021 Giovanni Crisalfi";
    string license = "GPL3";
    string website = "https://github.com/mr-chrome/gotosi";
    string comments = "GTK powered isotope-oriented periodic table of elements";
    string[] authors = {"Giovanni Crisalfi", null};
    // string[] documentors;
    // TODO var logo;
    string title = "About Gotosi";

    Gtk.show_about_dialog (
      null,
      "program-name", program_name,
      "version", version,
      "copyright", copyright,
      "license", license,
      "website", website,
      "comments", comments,
      "authors", authors,
      "title", title,
      null
      );
  }
}
