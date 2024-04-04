

def render_main_menu(screen)
    clear()

    Image.new(
        './images/MainMenu/Main_menu_background.png',
        x: 0, y: 0
    )

    build_btn = create_button(
        './images/MainMenu/Build_button.png',
        221, 297, 676.0 / 2, 221, ScreenType::MAIN_MENU
    )
    
    infer_btn = create_button(
        './images/MainMenu/Inference_button.png',
        692, 297, 676.0 / 2, 221, ScreenType::MAIN_MENU
    )
    
    on(:mouse_down) do |event|
        x, y = event.x, event.y
        case screen.current_type
        when ScreenType::MAIN_MENU
            if is_clicked?(build_btn, event)
                screen.current_type = ScreenType::BUILDING_SCREEN
            elsif is_clicked?(infer_btn, event)
                puts "Inference button clicked!"
            end
        end
    end
end
