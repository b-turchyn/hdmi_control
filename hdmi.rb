#!/usr/bin/env ruby
require 'sinatra/base'
require 'shotgun'
require 'haml'
require 'serialport'

class Connection
  @name = nil
  @id = nil

  def initialize(name, id)
    @name, @id = name, id.to_s
  end

  def name
    @name
  end

  def id
    @id
  end
end

class Output < Connection
end
class Input < Connection
end

class HDMIControl < Sinatra::Base
  set :environment, :production
  set :bind, '0.0.0.0'
  set :logging, true

  # Edit the inputs and outputs for what you have. Keep them in order please!
  # Anything you don't need can be removed safely.
  INPUTS = [
    Input.new('HTPC', 1),
    Input.new('PS3', 2),
    Input.new('Wii U', 3),
    Input.new('Computer', 4)
  ]

  OUTPUTS = [
    Output.new('Living Room', 'A'),
    Output.new('Bedroom', 'B'),
    Output.new('Basement', 'C'),
    Output.new('Server Rack', 'D')
  ]
  # No need to edit below this!

  # Haven't figured out how to query the mixer, so this will have to do
  set :last_inputs, { }

  ENDING_BYTES = %w(d5 7b)
  HEX_STYLE = "%02x"

  get '/' do
    @last_inputs = settings.last_inputs
    @inputs = INPUTS
    @outputs = OUTPUTS
    @column_class = column_class
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
    output_offset = find_offset(OUTPUTS, output)
    input_offset = find_offset(INPUTS, input)
    if output_offset != nil && input_offset != nil
      result = (output_offset * 4) + input_offset
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

  def column_class
    'col-md-' + (OUTPUTS.length > 4 ? 3 : 12 / OUTPUTS.length).to_s
  end

  def find_offset(haystack, needle)
    haystack.index { |i| i.id === needle.to_s }
  end

end

HDMIControl.run!
#/EOF
