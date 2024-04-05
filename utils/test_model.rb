require 'numo/narray'
require 'ruby2d'
require 'savio'
require 'benchmark'
require_relative '../ANN/Model'
require_relative '../UI/Utils'

if __FILE__ == $0
    set title: "MNIST"
    set width: 1250
    set height: 720
    
    set background: "#252526"
    
    input = Numo::DFloat.zeros(784, 1)
    model = load_model("full_train_model_256_128")
    outputText = nil

    28.times do |i|
        28.times do |j| 
            x = j * 16
            y = i * 16
            Square.new(x: x, y: y, size: 15, color: 'black')
        end
    end
    
    start_btn = Sprite.new(
        './images/BuildingScreen/Start_button.png',
        x: 120, y: 460,
        clip_width: 133,
        time: 150,
        animations: {
            not_hover: 0..0,
            hover: 1..1
        }
    )

    mouse_released = true
    on :mouse_down do |event|
        mouse_released = false
    end

    on :mouse_up do |event|
        mouse_released = true
    end

    on :mouse_move do |event|
        x = get :mouse_x
        y = get :mouse_y
        if not mouse_released and x < 448 and y < 448
            i = y / 16
            j = x / 16
            input[i * 28 + j, 0] = min(1.0, input[i * 28 + j, 0] + 230.0 / 255.0)
            color = input[i * 28 + j, 0]
            Square.new(x: j * 16, y: i * 16, size: 15, color: [color, color, color, 1])
    
            # Fill the surrounding pixels
            if i + 1 < 28 && j + 1 < 28
                input[(i + 1) * 28 + (j + 1), 0] = min(1.0, input[(i + 1) * 28 + (j + 1), 0] + 230.0 / 255.0)
                color = input[(i + 1) * 28 + (j + 1), 0]
                Square.new(x: (j + 1) * 16, y: (i + 1) * 16, size: 15, color: [color, color, color, 1])
            end
            
            if i + 1 < 28
                input[(i + 1) * 28 + j, 0] = min(1.0, input[(i + 1) * 28 + j, 0] + 110.0 / 255.0)
                color = input[(i + 1) * 28 + j, 0]
                Square.new(x: j * 16, y: (i + 1) * 16, size: 15, color: [color, color, color, 1])
            end
            
            if j + 1 < 28
                input[i * 28 + (j + 1), 0] = min(1.0, input[i * 28 + (j + 1), 0] + 110.0 / 255.0)
                color = input[i * 28 + (j + 1), 0]
                Square.new(x: (j + 1) * 16, y: i * 16, size: 15, color: [color, color, color, 1])
            end
        end
    end

    on :mouse_down do |event|
        x = get :mouse_x
        y = get :mouse_y
    
        if event.button == :left and x >= 120 and x <= (120 + 211) and y >= 460 and y <= (460 + 54)
            output = predict(input, model).to_s
            
            if outputText != nil
                # Clear the output text
                outputText.remove()
            end

            # Draw the output text
            outputText = Text.new(
                output,
                x: 460, y: 448/2,
                style: 'bold',
                size: 18,
                color: 'white',
                z: 10
            )
        end
    end
    
    on :mouse_move do |event|
        x = event.x
        y = event.y

        if x >= 120 and x <= (120 + 211) and y >= 460 and y <= (460 + 54)
            start_btn.play(animation: :hover, loop: true)
        else
            start_btn.play(animation: :not_hover, loop: true)
        end
    end
    show()
end
