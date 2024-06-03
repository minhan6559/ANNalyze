require_relative 'Activations'
require 'numo/narray'

# Artificial Neural Network class
class ANN
    attr_accessor :nodes_per_layer, :params, :activations
    def initialize(nodes_per_layer, activations)
        @nodes_per_layer = nodes_per_layer
        @activations = activations
        @params = initialize_params(nodes_per_layer)
    end
end

# Initialize parameters for the model
def initialize_params(nodes_per_layer)
    prev = 784
    params = {}
    nodes_per_layer.each_with_index do |cur, i|
        params["W#{i+1}"] = Numo::DFloat.new(cur, prev).rand_norm * Math.sqrt(2.0/prev)
        params["b#{i+1}"] = Numo::DFloat.zeros(cur, 1)
        prev = cur
    end
    return params
end

# Forward propagation for one layer
def forward_prop_one_layer(a_prev, w, b, activation=Activation::RELU)
    z = w.dot(a_prev) + b
    case activation
    when Activation::SIGMOID
        a = sigmoid(z)
    when Activation::RELU
        a = relu(z)
    when Activation::TANH
        a = tanh(z)
    when Activation::SOFTPLUS
        a = softplus(z)
    when Activation::SOFTMAX
        a = softmax(z)
    else
        raise "Non-supported activation function"
    end
    return a, z
end

# Forward propagation for the whole model
def forward_prop(x, model)
    cache = {}
    a_cur = x

    model.nodes_per_layer.length.times do |i|
        layer_idx = i + 1
        a_prev = a_cur
        activation = model.activations[i]
        w = model.params["W#{layer_idx}"]
        b = model.params["b#{layer_idx}"]
        a_cur, z = forward_prop_one_layer(a_prev, w, b, activation)
        cache["A#{i}"] = a_prev
        cache["Z#{layer_idx}"] = z
    end
    return a_cur, cache
end

# Forward propagation for one input
def single_input_forward(x, model)
    layer_values = []
    a_cur = x

    model.nodes_per_layer.length.times do |i|
        layer_idx = i + 1
        a_prev = a_cur
        activation = model.activations[i]
        w = model.params["W#{layer_idx}"]
        b = model.params["b#{layer_idx}"]
        a_cur, z = forward_prop_one_layer(a_prev, w, b, activation)
        layer_values << a_cur
    end
    return layer_values
end

# Compute the cost of the model
def compute_cost(aL, y)
    m = y.shape[1].to_f
    return -(1.0/m) * (y * Numo::NMath.log(aL)).sum
end

# Compute the accuracy of the model 
def compute_accuracy(aL, y)
    _aL = aL.argmax(axis: 0)
    _y = y.argmax(axis: 0)
    return (_aL.eq(_y)).count.to_f / y.shape[1]
end

# Backward propagation for one layer
def back_prop_one_layer(dA_cur, w_cur, z_cur, a_prev, activation=Activation::RELU)
    m = a_prev.shape[1].to_f
    case activation
    when Activation::SIGMOID
        dZ_cur = sigmoid_backward(dA_cur, z_cur)
    when Activation::RELU
        dZ_cur = relu_backward(dA_cur, z_cur)
    when Activation::TANH
        dZ_cur = tanh_backward(dA_cur, z_cur)
    when Activation::SOFTPLUS
        dZ_cur = softplus_backward(dA_cur, z_cur)
    when Activation::SOFTMAX
        dZ_cur = softmax_backward(dA_cur, z_cur)
    else
        raise "Non-supported activation function"
    end

    dW_cur = (1.0/m) * dZ_cur.dot(a_prev.transpose)
    db_cur = (1.0/m) * dZ_cur.sum(axis: 1, keepdims: true)
    dA_prev = w_cur.transpose.dot(dZ_cur)

    return dA_prev, dW_cur, db_cur
end

# Backward propagation for the whole model
def back_prop(aL, y, cache, model)
    dA_prev = aL - y
    l = model.nodes_per_layer.length
    grads = {}
    (0...l).reverse_each do |layer_idx_prev|
        layer_idx_cur = layer_idx_prev + 1
        activ_function_cur = model.activations[layer_idx_prev]
        
        dA_cur = dA_prev
        
        a_prev = cache["A#{layer_idx_prev}"]
        z_cur = cache["Z#{layer_idx_cur}"]
        
        w_cur = model.params["W#{layer_idx_cur}"]
        
        dA_prev, dW_cur, db_cur = back_prop_one_layer(
            dA_cur, w_cur, z_cur, a_prev, activ_function_cur)
        
        grads["dW#{layer_idx_cur}"] = dW_cur
        grads["db#{layer_idx_cur}"] = db_cur
    end
    return grads
end

# Gradient descent update
def update_params_with_gd(model, learning_rate, grads)
    model.nodes_per_layer.length.times do |i|
        layer_idx = i + 1
        model.params["W#{layer_idx}"] -= learning_rate * grads["dW#{layer_idx}"]
        model.params["b#{layer_idx}"] -= learning_rate * grads["db#{layer_idx}"]
    end
end

# Make a prediction
def predict(x, model)
    aL = forward_prop(x, model)[0]
    return aL.argmax
end

# Save the model
def save_model(model, model_name)
    fp = File.open("./saved_models/#{model_name}.bin", "wb")
    fp.write(Marshal.dump(model))
    fp.close
end

# Load the model
def load_model(model_name)
    return Marshal.load(File.open("./saved_models/#{model_name}.bin", "rb"))
end

# Load the dataset
def load_bin_dataset(dataset_name)
    dataset = Marshal.load(File.open("./dataset/dataset_bin/#{dataset_name}.bin", "rb"))
    return dataset
end