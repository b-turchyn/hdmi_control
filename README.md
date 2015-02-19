# HDMI Controller

Sinatra app to control Monoprice's 4x4 HDMI Matrix Mixer (PID# 5704) over HTTP

This was tested on the [4X4 True Matrix HDMI® Powered Switch w/ Remote (Rev. 3.0)](http://www.monoprice.com/Product?p_id=5704). It should also work on the [4x2 True Matrix HDMI® Switch w/ Remote (Rev. 3.0)](http://www.monoprice.com/Product?p_id=5312), but has not been tested on it.

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
