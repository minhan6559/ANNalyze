require 'ruby2d'
require 'savio'
require_relative 'MainMenu.rb'
require_relative 'BuildingScreen.rb'
require_relative 'TrainingScreen.rb'
require_relative 'InferenceScreen.rb'
require_relative 'LoadingModelScreen.rb'
require_relative 'Utils.rb'

module ScreenType
    MAIN_MENU = 0
    BUILDING_SCREEN = 1
    TRAINING_SCREEN = 2
    INFERERENCE_SCREEN = 3
    LOADING_MODEL_SCREEN = 4
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
    inference_screen = InferenceScreen.new()
    loading_model_screen = LoadingModelScreen.new()

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
                end
                render_training_screen(cur_screen, training_screen)
            when ScreenType::INFERERENCE_SCREEN
                if inference_screen.need_load_model
                    load_model_from_loading_screen(inference_screen, loading_model_screen)
                end
                render_inference_screen(cur_screen, inference_screen)
            when ScreenType::LOADING_MODEL_SCREEN
                render_loading_model_screen(cur_screen, loading_model_screen)
            end
        end
    end

    show()
end