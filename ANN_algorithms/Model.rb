require_relative 'Activations'

# Artificial Neural Network class
class ANN
    attr_accessor :nodes_per_layer, :params, :activations, :learning_rate, :grads
    def initialize(nodes_per_layer, activations, learning_rate)
        @nodes_per_layer = nodes_per_layer
        @activations = activations
        @params = initialize_params(nodes_per_layer)
        @learning_rate = learning_rate
        @grads = {}
    end
end

def initialize_params(nodes_per_layer)
    prev = 784
    params = {}
    nodes_per_layer.each_with_index do |cur, i|
        params["W#{i+1}"] = Numo::DFloat.new(cur, prev).rand_norm * Math.sqrt(2.0/prev)
        params["b#{i+1}"] = Numo::DFloat.zeros(cur, 1)
        prev = cur
    end
end

def single_layer_forward_propagation(a, w, b, activation=Activation::RELU)
    z = w.dot(a) + b
    
    case activation
    when Activation::SIGMOID
        activation_func = method(:sigmoid)
    when Activation::RELU
        activation_func = method(:relu)
    when Activation::TANH
        activation_func = method(:tanh)
    when Activation::SOFTMAX
        activation_func = method(:softmax)
    else
        raise "Non-supported activation function"
    end
    return activation_func.call(z), z
end

def forward_propagation(x, model)
    cache = {}
    a_cur = x

    model.nodes_per_layer.each_with_index do |cur, i|
        layer_idx = i + 1
        a_prev = a_cur
        activation = model.activations[i]
        w = model.params["W#{layer_idx}"]
        b = model.params["b#{layer_idx}"]
        a_cur, z = single_layer_forward_propagation(a_prev, w, b, activation)
        cache["A#{i}"] = a_prev
        cache["Z#{layer_idx}"] = z
    end
    return a_cur, cache
end

def compute_cost(aL, y)
    m = y.shape[1]
    cost = -(1./m) * (y * Numo::NMath.log(aL)).sum
    return cost
end

def compute_accuracy(aL, y)
    aL = aL.argmax(axis: 0)
    y = y.argmax(axis: 0)
    return (aL.eq(y)).count.to_f / y.shape[0]
end

def single_layer_backward_propagation(dA_cur, w_cur, b_cur, z_cur, a_prev, activation=Activation::RELU)
    m = a_prev.shape[1]
    if activation == Activation::SIGMOID
        activation_func = method(:sigmoid_backward)
    elsif activation == Activation::RELU
        activation_func = method(:relu_backward)
    elsif activation == Activation::TANH
        activation_func = method(:tanh_backward)
    elsif activation == Activation::SOFTMAX
        activation_func = method(:softmax_backward)
    else
        raise "Non-supported activation function"
    end

    dZ_cur = activation_func.call(dA_cur, z_cur)
    dW_cur = (1./m) * dZ_cur.dot(a_prev.transpose)
    db_cur = (1./m) * dZ_cur.sum(axis: 1, keepdims: true)
    dA_prev = w_cur.transpose.dot(dZ_cur)

    return dA_prev, dW_cur, db_cur
end

# softmax regression deep neural network backward propagation
def backward_propagation(y_hat, y, cache, model, eps = 0.000000000001)
    m = y.shape[1]
    
    dA_prev = y_hat - y
    L = model.nodes_per_layer.length

    (0...L).reverse_each do |layer_idx_prev|
        layer_idx_cur = layer_idx_prev + 1
        activ_function_cur = model.activations[layer_idx_prev]
        
        dA_cur = dA_prev
        
        a_prev = cache["A#{layer_idx_prev}"]
        z_cur = cache["Z#{layer_idx_cur}"]
        
        w_cur = model.params["W#{layer_idx_cur}"]
        b_cur = model.params["b#{layer_idx_cur}"]
        
        dA_prev, dW_cur, db_cur = single_layer_backward_propagation(
            dA_cur, w_cur, b_cur, z_cur, a_prev, activ_function_cur)
        
        model.grads["dW#{layer_idx_cur}"] = dW_cur
        model.grads["db#{layer_idx_cur}"] = db_cur
    end
end

def update_params(model)
    model.nodes_per_layer.length.times do |i|
        layer_idx = j + 1
        model.params["W#{layer_idx}"] -= model.learning_rate * model.grads["dW#{layer_idx}"]
        model.params["b#{layer_idx}"] -= model.learning_rate * model.grads["db#{layer_idx}"]
    end
end

def train(x, y, model, epochs=1000)
    costs = []
    accuracies = []
    epochs.times do |i|
        aL, cache = forward_propagation(x, model)
        cost = compute_cost(aL, y)
        accu = compute_accuracy(aL, y)
        backward_propagation(aL, y, cache, model)
        update_params(model)
        model.costs << cost
        if i % 100 == 0
            puts "Cost after iteration #{i}: #{cost}"
            puts "Accuracy after iteration #{i}: #{accu}"
        end
    end
end