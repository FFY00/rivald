inc = include_directories('.')

# Library
rivaldlib_sources = [
    'rivald/cycle.d',
    'rivald/device.d',
    'rivald/error.d',
    'rivald/util.d',
    'rivald/values.d'
    ]
rivaldlib = static_library('rivald',
                        rivaldlib_sources,
                        include_directories: inc,
                        dependencies: hidapid_dep,
                        install : true)

# Install files from sources array
# Loop needed as meson doesn't preserve the path for some reason
# See: https://github.com/mesonbuild/meson/issues/3371
include_subdir = 'rivald'
foreach file : rivaldlib_sources
    file_path = file.split('/')

    # Extract folder
    folder_path = []
    foreach path : file_path
        if path != file_path[-1]
            folder_path += path
        endif
    endforeach

    folder = join_paths(folder_path)
    install_headers(file, subdir: join_paths(include_subdir, folder))
endforeach
