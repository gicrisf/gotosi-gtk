/* window.vala
 *
 * Copyright 2021 mr-chrome
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

using Gtk;
using Gee;

namespace GotosiGtk {

    public struct Isotope {
        string atomic_number;
        string symbol;
        string mass_number;
        string relative_atomic_mass;
        string isotopic_composition;
        string standard_atomic_weight;
        string elevel;
        string spin;
        string thalf;
      }

      public struct Element {
        string atomic_number;
        string symbol;
        ArrayList<int> isotopes_idxs;
      }

      public struct ElWidgets {
        Label label_symbol;
        Label label_atomic_number;
        Label label_mass_number_0;
        Label label_mass_number_1;
        Label label_mass_number_2;
        Label label_rel_atomic_mass_0;
        Label label_rel_atomic_mass_1;
        Label label_rel_atomic_mass_2;
        Label label_nuclear_spin_0;
        Label label_nuclear_spin_1;
        Label label_nuclear_spin_2;
        Label label_half_life_0;
        Label label_half_life_1;
        Label label_half_life_2;
        LevelBar level_isotopic_composition_0;
        LevelBar level_isotopic_composition_1;
        LevelBar level_isotopic_composition_2;
      }

      const string[] ELEMENTS = {
        "H", "Li", "Na", "K", "Rb", "Cs", "Fr",
        "Be", "Mg", "Ca", "Sr", "Ba", "Ra",
        "Sc", "Y",
        "La", "Ce", "Pr", "Nd", "Pm", "Sm", "Eu", "Gd", "Tb", "Dy", "Ho", "Er", "Tm", "Yb", "Lu",
        "Ac", "Th", "Pa", "U", "Np", "Pu", "Am", "Cm", "Bk", "Cf", "Es", "Fm", "Md", "No", "Lr",
        "Ti", "Zr", "Hf", "Rf",
        "V", "Nb", "Ta", "Db",
        "Cr", "Mo", "W", "Sg",
        "Mn", "Tc", "Re", "Bh",
        "Fe", "Ru", "Os", "Hs",
        "Co", "Rh", "Ir", "Mt",
        "Ni", "Pd", "Pt", "Ds",
        "Cu", "Ag", "Au", "Rg",
        "Zn", "Cd", "Hg", "Cn",
        "B", "Al", "Ga", "In", "Tl", "Nh",
        "C", "Si", "Ge", "Sn", "Pb", "Fl",
        "N", "P", "As", "Sb", "Bi", "Mc",
        "O", "S", "Se", "Te", "Po", "Lv",
        "F", "Cl", "Br", "I", "At", "Ts",
        "He", "Ne", "Ar", "Kr", "Xe", "Rn", "Og",
      };  // elements

	// [GtkTemplate (ui = "/it/zwitterio/Gotosi/window.ui")]
	public class App : Gtk.Application {
		// [GtkChild]
		// Gtk.Label label;

		public App () {
			Object (
              application_id: "com.github.mr-chrome.gotosi",
              flags: ApplicationFlags.FLAGS_NONE
            );
		}

		// Active dataset
        private string isotopes_json_path = "/it/zwitterio/Gotosi/data/all_isotopes.min.json";
        private ArrayList<Isotope?> isotopes = null;

        // Store and share active element data
        private Element active_element = Element ();
        private ElWidgets el_widgets = ElWidgets ();

        protected override void activate () {
          // Data serialization
          this.isotopes = serialize_isotopes (isotopes_json_path);
          // Start selecting hydrogen
          this.active_element = get_active_element_data (this.isotopes, "H");
          // Builder
          var builder = new Gtk.Builder.from_resource ("/it/zwitterio/Gotosi/window.ui");

          // UI widgets
          var window = builder.get_object ("application_window") as ApplicationWindow;
          window.title = "Gotosi";
          window.window_position = WindowPosition.CENTER;
          var button_isotopes_table = builder.get_object ("button_isotopes_table") as Button;

          /// Isotopes preview widgets
          this.el_widgets = ElWidgets () {
            label_symbol = builder.get_object ("label_symbol") as Label,
            label_atomic_number = builder.get_object ("label_atomic_number") as Label,
            label_mass_number_0 = builder.get_object ("label_mass_number_0") as Label,
            label_mass_number_1 = builder.get_object ("label_mass_number_1") as Label,
            label_mass_number_2 = builder.get_object ("label_mass_number_2") as Label,
            label_rel_atomic_mass_0 = builder.get_object ("label_rel_atomic_mass_0") as Label,
            label_rel_atomic_mass_1 = builder.get_object ("label_rel_atomic_mass_1") as Label,
            label_rel_atomic_mass_2 = builder.get_object ("label_rel_atomic_mass_2") as Label,
            label_nuclear_spin_0 = builder.get_object ("label_nuclear_spin_0") as Label,
            label_nuclear_spin_1 = builder.get_object ("label_nuclear_spin_1") as Label,
            label_nuclear_spin_2 = builder.get_object ("label_nuclear_spin_2") as Label,
            label_half_life_0 = builder.get_object ("label_half_life_0") as Label,
            label_half_life_1 = builder.get_object ("label_half_life_1") as Label,
            label_half_life_2 = builder.get_object ("label_half_life_2") as Label,
            level_isotopic_composition_0 = builder.get_object ("level_isotopic_composition_0") as LevelBar,
            level_isotopic_composition_1 = builder.get_object ("level_isotopic_composition_1") as LevelBar,
            level_isotopic_composition_2 = builder.get_object ("level_isotopic_composition_2") as LevelBar,
          };

          set_active_element_ui_widgets ( this.active_element, this.el_widgets );

          /// Isotopes table widgets
          button_isotopes_table.clicked.connect (() => {
            var model = make_isotopes_table_model (this.isotopes, this.active_element.isotopes_idxs);
            open_isotope_modal (this.active_element.symbol, model);
          });

          foreach (var el in ELEMENTS) {
            var _btn = builder.get_object ("button_" + el) as Gtk.Button;
            var el_symbol = _btn.get_label();

            _btn.clicked.connect (() => {
              // Get element data and update UI widgets
              this.active_element = get_active_element_data (this.isotopes, el_symbol);
              set_active_element_ui_widgets ( this.active_element, this.el_widgets );
            }); // element btn clicked

          };  // foreach element

          // HeaderBar and Menus
          var custom_headerbar = build_headerbar ();
          window.set_titlebar (custom_headerbar);

          // Connect signals
          /*
           * var action = new GLib.SimpleAction ("about", null);
           * action.activate.connect (on_about);
           * action.set_enabled (true);
           * this.add_action (action);
           */

          // builder.connect_signals (null);

          // Show main window and quit when destroyed;
          window.destroy.connect (Gtk.main_quit);
          window.show_all ();
          Gtk.main();
        }  // Activate

        private Element get_active_element_data (ArrayList<Isotope?> isotopes, string symbol) {
          var active_el_isotopes = new ArrayList<int> ();

          var z="1";
          var index=0;
          foreach (var isotope in isotopes) {
            if (isotope.symbol == symbol) {
              active_el_isotopes.add(index);
              z = isotope.atomic_number;
            }
            index++;
        }

          Element el = Element () {
            atomic_number = z,
            symbol = symbol,
            isotopes_idxs = active_el_isotopes
          };

          return el;
        }  // get_active_element_data

        private double isocomp_to_double (string isocomp) {
          // Remove final bracket from string
          var isocomp_trimmed = isocomp.split("(")[0];

          // Parse to double and return
          return (double.parse(isocomp_trimmed));
        }

        private int compare_by_isocomp (int idx_a, int idx_b) {
          var isocomp_a = this.isotopes[idx_a].isotopic_composition;
          var isocomp_b = this.isotopes[idx_b].isotopic_composition;

          var a_double = isocomp_to_double(isocomp_a);
          var b_double = isocomp_to_double(isocomp_b);

          if (b_double > a_double) { return 1; }
          else if (b_double == a_double) { return 0; }
          else { return -1; }
        }  // compare_by_isocomp

        private void set_active_element_ui_widgets (Element el, ElWidgets widgets) {
          widgets.label_symbol.set_label (el.symbol);
          widgets.label_atomic_number.set_label (el.atomic_number);

          // Sort isotopes by desc isotopic composition
          el.isotopes_idxs.sort((a,b) => { return compare_by_isocomp(a, b); } );

          if (el.isotopes_idxs.size > 0) {
            widgets.label_mass_number_0.set_label (
                this.isotopes[el.isotopes_idxs[0]].mass_number
                );
            widgets.label_rel_atomic_mass_0.set_label (
                this.isotopes[el.isotopes_idxs[0]].relative_atomic_mass
                );
            widgets.level_isotopic_composition_0.value = isocomp_to_double (
                this.isotopes[el.isotopes_idxs[0]].isotopic_composition
                );
            widgets.label_nuclear_spin_0.set_label (
                this.isotopes[el.isotopes_idxs[0]].spin
                );
            widgets.label_half_life_0.set_label (
                this.isotopes[el.isotopes_idxs[0]].thalf
                );
          } else {
            widgets.label_mass_number_0.set_label ("NULL");
            widgets.label_rel_atomic_mass_0.set_label ("NULL");
            widgets.level_isotopic_composition_0.value = 0.0;
            widgets.label_nuclear_spin_0.set_label ("NULL");
            widgets.label_half_life_0.set_label ("NULL");
          }

          if (el.isotopes_idxs.size > 1) {
            widgets.label_mass_number_1.set_label (
              this.isotopes[el.isotopes_idxs[1]].mass_number
              );
            widgets.label_rel_atomic_mass_1.set_label (
              this.isotopes[el.isotopes_idxs[1]].relative_atomic_mass
              );
            widgets.level_isotopic_composition_1.value = isocomp_to_double (
              this.isotopes[el.isotopes_idxs[1]].isotopic_composition
              );
            widgets.label_nuclear_spin_1.set_label (
              this.isotopes[el.isotopes_idxs[1]].spin
              );
            widgets.label_half_life_1.set_label (
              this.isotopes[el.isotopes_idxs[1]].thalf
              );
          } else {
            widgets.label_mass_number_1.set_label ("NULL");
            widgets.label_rel_atomic_mass_1.set_label ("NULL");
            widgets.level_isotopic_composition_1.value = 0.0;
            widgets.label_nuclear_spin_1.set_label ("NULL");
            widgets.label_half_life_1.set_label ("NULL");
          }

          if (el.isotopes_idxs.size > 2) {
            widgets.label_mass_number_2.set_label (
              this.isotopes[el.isotopes_idxs[2]].mass_number
              );
            widgets.label_rel_atomic_mass_2.set_label (
              this.isotopes[el.isotopes_idxs[2]].relative_atomic_mass
              );
            widgets.level_isotopic_composition_2.value = isocomp_to_double (
              this.isotopes[el.isotopes_idxs[2]].isotopic_composition
              );
            widgets.label_nuclear_spin_2.set_label (
              this.isotopes[el.isotopes_idxs[2]].spin
              );
            widgets.label_half_life_2.set_label (
              this.isotopes[el.isotopes_idxs[2]].thalf
              );
          } else {
            widgets.label_mass_number_2.set_label ("NULL");
            widgets.label_rel_atomic_mass_2.set_label ("NULL");
            widgets.level_isotopic_composition_2.value = 0.0;
            widgets.label_nuclear_spin_2.set_label ("NULL");
            widgets.label_half_life_2.set_label ("NULL");
          }

        }  // set_active_element_ui_widgets
	}  // ApplicationWindow
}
