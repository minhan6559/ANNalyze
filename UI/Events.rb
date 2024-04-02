def create_button(file_path, x, y, width, height)
    btn = Sprite.new(
        file_path,
        x: x, y: y,
        clip_width: width,
        time: 150,
        animations: {
            not_hover: 0..0,
            hover: 1..1
        },
        loop: false
    )

    event = on :mouse_move do |event|
        x_mouse, y_mouse = event.x, event.y
        if x_mouse.between?(x, x + width) and y_mouse.between?(y, y + height)
            btn.play(animation: :hover, loop: true)
        else
            btn.play animation: :not_hover
        end
    end
    return event
end

def remove_all_events(events)
    events.each do |event|
        off(event)
    end
    return []
end