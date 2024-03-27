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

time = Benchmark.measure do
    df = Polars.read_csv("./dataset/mnist_train.csv")
    x = df.to_numo
    p x
end
puts time.real