class TrainingScreen
    attr_accessor :x_train, :y_train, :x_val, :y_val, :model, :batch_size, :learning_rate, :epochs, :epoch, :need_load_model, :done_training, :cost, :accu
    def initialize()
        @x_train, @y_train, @x_val, @y_val = load_dataset()
        @epoch = 0
        @cost = 0.0
        @accu = 0.0
        @need_load_model = true
        @done_training = false
    end
end

def load_dataset()
    x_train = load_bin_dataset("10000_X_train")
    y_train = load_bin_dataset("10000_Y_train")
    x_val = load_bin_dataset("X_val")
    y_val = load_bin_dataset("Y_val")

    return x_train, y_train, x_val, y_val
end

def load_building_screen_configs(training_screen, building_screen)
    nodes_per_layer = building_screen.nodes_per_layer.clone
    activations = building_screen.activations.clone

    nodes_per_layer << 10
    activations << Activation::SOFTMAX

    training_screen.model = ANN.new(nodes_per_layer, activations)
    training_screen.batch_size = building_screen.batch_size
    training_screen.learning_rate = building_screen.learning_rate
    training_screen.epochs = building_screen.epochs
end

def draw_input(input)
    28.times do |i|
        28.times do |j| 
            x = j * 11 + 27
            y = i * 11 + 221
            color = input[i * 28 + j, 0]
            Square.new(x: x, y: y, size: 10, color: [color, color, color, 1])
        end
    end
end

def draw_network_with_input(input, model)
    draw_input(input)

    layer_values = single_input_forward(input, model)

    # Draw network
    nodes_per_layer = model.nodes_per_layer
    x_start = 400 + (481.5 - (nodes_per_layer.length * 180 + 63) / 2.0)
    nodes_per_layer.each_with_index do |num_nodes, i|
        # Layer index
        y = 74
        if i == nodes_per_layer.length - 1
            y = 106
        end
        layer_text = "Layer #{i + 1}"
        if i == nodes_per_layer.length - 1
            layer_text = "Output"
        end
        Text.new(
            layer_text,
            x: x_start - 23 + i * 180, y: y,
            font: './fonts/SF-Pro-Display-Bold.otf',
            size: 24,
            color: 'aqua'
        )

        # Layer activations
        activation_name = nil
        x_minus = 0
        case model.activations[i]
        when Activation::RELU
            activation_name = 'ReLU'
        when Activation::SIGMOID
            activation_name = 'Sigmoid'
            x_minus = 9
        when Activation::TANH
            activation_name = 'Tanh'
            x_minus = -2
        when Activation::SOFTPLUS
            activation_name = 'Softplus'
            x_minus = 9
        when Activation::SOFTMAX
            activation_name = 'Softmax'
            x_minus = 9
        end

        y = 109
        if i == nodes_per_layer.length - 1
            y = 137
        end

        Text.new(
            activation_name,
            x: x_start - 10 + i * 180 - x_minus, y: y,
            font: './fonts/SF-Pro-Display-Medium.otf',
            size: 20,
            color: 'white'
        )

        # Border
        if i == nodes_per_layer.length - 1
            Image.new(
                './images/Network/Output_border.png',
                x: x_start - 19 + i * 180, y: 170
            )
        else
            Image.new(
                './images/Network/Layer_border.png',
                x: x_start - 19 + i * 180, y: 140
            )
        end

        # Nodes
        y = 160 + (215 - (min(num_nodes, 11) * 40 - 10) / 2.0)
        if i == nodes_per_layer.length - 1
            y = 182
        end
        x = x_start + i * 180

        if num_nodes > 11
            Image.new(
                './images/Network/More_nodes.png',
                x: x + 12, y: y + 5 * 40
            )
        end

        min(num_nodes, 11).times do |j|
            if j == 5 and num_nodes > 11
                next
            end
            node_value = layer_values[i][j, 0]
            if num_nodes > 11 and j > 5
                node_value = layer_values[i][j - 11, 0]
            end
            opacity = max(node_value.abs, 0.18)
            Square.new(
                x: x, y: y + j * 40,
                size: 30,
                color: 'white',
                opacity: opacity
            )

            # Draw connection
            if i != nodes_per_layer.length - 1
                next_num_nodes = nodes_per_layer[i + 1]
                min(next_num_nodes, 11).times do |k|
                    if k == 5 and next_num_nodes > 11
                        next
                    end
                    next_node_value = layer_values[i + 1][k, 0]
                    if next_num_nodes > 11 and k > 5
                        next_node_value = layer_values[i + 1][k - 11, 0]
                    end
                    line_opacity = max(0.18, min(node_value.abs, next_node_value.abs))
                    y2 = 160 + (215 - (min(next_num_nodes, 11) * 40 - 10) / 2.0) + k * 40 + 15
                    if i == nodes_per_layer.length - 2
                        y2 = 182 + k * 40 + 15
                    end
                    Line.new(
                        x1: x + 30, y1: y + j * 40 + 15,
                        x2: x + 180, y2: y2,
                        width: 1,
                        color: 'white',
                        opacity: line_opacity,
                        z: line_opacity
                    )
                end
            end
        end

        # Number of nodes
        num_nodes_text = num_nodes.to_s
        x_minus = 0
        case num_nodes_text.length
        when 2
            x_minus = 6
        when 3
            x_minus = 15
        end

        y = 611
        if i == nodes_per_layer.length - 1
            y = 593
        end

        Text.new(
            num_nodes_text,
            x: x_start + 6 + i * 180 - x_minus, y: y,
            font: './fonts/SF-Pro-Display-Semibold.otf',
            size: 26,
            color: 'white'
        )
    end
