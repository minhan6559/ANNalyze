def create_button(file_path, x, y, width, height, cur_screen, screen_type)
    btn = Sprite.new(
        file_path,
        x: x, y: y,
        clip_width: width,
        time: 150,
        animations: {
            not_hover: 0..0,
            hover: 1..1
        },
        loop: true
    )

    cur_screen.mouse_events << on(:mouse_move) do |event|
        case cur_screen.type
        when screen_type
            x_mouse, y_mouse = event.x, event.y
            if x_mouse.between?(x, x + width) and y_mouse.between?(y, y + height)
                btn.play(animation: :hover)
            else
                btn.play(animation: :not_hover)
            end
        end
    end

    return btn
end

def create_text_box(x, y, width, height, default_value)
    text_box = InputBox.new(
        x: x, y: y,
        value: default_value.to_s,
        displayName: default_value.to_s,
        height: height, length: width,
        size: 20,
        color: 'white', inactiveTextColor: 'black',
        activeColor: 'white', activeTextColor: 'black'
    )

    return text_box
end

def remove_all_events(events)
    if events.nil?
        return []
    end
    events.each do |event|
        off(event)
    end
    return []
end

def is_clicked?(btn, event)
    x_mouse, y_mouse = event.x, event.y
    return (event.button == :left and 
            x_mouse.between?(btn.x, btn.x + btn.clip_width) and 
            y_mouse.between?(btn.y, btn.y + btn.clip_height))
end

def max(*values)
    values.max
end

def min(*values)
    values.min
end