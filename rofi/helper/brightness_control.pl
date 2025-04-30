#!/usr/bin/env perl
use strict;
use warnings;

# Check if brightnessctl is available
die "brightnessctl not found. Please install it first.\n"
    unless system("which brightnessctl >/dev/null 2>&1") == 0;

my $config = "$ENV{HOME}/.config/rofi/helper/config.rasi";

# Get the current brightness using brightnessctl with error handling
my $current_brightness = `brightnessctl g 2>&1`;
if ($? != 0) {
    die "Failed to get current brightness: $current_brightness\n";
}
chomp($current_brightness);

# Calculate the maximum brightness for scaling
my $max_brightness = `brightnessctl m 2>&1`;
if ($? != 0) {
    die "Failed to get maximum brightness: $max_brightness\n";
}
chomp($max_brightness);

# Convert to percentage
$current_brightness = int(($current_brightness / $max_brightness) * 100);

# Define the options in the menu
my @options = map { "Brightness " . $_ * 10 . "%" } 1 .. 10;
unshift(@options, ("Brightness 1%", "Inc brightness 10%", "Dec brightness 10%"));
push(@options, "Blugon");

my $joined_options = join "\n", @options;
my $prompt = "Brightness ($current_brightness%)";
my $rofi_args = qq{-dmenu -config $config -p "$prompt" -i};

chomp(my $chosen = `echo "$joined_options" | rofi $rofi_args`);
exit unless $chosen;

print "Chosen option: $chosen\n";
my ($num) = $chosen =~ /(\d+)/;
my $new_brightness;

# Handle the different choices
if ($chosen =~ /Blugon/) {
    system("blugon && notify-send Blugon") == 0
        or warn "Failed to execute blugon: $?\n";
    exit;
} elsif ($chosen =~ /^a|inc/i) {
    $new_brightness = $current_brightness + $num;
    $new_brightness = 100 if $new_brightness > 100;
} elsif ($chosen =~ /^d|dec/i) {
    $new_brightness = $current_brightness - $num;
    $new_brightness = 0 if $new_brightness < 0;
} else {
    $new_brightness = $num;
}

# Calculate the new brightness as a percentage of max brightness
my $new_brightness_value = int(($new_brightness / 100) * $max_brightness);

# Set the new brightness using brightnessctl with error handling
my $result = system("brightnessctl set $new_brightness_value 2>/dev/null");
if ($result == 0) {
    system("notify-send Brightness $new_brightness%");
} else {
    system("notify-send 'Brightness Control' 'Failed to set brightness. Check permissions.'");
    die "Failed to set brightness. Error code: $?\n";
}
