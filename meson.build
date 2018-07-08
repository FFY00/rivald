project('rivald', 'd',
    version: '0.0.0',
    license: 'GPLv3')

# Dependency versions
hidapid_ver = '>=1.0.2'

# Depencencies
hidapid_dep = dependency('hidapi-d',
                            version: hidapid_ver,
                            required: false)

if not hidapid_dep.found()
    hidapid_dep = dependency('hidapi-d',
                                version: hidapid_ver,
                                method: 'dub')
endif

# Subdirs
subdir('source')
#subdir('tests')
subdir('tool')

# Generate dub.json
dub_sources = []
foreach path : rivaldlib_sources
    dub_sources += join_paths('source', path)
endforeach

use_dub = false # Until my PR is merged :/
if use_dub
dlang = import('dlang')
dlang.generate_dub_file(meson.project_name().to_lower(), meson.source_root(),
                        authors: 'Filipe Laíns',
                        description: 'Library to interface with the Steelseries Rival 310 mouse',
                        copyright: 'Copyright © 2018, Filipe Laíns',
                        license: meson.project_license(),
                        sourceFiles: dub_sources
#                        dependencies: hidapid_dep
)
endif
