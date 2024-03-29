import numpy as np


def sigmoid(Z):
    return 1 / (1 + np.exp(-Z))


def relu(Z):
    return np.maximum(0, Z)


def sigmoid_backward(dA, Z):
    sig = sigmoid(Z)
    return dA * sig * (1 - sig)


def relu_backward(dA, Z):
    dZ = np.array(dA, copy=True)
    dZ[Z <= 0] = 0
    return dZ


def softmax(z):
    return (np.exp(z.T) / np.sum(np.exp(z), axis=1)).T


b = np.arange(10,19).reshape(3, 3)
print(np.log(b))