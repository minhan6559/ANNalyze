require 'numo/narray'
require 'ruby2d'
require 'savio'
require 'polars-df'
require 'benchmark'
# require_relative './ANN_algorithms/Model'

set title: "MNIST Inferencer"
set width: 800
set height: 600
set background: "#1e1e1e"

input = Numo::DFloat.zeros(784, 1)
#draw canvas
28.times do |i|
    28.times do |j|
        x = j * 16
        y = i * 16
        Square.new(x: x, y: y, size: 15, color: 'black')
    end
end

start_btn = Sprite.new(
    './images/StartButton.png',
    x: 120, y: 460,
    clip_width: 422/2,
    time: 150
)

on :key_held do |event|
    x = get :mouse_x
    y = get :mouse_y

    if event.key == 'space' and x < 448 and y < 448
        i = y / 16
        j = x / 16
        Square.new(x: j * 16, y: i * 16, size: 15, color: 'white')
        input[i * 28 + j, 0] = 1
    end
end

on :mouse_down do |event|
    x = get :mouse_x
    y = get :mouse_y

    if event.button == :left and x >= 120 and x <= (120 + 211) and y >= 460 and y <= (460 + 54)
        start_btn.play
        output = predict(input, model).to_s
        Text.new(
            output,
            x: 460, y: 448/2,
            style: 'bold',
            size: 18,
            color: 'white',
            z: 10
        )
    end
end

a = Numo::DFloat[[1, 2], [3, 4]]
b = Numo::DFloat[[5, 6], [7, 8]]
m = a.shape[1]

p Numo::NMath.sqrt(a)
# show()
