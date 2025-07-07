import AtomicCompat

@safe
public struct CoreInputDeque: ~Copyable, Sendable {
	@usableFromInline
	internal let head: Atomic<Int> = .init(0)
	@usableFromInline
	internal let tail: Atomic<Int> = .init(0)

	// SAFETY: this is managed privately.
	@safe
	@usableFromInline
	internal nonisolated(unsafe) let inner: UnsafeMutableBufferPointer<Element>

	public struct Element: Sendable {
		public let player: UInt8
		public let delta: CoreInputDelta

		public static let zero = Self(player: .max, delta: .zero)
	}

	public init(maxPlayers: UInt8) {
		self.init(capacity: 64 * Int(maxPlayers))
	}

	public init(capacity: Int) {
		self.inner = .allocate(capacity: capacity)
		unsafe self.inner.initialize(repeating: .zero)
	}

	deinit {
		unsafe self.inner.deallocate()
	}

	@inlinable
	borrowing func availableRead(head: Int, tail: Int) -> Int {
		return tail >= head
		? tail &- head
		: tail &+ inner.count &- head
	}

	@inlinable
	borrowing func availableWrite(head: Int, tail: Int) -> Int {
		return tail >= head
		? inner.count &- tail &+ head
		: head &- tail
	}

	/// Writes the delta into the input buffer. Drops inputs if the buffer is full.
	public func enqueue(_ delta: CoreInputDelta, for player: UInt8) {
		let capacity = inner.count
		let head = self.head.load(ordering: .relaxed)
		let tail = self.tail.load(ordering: .acquiring)
		let available = self.availableWrite(head: head, tail: tail)
		guard available > 0 else { return }

		var nextTail = tail + 1
		nextTail -= nextTail >= capacity ? capacity : 0
		self.tail.store(nextTail, ordering: .releasing)

		inner[tail] = .init(player: player, delta: delta)
	}

	public func dequeue<Core: CoreProtocol & ~Copyable>(into core: inout Core) {
		let capacity = inner.count
		let head = self.head.load(ordering: .acquiring)
		let tail = self.tail.load(ordering: .relaxed)

		let available = self.availableRead(head: head, tail: tail)
		guard available > 0 else { return }

		var nextHead = head + available
		let needsWrap = nextHead >= capacity
		nextHead -= needsWrap ? capacity : 0
		self.head.store(nextHead, ordering: .releasing)

		let len1 = needsWrap ? capacity - head : available
		for i in head..<(head + len1) {
			core.writeInput(inner[i].delta, for: inner[i].player)
		}

		let len2 = needsWrap ? nextHead : 0
		for i in 0..<len2 {
			core.writeInput(inner[i].delta, for: inner[i].player)
		}
	}
}
