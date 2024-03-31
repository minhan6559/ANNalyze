require 'numo/narray'
class Adam
    attr_accessor :beta1, :beta2, :epsilon, :v, :s, :t 
    def initialize(nodes_per_layer, beta1 = 0.9, beta2 = 0.999, epsilon = 1e-08)
        @beta1 = beta1
        @beta2 = beta2
        @epsilon = epsilon
        @v, @s = initialize_adam(nodes_per_layer)
        @t = 1
    end
end

def initialize_adam(nodes_per_layer)
    prev = 784
    v = {}
    s = {}
    nodes_per_layer.each_with_index do |cur, i|
        v["dW#{i+1}"] = Numo::DFloat.zeros(cur, prev)
        v["db#{i+1}"] = Numo::DFloat.zeros(cur, 1)
        s["dW#{i+1}"] = Numo::DFloat.zeros(cur, prev)
        s["db#{i+1}"] = Numo::DFloat.zeros(cur, 1)
        prev = cur
    end
    return v, s
end

def update_params_with_adam(model, v, s, t, beta1 = 0.9, beta2 = 0.999, epsilon = 1e-08)
    v_corrected = {}
    s_corrected = {}

    model.nodes_per_layer.length.times do |i|
        l = i + 1
        v["dW#{l}"] = beta1 * v["dW#{l}"] + (1 - beta1) * model.grads["dW#{l}"]
        v["db#{l}"] = beta1 * v["db#{l}"] + (1 - beta1) * model.grads["db#{l}"]

        v_corrected["dW#{l}"] = v["dW#{l}"] / (1 - beta1 ** t)
        v_corrected["db#{l}"] = v["db#{l}"] / (1 - beta1 ** t)

        s["dW#{l}"] = beta2 * s["dW#{l}"] + (1 - beta2) * (model.grads["dW#{l}"] ** 2)
        s["db#{l}"] = beta2 * s["db#{l}"] + (1 - beta2) * (model.grads["db#{l}"] ** 2)

        s_corrected["dW#{l}"] = s["dW#{l}"] / (1 - beta2 ** t)
        s_corrected["db#{l}"] = s["db#{l}"] / (1 - beta2 ** t)

        model.params["W#{l}"] -= model.learning_rate * v_corrected["dW#{l}"] / (Numo::NMath.sqrt(s_corrected["dW#{l}"]) + epsilon)
        model.params["b#{l}"] -= model.learning_rate * v_corrected["db#{l}"] / (Numo::NMath.sqrt(s_corrected["db#{l}"]) + epsilon)
    end
end
