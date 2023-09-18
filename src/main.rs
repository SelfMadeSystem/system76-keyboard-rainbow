use clap::Parser;
use std::{
    fs,
    process::exit,
    sync::{
        atomic::{AtomicBool, Ordering},
        Arc,
    },
    thread,
    time::Duration,
};

/// Automatic rainbow keyboard color changer for System76 laptops
#[derive(Parser)]
struct Opts {
    /// Set the color increment
    #[clap(short, long, default_value = "1")]
    color_increment: u8,
    /// Set the sleep time
    #[clap(short, long, default_value = "10")]
    sleep_time: u64,
}

const COLOR_PATH: &str = "/sys/class/leds/system76_acpi::kbd_backlight/color";
const BRIGHTNESS_PATH: &str = "/sys/class/leds/system76_acpi::kbd_backlight/brightness";

fn main() {
    let running = Arc::new(AtomicBool::new(true));
    let r = running.clone();

    // Get the initial color and brightness
    let initial_color_str = fs::read_to_string(COLOR_PATH).unwrap();
    let initial_brightness_str = fs::read_to_string(BRIGHTNESS_PATH).unwrap();

    // Trap Ctrl+C and reset the keyboard color and brightness
    ctrlc::set_handler(move || {
        r.store(false, Ordering::SeqCst);
    })
    .expect("Error setting Ctrl+C handler");

    // Set the current color to red
    let mut color_red = 255;
    let mut color_green = 0;
    let mut color_blue = 0;

    let opts = Opts::parse();

    // Set the color increment
    let color_increment = opts.color_increment;

    // Set the sleep time
    let sleep_time = Duration::from_millis(opts.sleep_time);

    // If the brightness is 0, set it to 255
    let initial_brightness: u8 = {
        let b = initial_brightness_str.trim().parse().unwrap_or(0);
        if b == 0 {
            fs::write(BRIGHTNESS_PATH, "255").unwrap();
            255
        } else {
            b
        }
    };

    // On the gaze18 keyboard, the max color value appears to be the value of the brightness
    // Please submit a PR if this is not the case for your keyboard
    let max_color: u8 = initial_brightness;

    // Function to reset the keyboard color and brightness
    fn reset_color(initial_color: &str, initial_brightness: &str) {
        fs::write(COLOR_PATH, initial_color).unwrap();
        fs::write(BRIGHTNESS_PATH, initial_brightness).unwrap();
        exit(0);
    }

    // Function to set the keyboard color
    fn set_color(color: &str) {
        fs::write(COLOR_PATH, color).unwrap();
    }

    // Function to get the hex value of the current color
    fn get_hex_color(red: u8, green: u8, blue: u8, max_color: u8) -> String {
        let red = (red as u32 * max_color as u32 / 255).min(max_color as u32);
        let green = (green as u32 * max_color as u32 / 255).min(max_color as u32);
        let blue = (blue as u32 * max_color as u32 / 255).min(max_color as u32);
        format!("{:02x}{:02x}{:02x}", red, green, blue)
    }

    // Function to increment the color
    fn increment_color(
        red: &mut u8,
        green: &mut u8,
        blue: &mut u8,
        color_increment: u8,
        sleep_time: Duration,
    ) {
        if *red == 255 && *green == 0 && *blue < 255 {
            // red change is a lot more noticeable than the other colors, so we slow it down
            if *blue < 24 {
                *blue += 1;
                thread::sleep(sleep_time);
                if *blue < 10 {
                    thread::sleep(sleep_time);
                }
            } else {
                *blue += color_increment;
            }
        } else if *red > 0 && *green == 0 && *blue == 255 {
            *red -= color_increment;
        } else if *red == 0 && *green < 255 && *blue == 255 {
            *green += color_increment;
        } else if *red == 0 && *green == 255 && *blue > 0 {
            *blue -= color_increment;
        } else if *red < 255 && *green == 255 && *blue == 0 {
            *red += color_increment;
        } else if *red == 255 && *green > 0 && *blue == 0 {
            if *green < 24 {
                *green -= 1;
                if *green < 10 {
                    thread::sleep(sleep_time);
                }
            } else {
                *green -= color_increment;
            }
        }

        // Make sure the color values are between 0 and 255
        *red = (*red).min(255);
        *green = (*green).min(255);
        *blue = (*blue).min(255);
    }

    // Loop through the colors of the rainbow
    while running.load(Ordering::SeqCst) {
        let hex_color = get_hex_color(color_red, color_green, color_blue, max_color);
        set_color(&hex_color);
        increment_color(
            &mut color_red,
            &mut color_green,
            &mut color_blue,
            color_increment,
            sleep_time,
        );
        thread::sleep(sleep_time);
    }
    reset_color(&initial_color_str, &initial_brightness_str);
}
