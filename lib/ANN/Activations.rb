module Activation
    SIGMOID = 0
    RELU = 1
    TANH = 2
    SOFTPLUS = 3
    SOFTMAX = 4
end

# Sigmoid Activation Function
def sigmoid(z)
    return 1/(1+Numo::NMath.exp(-z))
end

def sigmoid_backward(dA, z)
    sig = sigmoid(z)
    return dA * sig * (1 - sig)
end

# ReLU Activation Function
def relu(z)
    return Numo::DFloat.maximum(0,z)
end

def relu_backward(dA, z)
    return dA * Numo::DFloat.cast(z > 0)
end

# Tanh Activation Function
def tanh(z)
    return Numo::NMath.tanh(z)
end

def tanh_backward(dA, z)
    return dA * (1 - tanh(z) ** 2)
end

# Softmax Activation Function
def softmax(z)
    exps = Numo::NMath.exp(z)
    return exps / exps.sum(axis: 0, keepdims: true)
end

def softmax_backward(dA, z)
    return dA
end

# Softplus Activation Function
def softplus(z)
    return Numo::NMath.log(1 + Numo::NMath.exp(z))
end

def softplus_backward(dA, z)
    return dA * sigmoid(z)
end