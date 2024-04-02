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

def update_params_with_adam(model, adam)
    v_corrected = {}
    s_corrected = {}

    beta1 = adam.beta1
    beta2 = adam.beta2
    epsilon = adam.epsilon
    t = adam.t

    model.nodes_per_layer.length.times do |i|
        l = i + 1
        adam.v["dW#{l}"] = beta1 * adam.v["dW#{l}"] + (1 - beta1) * model.grads["dW#{l}"]
        adam.v["db#{l}"] = beta1 * adam.v["db#{l}"] + (1 - beta1) * model.grads["db#{l}"]

        v_corrected["dW#{l}"] = adam.v["dW#{l}"] / (1 - beta1 ** t)
        v_corrected["db#{l}"] = adam.v["db#{l}"] / (1 - beta1 ** t)

        adam.s["dW#{l}"] = beta2 * adam.s["dW#{l}"] + (1 - beta2) * (model.grads["dW#{l}"] ** 2)
        adam.s["db#{l}"] = beta2 * adam.s["db#{l}"] + (1 - beta2) * (model.grads["db#{l}"] ** 2)

        s_corrected["dW#{l}"] = adam.s["dW#{l}"] / (1 - beta2 ** t)
        s_corrected["db#{l}"] = adam.s["db#{l}"] / (1 - beta2 ** t)

        model.params["W#{l}"] -= model.learning_rate * v_corrected["dW#{l}"] / (Numo::NMath.sqrt(s_corrected["dW#{l}"]) + epsilon)
        model.params["b#{l}"] -= model.learning_rate * v_corrected["db#{l}"] / (Numo::NMath.sqrt(s_corrected["db#{l}"]) + epsilon)
    end

    adam.t += 1
end
