class TrainingScreen
    attr_accessor :x_train, :y_train, :x_test, :y_test, :model, :batch_size, :learning_rate, :epochs, :epoch, :need_load_model, :done_training, :cost, :accu
    def initialize()
        @x_train, @y_train, @x_test, @y_test = load_dataset()
        @epoch = 0
        @cost = 0.0
        @accu = 0.0
        @need_load_model = true
        @done_training = false
    end
end

def reset_training_screen(training_screen)
    training_screen.epoch = 0
    training_screen.cost = 0.0
    training_screen.accu = 0.0
    training_screen.need_load_model = true
    training_screen.done_training = false
end

def load_dataset()
    x_train = load_bin_dataset("10000_X_train")
    y_train = load_bin_dataset("10000_Y_train")
    x_test = load_bin_dataset("X_val")
    y_test = load_bin_dataset("Y_val")

    return x_train, y_train, x_test, y_test
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

    training_screen.need_load_model = false
end

def get_accuracy(training_screen)
    aL, _ = forward_prop(training_screen.x_test, training_screen.model)
    return compute_accuracy(aL, training_screen.y_test)
end

def single_step_train(training_screen)
    m = training_screen.x_train.shape[1]
    batch_size = training_screen.batch_size

    permutated_indexes = (0...m).to_a.shuffle
    shuffled_X = training_screen.x_train[true, permutated_indexes].reshape(784, m)
    shuffled_Y = training_screen.y_train[true, permutated_indexes].reshape(10, m)

    total_cost = 0
    num_complete_minibatches = (m / batch_size).to_i
    for k in 0...num_complete_minibatches
        mini_batch_X = shuffled_X[true, k * batch_size...(k+1) * batch_size]
        mini_batch_Y = shuffled_Y[true, k * batch_size...(k+1) * batch_size]

        aL, cache = forward_prop(mini_batch_X, training_screen.model)
        total_cost += compute_cost(aL, mini_batch_Y)
        grads = back_prop(aL, mini_batch_Y, cache, training_screen.model)
        update_params_with_gd(training_screen.model, training_screen.learning_rate, grads)
    end

    if m % batch_size != 0
        mini_batch_X = shuffled_X[true, num_complete_minibatches * batch_size...m]
        mini_batch_Y = shuffled_Y[true, num_complete_minibatches * batch_size...m]

        aL, cache = forward_prop(mini_batch_X, training_screen.model)
        total_cost += compute_cost(aL, mini_batch_Y)
        grads = back_prop(aL, mini_batch_Y, cache, training_screen.model)
        update_params_with_gd(training_screen.model, training_screen.learning_rate, grads)
    end
    
    avg_cost = total_cost / (num_complete_minibatches + (m % batch_size != 0 ? 1 : 0))
    
    accu = get_accuracy(training_screen)
    return avg_cost, accu
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

def draw_network_with_input(input, model, has_input = true)
    draw_input(input)

    layer_values = single_input_forward(input, model)

    # Draw network
    nodes_per_layer = model.nodes_per_layer
    x_start = 400 + (481.5 - (nodes_per_layer.length * 180 + 63) / 2.0)
    nodes_per_layer.each_with_index do |num_nodes, i|
        # Layer index
        y = 88
        if i == nodes_per_layer.length - 1
            y = 120
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

        y = 123
        if i == nodes_per_layer.length - 1
            y = 151
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
                x: x_start - 19 + i * 180, y: 184
            )
        else
            Image.new(
                './images/Network/Layer_border.png',
                x: x_start - 19 + i * 180, y: 154
            )
        end

        # Nodes
        y = 174 + (215 - (min(num_nodes, 11) * 40 - 10) / 2.0)
        if i == nodes_per_layer.length - 1
            y = 196
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

            opacity = 1
            if has_input
                opacity = max(node_value.abs, 0.18)
            end
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

                    line_opacity = 0.2
                    if has_input
                        line_opacity = max(0.18, min(node_value.abs, next_node_value.abs))
                    end
                    y2 = 174 + (215 - (min(next_num_nodes, 11) * 40 - 10) / 2.0) + k * 40 + 15
                    if i == nodes_per_layer.length - 2
                        y2 = 196 + k * 40 + 15
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

        y = 625
        if i == nodes_per_layer.length - 1
            y = 607
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
    draw_network_with_input(input, training_screen.model, true)

    cost = training_screen.cost
    accu = training_screen.accu

    if not training_screen.done_training
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
    else
        Text.new(
            "Model name: ",
            x: 27, y: 587,
            font: './fonts/SF-Pro-Display-Semibold.otf',
            size: 25,
            color: 'white'
        )
    end

    y_accu = 625
    if training_screen.done_training
        y_accu = 547
    end
    accu_text = "Accuracy: #{accu.round(2)}"
    if accu_text.length < 14
        accu_text += "0" * (14 - accu_text.length)
    end
    Text.new(
        accu_text,
        x: 99, y: y_accu,
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
    
    draw_training_info(training_screen)

    if not training_screen.done_training
        training_screen.cost, training_screen.accu = single_step_train(training_screen)
        training_screen.epoch += 1
        cur_screen.render_again = true
        if training_screen.epoch == training_screen.epochs
            training_screen.done_training = true
        end
    else
        home_btn = create_button(
            './images/MainMenu/Home_button.png',
            1171, 10, 55, 47, cur_screen, ScreenType::TRAINING_SCREEN
        )

        save_btn = create_button(
            './images/TrainingScreen/Save_button.png',
            88, 630, 186, 45, cur_screen, ScreenType::TRAINING_SCREEN
        )

        model_name_box = InputBox.new(
            x: 175, y: 590,
            displayName: "model_name",
            height: 200, length: 160,
            size: 20,
            color: 'white', inactiveTextColor: 'black',
            activeColor: 'white', activeTextColor: 'black'
        )

        success_text = nil

        cur_screen.mouse_events << on(:mouse_down) do |event|
            case cur_screen.type
            when ScreenType::TRAINING_SCREEN
                if is_clicked?(home_btn, event)
                    change_screen(cur_screen, ScreenType::MAIN_MENU)
                    reset_training_screen(training_screen)
                end
                if is_clicked?(save_btn, event)
                    model_name = model_name_box.value
                    if model_name.nil? or model_name.empty?
                        model_name = model_name_box.displayName
                    end
                    save_model(training_screen.model, model_name)

                    if not success_text.nil?
                        success_text.remove()
                    end

                    success_text = Text.new(
                        "Saved as \"#{model_name}\"",
                        x: 120 - model_name.length * 4, y: 680, size: 20,
                        font: './fonts/SF-Pro-Display-Semibold.otf',
                        color: 'teal'
                    )
                end
            end
        end
    end

end