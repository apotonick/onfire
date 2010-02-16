require 'rubygems'
require 'shoulda'
require 'onfire'

class Onfire::EventTable
  def size
    source2evt.inject(0)do |memo, evts| 
      memo + evts[1].inject(0) {|sum, h| sum + h[1].size} # h => [key, value].
    end || 0
  end
end