require 'ruby2d'
require 'savio'
require_relative 'MainMenu.rb'
require_relative 'BuildingScreen.rb'
require_relative 'TrainingScreen.rb'
require_relative 'Utils.rb'

module ScreenType
    MAIN_MENU = 0
    BUILDING_SCREEN = 1
    TRAINING_SCREEN = 2
end

class CurrentScreen
    attr_accessor :type, :render_again, :mouse_events
    def initialize()
        @type = ScreenType::MAIN_MENU
        @render_again = true
        @mouse_events = []
    end
end

def change_screen(cur_screen, new_screen)
    cur_screen.type = new_screen
    cur_screen.render_again = true
end

def start_window()
    set title: "ANNalyze"
    set width: 1250
    set height: 720
    set background: "#252526"

    cur_screen = CurrentScreen.new()

    building_screen = BuildingScreen.new()
    training_screen = TrainingScreen.new()

    update do
        if cur_screen.render_again
            cur_screen.render_again = false
            cur_screen.mouse_events = remove_all_events(cur_screen.mouse_events)
            case cur_screen.type
            when ScreenType::MAIN_MENU
                render_main_menu(cur_screen)
            when ScreenType::BUILDING_SCREEN
                render_building_screen(cur_screen, building_screen)
            when ScreenType::TRAINING_SCREEN
                if training_screen.need_load_model
                    load_building_screen_configs(training_screen, building_screen)
                    training_screen.need_load_model = false
                end
                render_training_screen(cur_screen, training_screen)
            end
        end
    end

    # create_button(
    #     './images/BuildingScreen/Remove_button.png', 
    #     221, 297, 104.0 /2, 32, cur_screen, ScreenType::MAIN_MENU
    # )

    show()
end