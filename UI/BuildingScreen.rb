class BuildingScreen

end

def render_building_screen(screen)
    clear()
    
    Image.new(
        './images/BuildingScreen/Building_screen_background.png',
        x: 0, y: 0
    )

    start_btn = create_button(
        './images/BuildingScreen/Start_button.png',
        981, 610, 133, 58, ScreenType::BUILDING_SCREEN
    )

    home_btn = create_button(
        'images\BuildingScreen\Home_button.png',
        1171, 10, 55, 47, ScreenType::BUILDING_SCREEN
    )

    on(:mouse_down) do |event|
        case screen.current_type
        when ScreenType::BUILDING_SCREEN
            if is_clicked?(home_btn, event)
                screen.current_type = ScreenType::MAIN_MENU
            end
        end
    end
end

