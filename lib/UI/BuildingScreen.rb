class BuildingScreen
    attr_accessor :nodes_per_layer, :activations, :batch_size, :learning_rate, :epochs, :error_message
    def initialize()
        @nodes_per_layer = []
        @activations = []
        @batch_size = 64
        @learning_rate = 0.05
        @epochs = 20
        @error_message = nil
    end
end

def create_radio_activations(selected_value = Activation::RELU)
    selected_value = Activation::RELU if selected_value.nil?
    btn_manager = ButtonManager.new(type: 'radio')

    relu_btn = Button.new(
        x: 900, y: 271,
        selectedColor: "aqua",
        buttonManager: btn_manager,
        size: 8
    )
    relu_btn.value = Activation::RELU

    sigmoid_btn = Button.new(
        x: 995, y: 271,
        selectedColor: "aqua",
        buttonManager: btn_manager,
        size: 8
    )
    sigmoid_btn.value = Activation::SIGMOID

    tanh_btn = Button.new(
        x: 900, y: 305,
        selectedColor: "aqua",
        buttonManager: btn_manager,
        size: 8
    )
    tanh_btn.value = Activation::TANH

    softplus_btn = Button.new(
        x: 995, y: 305,
        selectedColor: "aqua",
        buttonManager: btn_manager,
        size: 8
    )
    softplus_btn.value = Activation::SOFTPLUS

    btn_manager.buttons.each do |btn|
        if btn.value == selected_value
            btn_manager.select(btn)
        end
    end
    return btn_manager
end

def remove_radio_activations(activations_btn)
    activations_btn.buttons.each do |btn|
        btn.remove
    end
end

def get_selected_activation(activations_btn)
    activations_btn.selected.each do |button|
        return button.value.to_i
    end
end

def draw_network_building_screen(cur_screen, building_screen)
    building_screen.nodes_per_layer.each_with_index do |num_nodes, i|
        # Layer index
        Text.new(
            "Layer #{i + 1}",
            x: 111 + i * 180, y: 74,
            font: './fonts/SF-Pro-Display-Bold.otf',
            size: 24,
            color: 'aqua'
        )

        # Layer activations
        activation_name = nil
        x_minus = 0
        case building_screen.activations[i]
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
        end

        Text.new(
            activation_name,
            x: 124 + i * 180 - x_minus, y: 109,
            font: './fonts/SF-Pro-Display-Medium.otf',
            size: 20,
            color: 'white'
        )

        # Border
        Image.new(
            './images/Network/Layer_border.png',
            x: 115 + i * 180, y: 140
        )

        y_start = 160 + (215 - (min(num_nodes, 11) * 40 - 10) / 2.0)
        x = 134 + i * 180

        min(num_nodes, 11).times do |j|
            if num_nodes > 11 and j == 5
                Image.new(
                    './images/Network/More_nodes.png',
                    x: x + 12, y: y_start + j * 40
                )
            else
                Square.new(
                    x: x, y: y_start + j * 40,
                    size: 30,
                    color: 'white'
                )
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
        Text.new(
            num_nodes.to_s,
            x: 140 + i * 180 - x_minus, y: 611,
            font: './fonts/SF-Pro-Display-Semibold.otf',
            size: 26,
            color: 'white'
        )

        # Remove button
        remove_btn = create_button(
            './images/BuildingScreen/Remove_button.png',
            123 + i * 180, 667, 52, 32, cur_screen, ScreenType::BUILDING_SCREEN
        )

        cur_screen.mouse_events << on(:mouse_down) do |event|
            case cur_screen.type
            when ScreenType::BUILDING_SCREEN
                if is_clicked?(remove_btn, event)
                    building_screen.nodes_per_layer.delete_at(i)
                    building_screen.activations.delete_at(i)
                    building_screen.error_message = nil
                    cur_screen.render_again = true
                end
            end
        end
    end
end

def render_building_screen(cur_screen, building_screen)
    clear()
    draw_network_building_screen(cur_screen, building_screen)
    
    # Background
    Image.new(
        './images/BuildingScreen/Building_screen_background.png',
        x: 0, y: 0, z: -1
    )

    start_btn = create_button(
        './images/BuildingScreen/Start_button.png',
        981, 598, 133, 58, cur_screen, ScreenType::BUILDING_SCREEN
    )

    home_btn = create_button(
        './images/MainMenu/Home_button.png',
        1171, 10, 55, 47, cur_screen, ScreenType::BUILDING_SCREEN
    )

    # ANN configs buttons
    add_btn = create_button(
        './images/BuildingScreen/Add_button.png',
        1138, 186, 64, 68, cur_screen, ScreenType::BUILDING_SCREEN
    )
    activations_btn = create_radio_activations(building_screen.activations[-1] || Activation::RELU)
    num_nodes_box = create_text_box(895, 184, 180, 200, building_screen.nodes_per_layer[-1] || 16)
    batch_size_box = create_text_box(1057, 425, 130, 200, building_screen.batch_size)
    learning_rate_box = create_text_box(1057, 471, 130, 200, building_screen.learning_rate)
    epochs_box = create_text_box(1057, 522, 130, 200, building_screen.epochs)

    error_message = building_screen.error_message
    if error_message
        Text.new(
            error_message,
            x: 1049 - error_message.length * 5, y: 671, size: 20,
            font: './fonts/SF-Pro-Display-Semibold.otf',
            color: 'red'
        )
    end

    cur_screen.mouse_events << on(:mouse_down) do |event|
        case cur_screen.type
        when ScreenType::BUILDING_SCREEN
            if is_clicked?(home_btn, event)
                change_screen(cur_screen, ScreenType::MAIN_MENU)
            # Add new layer
            elsif is_clicked?(add_btn, event)
                num_nodes = Integer(num_nodes_box.value) rescue false
                activation = get_selected_activation(activations_btn)

                error_message = nil
                if not (num_nodes and num_nodes > 0)
                    error_message = "Invalid number of nodes"
                end

                if building_screen.nodes_per_layer.length == 4
                    error_message = "Maximum number of layers is 4"
                end

                if not error_message
                    building_screen.nodes_per_layer << num_nodes
                    building_screen.activations << activation
                end

                building_screen.error_message = error_message
                cur_screen.render_again = true
                
            # Start training
            elsif is_clicked?(start_btn, event)
                batch_size = Integer(batch_size_box.value) rescue false
                learning_rate = Float(learning_rate_box.value) rescue false
                epochs = Integer(epochs_box.value) rescue false

                error_message = nil

                if not (batch_size and batch_size > 0)
                    error_message = "Invalid batch size"
                end

                if not (learning_rate and learning_rate > 0)
                    error_message = "Invalid learning rate"
                end

                if not (epochs and epochs > 0)
                    error_message = "Invalid number of epochs"
                end

                if not error_message
                    building_screen.batch_size = batch_size
                    building_screen.learning_rate = learning_rate
                    building_screen.epochs = epochs
                    change_screen(cur_screen, ScreenType::TRAINING_SCREEN)
                end

                building_screen.error_message = error_message
                cur_screen.render_again = true
            end
        end
    end
end