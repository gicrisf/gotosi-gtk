using Gee;

namespace GotosiGtk {
    // Just an auxiliary struct because Vala doesn't support tuple var assignments
    private struct SpinProp {
      string elevel;
      string spin;
      string thalf;
    }

    // IO Utils
    private ArrayList<Isotope?> serialize_isotopes (string isotopes_json_path) {

      // ArrayList is similar to Rust's Vec
      // Dependency `gee-0.8`
      var isotopes = new ArrayList<Isotope?> ();

      // Make a new Json parser
      // Dependency 'json-glib-1.0'
      var parser = new Json.Parser ();

      // Parse and store data
      try {
        parser.load_from_stream ( resources_open_stream (isotopes_json_path, ResourceLookupFlags.NONE));
        // parser.load_from_file (isotopes_json_path);
      } catch (Error e) {
        stderr.printf("Error: %s\n", e.message);
      }

      var iso_root = parser.get_root (); // type is JsonArray

      try {
        // parser.load_from_file (spins_json_path);
        parser.load_from_stream ( resources_open_stream ("/it/zwitterio/Gotosi/data/spins.json", ResourceLookupFlags.NONE));
      } catch (Error e) {
        stderr.printf("Error: %s\n", e.message);
      }

      var spins_root = parser.get_root ();

      // GList containing JsonNode of the array.
      var json_isotopes = iso_root.get_array ().get_elements ();
      var json_spins = spins_root.get_array ().get_elements ();

      foreach (var iso_node in json_isotopes) {
        var iso_obj = iso_node.get_object ();

        var atomic_number = extract_property (iso_obj, "atomic_number");
        var symbol = extract_property (iso_obj, "symbol");
        var mass_number = extract_property (iso_obj, "mass_number");

        // Find isotope in supplementary dataset
        var nucleus = mass_number.up () + symbol.up ();
        var spin_properties = extract_spin_properties (json_spins, nucleus);

        Isotope this_iso = Isotope () {
          atomic_number = atomic_number,
          symbol = symbol,
          mass_number = mass_number,
          relative_atomic_mass = extract_property (iso_obj, "relative_atomic_mass"),
          isotopic_composition = extract_property (iso_obj, "isotopic_composition"),
          standard_atomic_weight = extract_property (iso_obj, "standard_atomic_weight"),
          elevel = spin_properties.elevel,
          spin = spin_properties.spin,
          thalf = spin_properties.thalf,
        };

        isotopes.add(this_iso);
      }  // foreach node in isotopes

      return isotopes;
    } // serialize_isotopes

    private string extract_property (Json.Object obj, string property) {

      // Manage nulls
      if (obj.get_member (property) == null) {
        return "NULL";
      } else {
        return obj.get_string_member (property);
      }
    }  // extract_properties from json

    private SpinProp extract_spin_properties (GLib.List<weak Json.Node> json_spins, string nucleus) {
      foreach (var spin_node in json_spins) {
        var spin_obj = spin_node.get_object ();
        var this_nucleus = extract_property (spin_obj, "nucleus");

        if (this_nucleus == nucleus) {
          var this_spin_prop = SpinProp () {
            elevel = extract_property (spin_obj, "elevel"),
            spin = extract_property (spin_obj, "spin"),
            thalf = extract_property (spin_obj, "thalf"),
          };

          return this_spin_prop;
        }
      }  // foreach

      var this_spin_prop = SpinProp () {
        elevel = "NULL",
        spin = "NULL",
        thalf = "NULL",
      };

      return this_spin_prop;

    }  // extract_spin_properties
}
