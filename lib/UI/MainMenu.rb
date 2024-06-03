def render_main_menu(cur_screen)
    clear()
    
    # Background
    Image.new(
        './images/MainMenu/Main_menu_background.png',
        x: 0, y: 0
    )

    # Build button
    build_btn = create_button(
        './images/MainMenu/Build_button.png',
        221, 297, 676.0 / 2, 221, cur_screen, ScreenType::MAIN_MENU
    )
    
    # Inference button
    infer_btn = create_button(
        './images/MainMenu/Inference_button.png',
        692, 297, 676.0 / 2, 221, cur_screen, ScreenType::MAIN_MENU
    )
    
    # Mouse events for the buttons
    cur_screen.mouse_events << on(:mouse_down) do |event|
        x, y = event.x, event.y
        case cur_screen.type
        when ScreenType::MAIN_MENU
            if is_clicked?(build_btn, event)
                change_screen(cur_screen, ScreenType::BUILDING_SCREEN)
            elsif is_clicked?(infer_btn, event)
                change_screen(cur_screen, ScreenType::LOADING_MODEL_SCREEN)
            end
        end
    end
end