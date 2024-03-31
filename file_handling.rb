require 'numo/narray'
require 'polars-df'

x_train = Polars.read_csv("./dataset/10000_X_train.csv").to_numo
y_train = Polars.read_csv("./dataset/10000_Y_train.csv").to_numo

fp = File.open("./dataset_bin/10000_X_train.bin", "wb")
fp.write(Marshal.dump(x_train))
fp.close

fp = File.open("./dataset_bin/10000_Y_train.bin", "wb")
fp.write(Marshal.dump(y_train))
fp.close

x_train = Polars.read_csv("./dataset/30000_X_train.csv").to_numo
y_train = Polars.read_csv("./dataset/30000_Y_train.csv").to_numo

fp = File.open("./dataset_bin/30000_X_train.bin", "wb")
fp.write(Marshal.dump(x_train))
fp.close

fp = File.open("./dataset_bin/30000_Y_train.bin", "wb")
fp.write(Marshal.dump(y_train))
fp.close

x_train = Polars.read_csv("./dataset/full_X_train.csv").to_numo
y_train = Polars.read_csv("./dataset/full_Y_train.csv").to_numo

fp = File.open("./dataset_bin/full_X_train.bin", "wb")
fp.write(Marshal.dump(x_train))
fp.close

fp = File.open("./dataset_bin/full_Y_train.bin", "wb")
fp.write(Marshal.dump(y_train))
fp.close

x_val = Polars.read_csv("./dataset/X_val.csv").to_numo
y_val = Polars.read_csv("./dataset/Y_val.csv").to_numo

fp = File.open("./dataset_bin/X_val.bin", "wb")
fp.write(Marshal.dump(x_val))
fp.close

fp = File.open("./dataset_bin/Y_val.bin", "wb")
fp.write(Marshal.dump(y_val))
fp.close