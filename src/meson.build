gotosi_gtk_sources = [
  'main.vala',
  'window.vala',
  'parse.vala',
  'treeview.vala',
  'headerbar.vala',
]

gotosi_gtk_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('json-glib-1.0'),
  dependency('gee-0.8'),
]

gnome = import('gnome')

gotosi_gtk_sources += gnome.compile_resources('gotosi_gtk-resources',
  'gotosi_gtk.gresource.xml',
  c_name: 'gotosi_gtk'
)

executable('gotosi-gtk', gotosi_gtk_sources,
  vala_args: '--target-glib=2.50',  dependencies: gotosi_gtk_deps,
  install: true,
)
