using Gtk;
using Gee;

namespace GotosiGtk {

  /*
   * Enum cannot be compiled if inside the function
   * Remember the semicolon on the last term!
   */
  enum Cols {
    MASS_NUMBER,
    RELATIVE_ATOMIC_MASS,
    ISOTOPIC_COMPOSITION,
    STANDARD_ATOMIC_WEIGHT,
    ELEVEL,
    SPIN,
    THALF;
  }

  // TreeViewColumn custom generator
  Gtk.TreeViewColumn custom_column (int id, string title) {
    var col = new Gtk.TreeViewColumn ();
    var cell = new Gtk.CellRendererText ();

    col.pack_start (cell, true);
    col.set_min_width (100);
    col.set_resizable (true);
    col.set_title (title);

    col.add_attribute(cell, "text", id);

    return col;
  }

  // Setup new treeeview
  Gtk.TreeView setup_treeview () {
    var treeview = new Gtk.TreeView ();

    treeview.append_column (custom_column (Cols.MASS_NUMBER, "Mass Number"));
    treeview.append_column (custom_column (Cols.RELATIVE_ATOMIC_MASS, "Rel. Atomic Mass"));
    treeview.append_column (custom_column (Cols.ISOTOPIC_COMPOSITION, "Isotopic Composition"));
    treeview.append_column (custom_column (Cols.STANDARD_ATOMIC_WEIGHT, "Std Atomic Weight"));
    treeview.append_column (custom_column (Cols.ELEVEL, "E level"));
    treeview.append_column (custom_column (Cols.SPIN, "Nuclear Spin"));
    treeview.append_column (custom_column (Cols.THALF, "Half life"));

    return treeview;
  } // Setup TreeView

  public Gtk.ListStore make_isotopes_table_model (ArrayList<Isotope?> isotopes, ArrayList<int> active_element_isotopes) {

    // The model needs to know how many columns and the type of value in each one;
    var model = new Gtk.ListStore (
      7,
      typeof (string),
      typeof (string),
      typeof (string),
      typeof (string),
      typeof (string),
      typeof (string),
      typeof (string)
    );

    Gtk.TreeIter iter;

    foreach (var idx in active_element_isotopes) {
      model.append (out iter);
      model.set (
        iter,
        Cols.MASS_NUMBER,
        isotopes[idx].mass_number,
        Cols.RELATIVE_ATOMIC_MASS,
        isotopes[idx].relative_atomic_mass,
        Cols.ISOTOPIC_COMPOSITION,
        isotopes[idx].isotopic_composition,
        Cols.STANDARD_ATOMIC_WEIGHT,
        isotopes[idx].standard_atomic_weight,
        Cols.ELEVEL,
        isotopes[idx].elevel,
        Cols.SPIN,
        isotopes[idx].spin,
        Cols.THALF,
        isotopes[idx].thalf
        );
    }  // foreach

    return model;
  }

  public void open_isotope_modal(string symbol, Gtk.ListStore model) {
    var modal_window = new Gtk.Window ();
    modal_window.title = "Gotosi - Isotopes";
    modal_window.border_width = 10;
    modal_window.window_position = WindowPosition.CENTER;

    var vbox = new Box (Orientation.VERTICAL, 10);

    // Metadata frontmatter
    // TODO: better design, maybe logos
    var meta_label = new Label (("Element is: " + symbol));
    vbox.pack_start (meta_label, false, true, 10);

    // TreeView data
    var view = setup_treeview ();
    view.set_model (model);

    var scrolled_window = new Gtk.ScrolledWindow (null, null);
    scrolled_window.propagate_natural_width = true;
    scrolled_window.propagate_natural_height = true;
    scrolled_window.min_content_height = 400;
    scrolled_window.max_content_height = 800;
    scrolled_window.add (view);

    vbox.pack_start (scrolled_window, false, false, 0);

    modal_window.add (vbox);
    modal_window.set_keep_above (true);
    modal_window.show_all ();
  } // open_modal

} 
