require_relative 'Events.rb'
require_relative 'BuildingScreen.rb'

def render_main_menu()
    main_menu_background = Image.new(
        './images/MainMenu/Main_menu_background.png',
        x: 0, y: 0
    )

    events = []
    events << create_button(
        './images/MainMenu/Build_button.png',
        221, 297, 676.0 / 2, 221
    )
    
    events << create_button(
        './images/MainMenu/Inference_button.png',
        692, 297, 676.0 / 2, 221
    )
    
    events << on(:mouse_down) do |event|
        x, y = event.x, event.y
        case event.button
        when :left
            if x.between?(221, 221 + 676.0 / 2) && y.between?(297, 297 + 221)
                render_building_screen(events)
            elsif x.between?(692, 692 + 676.0 / 2) && y.between?(297, 297 + 221)

            end
        end
    end
end