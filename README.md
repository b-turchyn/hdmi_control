# HDMI Controller
Sinatra app to control Monoprice's 4x4 HDMI Matrix Mixer over HTTP

# Installation

    git clone https://github.com/b-turchyn/hdmi_control.git
    cd hdmi_control
    bundle

# Configuration

 * Edit `hdmi.rb` to change the names of your inputs and outputs

# Usage

By default, this runs in production mode in the foreground. Run inside `screen`
or `tmux` if you want to run in the background.

    ./hdmi.rb

# License

This software is licenced under the MIT Licence.
