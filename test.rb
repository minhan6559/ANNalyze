require 'rover-df'
require 'numo/narray'
require 'ruby2d'
require 'savio'
require 'polars-df'
require 'benchmark'

set title: "Hello Triangle"
set width: 800
set height: 600
set background: "#1e1e1e"

class ANN
    attr_accessor :dict
    def initialize()
        @dict = {}
    end
end

model = ANN.new()
model.dict['W1'] = Numo::DFloat.new(3, 2).seq
model.dict['W1'] -= Numo::DFloat.new(3, 2).seq

m = 2
p 1 / (m.to_f)