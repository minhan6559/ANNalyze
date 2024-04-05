class BuildingScreen
    attr_accessor :nodes_per_layer, :activations, :batch_size, :learning_rate, :epochs
    def initialize()
        @nodes_per_layer = []
        @activations = []
        @batch_size = 64
        @learning_rate = 0.05
        @epochs = 20
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
            './images/BuildingScreen/Layer_border.png',
            x: 115 + i * 180, y: 140
        )

        y_start = 160 + (215 - (min(num_nodes, 11) * 40 - 10) / 2.0)
        x = 134 + i * 180

        min(num_nodes, 11).times do |j|
            if num_nodes > 11 and j == 5
                Image.new(
                    './images/BuildingScreen/More_nodes.png',
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
        x: 0, y: 0
    )

    start_btn = create_button(
        './images/BuildingScreen/Start_button.png',
        981, 598, 133, 58, cur_screen, ScreenType::BUILDING_SCREEN
    )

    home_btn = create_button(
        './images/BuildingScreen/Home_button.png',
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

    cur_screen.mouse_events << on(:mouse_down) do |event|
        case cur_screen.type
        when ScreenType::BUILDING_SCREEN
            if is_clicked?(home_btn, event)
                change_screen(cur_screen, ScreenType::MAIN_MENU)
            elsif is_clicked?(add_btn, event) and building_screen.nodes_per_layer.length < 4
                building_screen.nodes_per_layer << num_nodes_box.value.to_i
                building_screen.activations << get_selected_activation(activations_btn)
                cur_screen.render_again = true
            elsif is_clicked?(start_btn, event)
                building_screen.batch_size = batch_size_box.value.to_i
                building_screen.learning_rate = learning_rate_box.value.to_f
                building_screen.epochs = epochs_box.value.to_i

                p building_screen.nodes_per_layer
                p building_screen.activations
                p building_screen.batch_size
                p building_screen.learning_rate
                p building_screen.epochs
            end
        end
    end
end