// SWIFT_ENABLE_TENSORFLOW
// TODO: Handle trailing where clause in @differentiable attribute.

// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend %s -emit-module -parse-as-library -o %t
// RUN: %target-sil-opt -disable-sil-linking -enable-sil-verify-all %t/differentiable_attr.swiftmodule -o - | %FileCheck %s

struct CheckpointsFoo {}
func pfoo(_ x: Float) -> (checkpoints: CheckpointsFoo, originalValue: Float) {
  return (CheckpointsFoo(), x * x)
}
func dfoo_checkpointed(_ x: Float, checkpoints: CheckpointsFoo, originalValue: Float, seed: Float) -> Float {
  return 2 * x
}
// CHECK-DAG: @differentiable(reverse, primal: pfoo, adjoint: dfoo_checkpointed)
// CHECK-DAG: func foo_checkpointed(_ x: Float) -> Float
@differentiable(reverse, primal: pfoo(_:), adjoint: dfoo_checkpointed(_:checkpoints:originalValue:seed:))
func foo_checkpointed(_ x: Float) -> Float {
  return x * x
}

struct S<T> {
  struct Checkpoints {
    let s: S
  }
  func primal(x: Float) -> (Checkpoints, Float) {
    return (Checkpoints(s: self), x)
  }
  func adjoint_checkpointed(x: Float, _: Checkpoints, _: Float, _: Float) -> S {
    return self
  }

  // CHECK-DAG: @differentiable(reverse, wrt: (self), primal: primal, adjoint: adjoint_checkpointed)
  // CHECK-DAG: func original(x: Float) -> Float
  @differentiable(reverse, wrt: (self), primal: primal, adjoint: adjoint_checkpointed)
  func original(x: Float) -> Float {
    return x
  }
}

func pbaz1<T>(_ x: T, _ y: T) -> ((T, T), T) {
  return ((y, y), x)
}
func dbaz1_checkpointed<T>(_ x: T, _ y: T, primal: (T, T), originalValue: T, seed: T) -> (T, T) {
  return (y, x)
}
// CHECK-DAG: @differentiable(reverse, primal: pbaz1, adjoint: dbaz1_checkpointed)
// CHECK-DAG: func baz1_checkpointed<T>(_ x: T, _ y: T) -> T
@differentiable(reverse, primal: pbaz1(_:_:), adjoint: dbaz1_checkpointed(_:_:primal:originalValue:seed:))
func baz1_checkpointed<T>(_ x: T, _ y: T) -> T {
  return x
}

struct CheckpointsFP<T : FloatingPoint> {
  let meow: T
}
func pbaz2<T : FloatingPoint>(_ x: T, _ y: T) -> (CheckpointsFP<T>, T) {
  return (CheckpointsFP(meow: 1), x + y)
}
func dbaz2_checkpointed<T : FloatingPoint>(_ x: T, _ y: T, primal: CheckpointsFP<T>, originalValue: T, seed: T) -> (T, T) {
  return (1, 1)
}
// CHECK-DAG: @differentiable(reverse, primal: pbaz2, adjoint: dbaz2_checkpointed)
// CHECK-DAG: func baz2_checkpointed<T>(_ x: T, _ y: T) -> T where T : FloatingPoint
@differentiable(reverse, primal: pbaz2(_:_:), adjoint: dbaz2_checkpointed(_:_:primal:originalValue:seed:))
func baz2_checkpointed<T : FloatingPoint>(_ x: T, _ y: T) -> T {
  return x
}
