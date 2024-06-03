# This file contains the code to render the loading model screen

# Loading model screen class
class LoadingModelScreen
    attr_accessor :model_name, :start_index
    def initialize()
        @model_name = ""
        @start_index = 0
    end
end

# Reset the loading model screen to the initial state
def reset_loading_model_screen(loading_model_screen)
    loading_model_screen.model_name = ""
    loading_model_screen.start_index = 0
end

# Render the loading model screen
def render_loading_model_screen(cur_screen, loading_model_screen)
    clear()

    # Background
    Image.new(
        './images/LoadingModelScreen/Background.png',
        x: 0, y: 0, z: -1
    )

    # Get the list of saved models from the "saved_models" directory
    model_list = Dir.entries('./saved_models')
    if model_list.include?('.DS_Store')
        model_list = model_list[3..-1]
    else
        model_list = model_list[2..-1]
    end

    # Display the list of saved models
    if model_list.length == 0 # No model found
        Text.new(
            "No model found !!!",
            x: 518, y: 349, z: 99,
            size: 28, color: 'white',
            font: './fonts/SF-Pro-Display-Semibold.otf'
        )
    else
        model_list = model_list.sort
        start_index = loading_model_screen.start_index

        # Display 6 models at a time
        min(6, model_list.length - start_index).times do |i|
            # File name
            file_name_text = Text.new(
                model_list[start_index + i][0...-4],
                x: 397, y: 222 + 62 * i, z: 99,
                size: 25, color: 'white'
            )

            # Choose file button
            choose_file_btn = create_button(
                './images/LoadingModelScreen/File_name_background.png',
                372, 214 + 62 * i, 506, 49, cur_screen, ScreenType::LOADING_MODEL_SCREEN
            )

            # Mouse events for the choose file button
            cur_screen.mouse_events << on(:mouse_down) do |event|
                if is_clicked?(choose_file_btn, event)
                    loading_model_screen.model_name = file_name_text.text
                    loading_model_screen.start_index = 0
                    change_screen(cur_screen, ScreenType::INFERERENCE_SCREEN)
                end
            end
        end

        # Left button
        if start_index > 0
            left_btn = create_button(
                './images/LoadingModelScreen/Left_button.png',
                320, 343, 37, 38, cur_screen, ScreenType::LOADING_MODEL_SCREEN
            )

            cur_screen.mouse_events << on(:mouse_down) do |event|
                if is_clicked?(left_btn, event)
                    loading_model_screen.start_index -= 6
                    cur_screen.render_again = true
                end
            end
        end

        # Right button
        if start_index + 6 < model_list.length
            right_btn = create_button(
                './images/LoadingModelScreen/Right_button.png',
                889, 343, 37, 38, cur_screen, ScreenType::LOADING_MODEL_SCREEN
            )

            cur_screen.mouse_events << on(:mouse_down) do |event|
                if is_clicked?(right_btn, event)
                    loading_model_screen.start_index += 6
                    cur_screen.render_again = true
                end
            end
        end
    end

    # Home button
    home_btn = create_button(
        './images/MainMenu/Home_button.png',
        1171, 10, 55, 47, cur_screen, ScreenType::LOADING_MODEL_SCREEN
    )

    # Mouse events for the home button
    cur_screen.mouse_events << on(:mouse_down) do |event|
        if is_clicked?(home_btn, event)
            reset_loading_model_screen(loading_model_screen)
            change_screen(cur_screen, ScreenType::MAIN_MENU)
        end
    end
end