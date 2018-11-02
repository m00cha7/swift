// TODO: Revert to %target-run-simple-swift once we complete send/recv support for resource/variant tensors.
// RUN: %target-run-send-recv-handle-swift
// RUN: %target-run-disable-deabstraction-swift
// REQUIRES: executable_test
// REQUIRES: swift_test_mode_optimize

// This file contains testing over a dataset as a global variable. This requires
// sends/recvs support for variant handles.

import TensorFlow
import TensorFlowUnittest
import StdlibUnittest

var DatasetGlobalTests = TestSuite("DatasetGlobal")

// TODO: add GPU support -- in device partitioning, maybe sure we do not do tensor
// transfer for variant / resource ops.
// The current error is:
// Fatal error: No unary variant device copy function found for direction: 1 and Variant type_name: tensorflow::DatasetVariantWrapper
#if !CUDA

let scalars = Tensor<Float>([0, 1, 2])
let dataset = Dataset(elements: scalars)
var iterator = dataset.makeIterator()

DatasetGlobalTests.testCPUOrGPU("DatasetAsGlobalVar") {
  // This stmt makes sure the load inst from the global var `dataset` does not
  // make dataset an input arg tensor.
  //
  // It can be removed when we convert arg tensors to Swift->TF tensor
  // transfers.
  _ = scalars + scalars

  var expectedVal: Float = 0.0
  for item in dataset {
    _hostOp(item)
    expectNearlyEqualWithScalarTensor(expectedVal, item)
    expectedVal += 1.0
  }
}

DatasetGlobalTests.testCPUOrGPU("IteratorAsGlobalVar") {
  // This stmt makes sure the load inst from the global var `iterator` does not
  // make iterator an input arg tensor.
  //
  // It can be removed when we convert arg tensors to Swift->TF tensor
  // transfers.
  _ = scalars + scalars

  var expectedVal: Float = 0.0
	while let item = iterator.next() {
    _hostOp(item)
    expectNearlyEqualWithScalarTensor(expectedVal, item)
    expectedVal += 1.0
	}
}

#endif // !CUDA

runAllTests()
