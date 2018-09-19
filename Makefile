cuda:
	nvcc KMP/kmp_CUDA.cu -o build/kmpCuda && ./build/kmpCuda DATA/norm.txt DATA/pattern.txt
serial:
	g++ KMP/kmp.cpp -o build/kmpSerial && ./build/kmpSerial DATA/norm.txt DATA/pattern.txt