require 'ruby2d'
require 'savio'
require_relative 'MainMenu.rb'
require_relative 'BuildingScreen.rb'
require_relative 'Utils.rb'

module ScreenType
    MAIN_MENU = 0
    BUILDING_SCREEN = 1
end

class Screen
    attr_accessor :current_type
    def initialize()
        @current_type = ScreenType::MAIN_MENU
    end
end

def start_window()
    set title: "ANNalyze"
    set width: 1250
    set height: 720
    set background: "#252526"

    prev_screen = nil
    screen = Screen.new()

    update do
        if prev_screen != screen.current_type
            case screen.current_type
            when ScreenType::MAIN_MENU
                render_main_menu(screen)
            when ScreenType::BUILDING_SCREEN
                render_building_screen(screen)
            end
            prev_screen = screen.current_type
        end
    end

    # create_button('./images/BuildingScreen/Start_button.png', 221, 297, 266.0 /2, 58)
    show()
end