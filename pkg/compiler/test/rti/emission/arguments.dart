// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.7

/*class: A:checkedTypeArgument,checks=[],onlyForRti,typeArgument*/
class A {}

/*class: B:checks=[],onlyForRti,typeArgument*/
class B {}

/*class: C:checkedInstance,checks=[],instance*/
class C<T> {}

@pragma('dart2js:noInline')
test(o) => o is C<A>;

main() {
  test(new C<A>());
  test(new C<B>());
}
