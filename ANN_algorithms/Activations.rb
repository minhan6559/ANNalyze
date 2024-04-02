module Activation
    SIGMOID = 1
    RELU = 2
    TANH = 3
    SOFTPLUS = 4
    SOFTMAX = 5
end

def sigmoid(z)
    return 1/(1+Numo::NMath.exp(-z))
end

def sigmoid_backward(dA, z)
    sig = sigmoid(z)
    return dA * sig * (1 - sig)
end

def relu(z)
    return Numo::DFloat.maximum(0,z)
end

def relu_backward(dA, z)
    return dA * Numo::DFloat.cast(z > 0)
end

def tanh(z)
    return Numo::NMath.tanh(z)
end

def tanh_backward(dA, z)
    return dA * (1 - tanh(z) ** 2)
end

def softmax(z)
    exps = Numo::NMath.exp(z)
    return exps / exps.sum(axis: 0, keepdims: true)
end

def softmax_backward(dA, z)
    return dA
end

def softplus(z)
    return Numo::NMath.log(1 + Numo::NMath.exp(z))
end

def softplus_backward(dA, z)
    return dA * sigmoid(z)
end