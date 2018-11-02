// RUN: %target-run-simple-swift
// REQUIRES: executable_test
// REQUIRES: swift_test_mode_optimize
//
// String Tensor tests.

import TensorFlow
import StdlibUnittest

var StringTensorTests = TestSuite("String")

StringTensorTests.test("StringComparison") {
  // Const op over a String tensor cannot live on GPU.
  TensorFlow.enableCPU()
  let t1 = Tensor("foo")
  let result1 = t1.elementsEqual(t1)
  expectEqual(ShapedArray(shape: [], scalars: [true]), result1.array)

  let t2 = Tensor(["foo", "bar"])
  let result2 = t2.elementsEqual(t2)
  expectEqual(ShapedArray(shape: [2], scalars: [true, true]),
              result2.array)

  let t3 = Tensor(["different", "bar"])
  let result3 = t2.elementsEqual(t3)
  expectEqual(ShapedArray(shape: [2], scalars: [false, true]),
              result3.array)

}

runAllTests()