end

def draw_progress_bar(training_screen)
    if training_screen.done_training
        Image.new(
            './images/TrainingScreen/Progress_bar_complete.png',
            x: 31, y: 100
        )
    else
        progress = (training_screen.epoch.to_f / training_screen.epochs)
        progress_text = (progress * 100).to_s[0...4]

        Text.new(
            "Progress: #{progress_text}%",
            x: 94, y: 114,
            font: './fonts/SF-Pro-Display-Semibold.otf',
            size: 25,
            color: 'white'
        )

        Sprite.new(
            './images/TrainingScreen/Progress_inner.png',
            x: 31, y: 162,
            clip_width: 300 * progress
        )

        Image.new(
            './images/TrainingScreen/Progress_border.png',
            x: 31, y: 162
        )
    end
end

def draw_training_info(training_screen)
    # Draw input
    random_index = rand(0...training_screen.x_train.shape[1])
    input = training_screen.x_train[true, random_index].reshape(784, 1)

    draw_progress_bar(training_screen)
    draw_network_with_input(input, training_screen.model)

    cost = training_screen.cost
    accu = training_screen.accu

    epoch_text = "Epoch: #{training_screen.epoch}"
    x_minus = 0
    if epoch_text.length == 9
        x_minus = 5
    elsif epoch_text.length >= 10
        x_minus = 10
    end
    Text.new(
        epoch_text,
        x: 135 - x_minus, y: 547,
        font: './fonts/SF-Pro-Display-Semibold.otf',
        size: 25,
        color: 'white'
    )

    Text.new(
        "Cost: #{cost.round(6).to_s[0...5]}",
        x: 120, y: 587,
        font: './fonts/SF-Pro-Display-Semibold.otf',
        size: 25,
        color: 'white'
    )

    Text.new(
        "Accuracy: #{accu.round(3).to_s[0...4]}",
        x: 99, y: 625,
        font: './fonts/SF-Pro-Display-Semibold.otf',
        size: 25,
        color: 'white'
    )

end

def render_training_screen(cur_screen, training_screen)
    clear()

    # Nav bar
    Image.new(
        './images/TrainingScreen/Nav_bar.png',
        x: 0, y: 0, z: -1
    )

    if training_screen.done_training
        home_btn = create_button(
            './images/MainMenu/Home_button.png',
            1171, 10, 55, 47, cur_screen, ScreenType::TRAINING_SCREEN
        )
    end

    draw_training_info(training_screen)
    if not training_screen.done_training
        training_screen.cost, training_screen.accu = single_step_train(training_screen)
        training_screen.epoch += 1
        cur_screen.render_again = true
        if training_screen.epoch == training_screen.epochs
            training_screen.done_training = true
        end
    end

end