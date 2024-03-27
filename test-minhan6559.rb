require 'rover-df'
require 'numo/narray'
require 'ruby2d'
require 'savio'
require 'daru'
require 'benchmark'

set title: "Hello Triangle"
set width: 800
set height: 600
set background: "#1e1e1e"

time = Benchmark.measure do
    df = Rover.read_csv("./dataset/small_train.csv")
    x = df.to_numo
    p x.shape
end
puts time.real #or save it to logs
# show()