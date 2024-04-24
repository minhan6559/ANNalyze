class InferenceScreen
    attr_accessor :need_load_model, :model, :input, :has_input, :mouse_released
    def initialize()
        @need_load_model = true
        @model = nil
        @input = Numo::DFloat.zeros(784, 1)
        @mouse_released = true
        @has_input = false
    end
end

def load_model_from_loading_screen(inference_screen, loading_model_screen)
    inference_screen.model = load_model(loading_model_screen.model_name)
    inference_screen.need_load_model = false
end

def reset_inference_screen(inference_screen)
    inference_screen.need_load_model = true
    inference_screen.model = nil
    inference_screen.input = Numo::DFloat.zeros(784, 1)
    inference_screen.mouse_released = true
    inference_screen.has_input = false
end

def draw_input_with_mouse(cur_screen, inference_screen)
    cur_screen.mouse_events << on(:mouse_down) do |event|
        inference_screen.mouse_released = false
    end

    cur_screen.mouse_events << on(:mouse_up) do |event|
        inference_screen.mouse_released = true
    end

    surrounding_directions = [[0, -1], [0, 2], [1, -1], [1,1]]
    cur_screen.mouse_events << on(:mouse_move) do |event|
        x = get :mouse_x
        y = get :mouse_y
        if not inference_screen.mouse_released and x.between?(27, 308 + 27) and y.between?(221, 308 + 221)
            i = (y - 221) / 11
            j = (x - 27) / 11
            # color = min(1.0, inference_screen.input[i * 28 + j, 0] + 230.0 / 255.0)
            color = max(0.98, inference_screen.input[i * 28 + j, 0])
            inference_screen.input[i * 28 + j, 0] = color
            Square.new(x: j * 11 + 27, y: i * 11 + 221, size: 10, color: [color, color, color, 1])
    
            if i + 1 < 28
                color = max(0.98, inference_screen.input[(i + 1) * 28 + j, 0])
                inference_screen.input[(i + 1) * 28 + j, 0] = color
                Square.new(x: j * 11 + 27, y: (i + 1) * 11 + 221, size: 10, color: [color, color, color, 1])
            end
            
            if j + 1 < 28
                color = max(0.98, inference_screen.input[i * 28 + (j + 1), 0])
                inference_screen.input[i * 28 + (j + 1), 0] = color
                Square.new(x: (j + 1) * 11 + 27, y: i * 11 + 221, size: 10, color: [color, color, color, 1])
            end

            surrounding_directions.each do |direction|
                m, n = direction
                if (i + m).between?(0, 27) and (j + n).between?(0, 27)
                    color = max(0.4, inference_screen.input[(i + m) * 28 + (j + n), 0])
                    inference_screen.input[(i + m) * 28 + (j + n), 0] = color
                    Square.new(x: (j + n) * 11 + 27, y: (i + m) * 11 + 221, size: 10, color: [color, color, color, 1])
                end
            end
        end
    end
end


def render_inference_screen(cur_screen, inference_screen)
    clear()

    Image.new(
        './images/InferenceScreen/Nav_bar.png',
        x: 0, y: 0, z: -1
    )

    draw_network_with_input(inference_screen.input, inference_screen.model, inference_screen.has_input)
    draw_input_with_mouse(cur_screen, inference_screen)
    
    output = forward_prop(inference_screen.input, inference_screen.model)[0].argmax(axis: 0)[0]
    if inference_screen.has_input
        Text.new(
            "Predicted: #{output}",
            x: 115, y: 174,
            size: 25, color: 'white',
            font: './fonts/SF-Pro-Display-Semibold.otf'
        )
    end
    
    clear_btn = create_button(
        './images/InferenceScreen/Clear_button.png',
        42, 548, 115, 58, cur_screen, ScreenType::INFERERENCE_SCREEN
    )

    predict_btn = create_button(
        './images/InferenceScreen/Predict_button.png',
        188, 548, 133, 58, cur_screen, ScreenType::INFERERENCE_SCREEN
    )

    home_btn = create_button(
        './images/MainMenu/Home_button.png',
        1171, 10, 55, 47, cur_screen, ScreenType::INFERERENCE_SCREEN
    )

    cur_screen.mouse_events << on(:mouse_down) do |event|
        case cur_screen.type
        when ScreenType::INFERERENCE_SCREEN
            if is_clicked?(clear_btn, event)
                inference_screen.input = Numo::DFloat.zeros(784, 1)
                inference_screen.has_input = false
                cur_screen.render_again = true
            end
            if is_clicked?(predict_btn, event)
                inference_screen.has_input = true
                cur_screen.render_again = true
            end
            if is_clicked?(home_btn, event)
                change_screen(cur_screen, ScreenType::MAIN_MENU)
                reset_inference_screen(inference_screen)
            end
        end
    end
end