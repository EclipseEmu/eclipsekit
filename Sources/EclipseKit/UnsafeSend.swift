/// A handle for sending things between thread boundaries.
///
/// - WARNING: Only use this when you know the wrapped type has some level of thread safety
///            but couldn't conform to ``Sendable`` for one reason or another.
///            For example, ``RunLoop.perform`` is thread-safe, but ``RunLoop`` itself is not.
@unsafe
@frozen
public struct UnsafeSend<Value: ~Copyable>: @unchecked Sendable, ~Copyable {
	public let inner: Value

	public init(_ inner: consuming Value) {
		unsafe self.inner = inner
	}
}

/// A handle for sending things between thread boundaries, where ``Copyable`` is needed.
/// If Copyable is not needed, use ``UnsafeSend`` instead.
///
/// - WARNING: This should be almost never be used, as this handle can be copied,
///            meaning it can continue to be used on the origin thread.
///            Only use it for things like streams and continuations.
@unsafe
@frozen
public struct UnsafeCopyableSend<Value>: @unchecked Sendable {
	public let inner: Value

	public init(_ inner: consuming Value) {
		unsafe self.inner = inner
	}
}
