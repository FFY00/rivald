# rivald

Library (and cli tool) to interface with the Steelseries Rival 310 mouse

##### TODO
  * rivaltool
  * Buttons/Macros
  * Button report

## Build

```
mkdir build
cd build
meson ..
```
###### You should also be able to build this with dub

#### Dependencies
  * [hidapi-d](https://github.com/FFY00/hidapi-d)

#### Compiler
This project was tested with [DMD](https://github.com/dlang/dmd) and [LDC](https://github.com/ldc-developers/ldc) backends.

If you want to change the compiler.
```
DC=ldc meson ..
```

## Protocol Information
See [rival310-re](https://github.com/FFY00/rival310-re).

### Related Projects
  * [RivalGUI](https://github.com/FFY00/rivalgui) - GTK+ based tool to configure the Steelseries Rival 310 mouse. (via rivald)
  * [libratbag](https://github.com/libratbag/libratbag) - A DBus daemon to configure gaming mice.
  * [piper](https://github.com/libratbag/piper) - GTK+ application to configure gaming mice, using libratbag via ratbagd.
  * [rivalcfg](https://github.com/flozz/rivalcfg) - Small CLI utility program that allows you to configure SteelSeries Rival gaming mice.

#### Driver backend comparison (Steelseries Rival 310 only)

Backend | LEDs | DPI | Report Rate | Read Values | Buttons (Macros) | Button Report
:---: | :---: | :---: | :---: | :---: | :---: | :---:
***Official Driver*** | Partial (**90%**) | **Full** | **Full** | **Full** |  **Full** | *None*
**rivald** | **Full** | **Full** | **Full** | **Full** [1] | *None* (yet) | *None* (yet)
libratbag | Partial (**70%**) | **Full** | **Full** | *None* | Partial (**90%**) | *None*
rivalcfg | *None* (yet) | **Full** | *None* | *None* | *None* | *None*

**[1]**
Supports everything currently known. There isn't any official information regarding the protocol. All of the public knowledge regarding it was obtained via reverse engineering. This can be hard especially when reading values from the device.

#### Applications

Application | Backend | Type | Backend Type | Operating Systems
:---: | :---: | :---: | :---: | :---:
rivaltool | *rivald* | CLI | Standalone | Linux, *Window** and *MacOS**
RivalGUI | *rivald* | GUI | Hybrid [1] | Linux, *Window** and *MacOS**
Piper | libratbag | GUI | Daemon | Linux
ratbagctl | libratbag | CLI | Daemon | Linux
rivalcfg | rivalcfg | CLI | Standalone | Linux, *Window** and *MacOS**

__*__
Not tested

**[1]**
RivalGUI uses the *rivald* backend but is (not yet, will be) compatible with `ratbagd` (libratbag's daemon).

### License
This software is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html).

### Author(s)
  * Filipe Laíns (FFY00) - Main contributor (*base software and reverse engineering*)