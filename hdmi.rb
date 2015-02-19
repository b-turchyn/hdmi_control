#!/usr/bin/env ruby
require 'sinatra/base'
require 'shotgun'
require 'haml'
require 'serialport'

class HDMIControl < Sinatra::Base
  set :environment, :production

  # Edit INPUT_NAMES and OUTPUT_NAMES to match your inputs and outputs
  INPUT_NAMES = [
    'HTPC',
    'PS3',
    'Wii U',
    'Computer'
  ]

  OUTPUT_NAMES = [
    'Living Room',
    'Bedroom',
    'Basement',
    'Server Rack'
  ]

  # No need to edit below this!


  # Haven't figured out how to query the mixer, so this will have to do
  set :last_inputs, {
    'A' => nil,
    'B' => nil,
    'C' => nil,
    'D' => nil
  }


  OFFSET_OUTPUT = %w(A B C D)
  OFFSET_INPUT = %w(1 2 3 4)
  ENDING_BYTES = %w(d5 7b)
  HEX_STYLE = "%02x"

  get '/' do
    @last_inputs = settings.last_inputs
    @inputs = INPUT_NAMES
    @outputs = OUTPUT_NAMES
    haml :index
  end

  post '/change/:set' do

    result = get_hex_code(params[:set])
    bytes = build_bytes(result)

    # Seems to work more reliably if burst requests are sent.
    # Specification dictates > 50ms delay between messages. We use 100ms.
    send_to_serial(bytes)

    redirect '/', 303
  end

  def get_hex_code(channel)
    output = channel[0]
    input = channel[1]
    result = nil

    # If it's a known channel, convert. Otherwise use RAW
    if OFFSET_OUTPUT.include?(output) && OFFSET_INPUT.include?(input)
      result = (OFFSET_OUTPUT.index(output) * 4) + OFFSET_INPUT.index(input)
      # Remember what the input was
      settings.last_inputs[output] = input
    else
      result = params[:set].to_i(16)
    end

    result
  end

  def build_bytes(result)
    order = HEX_STYLE % result
    inv_order = HEX_STYLE % (255 - result)

    pre_bytes = [order, inv_order].concat(ENDING_BYTES).join
    [pre_bytes].pack('H*')
  end

  def send_to_serial(bytes)
    out = SerialPort.new('/dev/ttyS0', baud: 2600, data_bits: 8, dtr: 1)
    2.times do
      puts out.write(bytes)
      sleep 0.1
    end
  end

end

HDMIControl.run!
#/EOF
