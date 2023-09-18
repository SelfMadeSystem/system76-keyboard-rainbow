# System76 Rainbow Keyboard

This is a simple program to have a rainbow keyboard on System76 laptops. It
should work on any System76 laptop with a backlit keyboard. Please report any
issues you have with it.

Tested on a System76 Gazelle (gaze18) laptop running Pop!_OS 22.04.

The brightness should already be set to what it was before running the program
when it exits. It should also automatically adjust when you change the
brightness with the keyboard. If it doesn't, please report it as an issue.

## Installation

You must install `rust` and `cargo` to build this program. You can install them
with `apt`:

```bash
sudo apt install rustc cargo
```

Then you can build and install the program with:

```bash
cargo install --git https://github.com/SelfMadeSystem/system76-keyboard-rainbow
```

To run the program, you need to add `~/.cargo/bin` to your `PATH`:

If using `bash`:

```bash
export PATH="$PATH:$HOME/.cargo/bin"
```

If using `fish`:

```fish
set -gx PATH $PATH $HOME/.cargo/bin
```

## Usage

The program must be run as root to access the following files:
- `/sys/class/leds/system76_acpi::kbd_backlight/color`
- `/sys/class/leds/system76_acpi::kbd_backlight/brightness`

If you don't want to run the program as root, you can change the permissions of
these files. I run it as root because I'm lazy. You can probably figure out how
to do this yourself.

You can run the program with:

```bash
system76-keyboard-rainbow
```

You can also run it in the background with:

```bash
system76-keyboard-rainbow &
```

### Options

You can change the sleep time of the rainbow with the `-s` or `--sleep-time`
option (in milliseconds). For example, to have a 0.1 second sleep time:

```bash
system76-keyboard-rainbow -s 100
```

You can also change the color increment with the `-c` or `--color-increment`
option. For example, to have a 10 increment:

```bash
system76-keyboard-rainbow -c 10
```

## What's the `keyboard_led_rainbow.sh` file?

That's the original script I wrote to do this. It took up to 10% of my CPU when
running, so I decided to rewrite it in Rust. I'm keeping it here for posterity.

## License

This program is licensed under the MIT license. See the [LICENSE](LICENSE.md) file
for more information.
