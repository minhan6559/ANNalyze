class BuildingScreen

end

def render_building_screen(events)
    clear()
    events = remove_all_events(events)
    
    main_menu_background = Image.new(
        './images/BuildingScreen/Building_screen_background.png',
        x: 0, y: 0
    )

    events << create_button(
        './images/BuildingScreen/Start_button.png',
        981, 610, 133, 58
    )

    events << create_button(
        './images/BuildingScreen/Home_button.png',
        1171, 10, 55, 47
    )
end
