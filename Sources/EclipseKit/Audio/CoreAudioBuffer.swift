import AtomicCompat
#if os(macOS) || os(iOS)
import Darwin
#endif

/// A circular buffer intended for reading and writing large amounts of bytes, ideal for audio.
@safe
public struct CoreAudioBuffer: Sendable, ~Copyable {
	public let capacity: Int
	private let head: Atomic<Int> = .init(0)
	private let tail: Atomic<Int> = .init(0)
	// SAFETY: This pointer is managed entirely in the scope of this struct.
	private nonisolated(unsafe) let inner: UnsafeMutableRawBufferPointer

	public init(capacity: Int) {
		self.capacity = capacity
		unsafe self.inner = .init(UnsafeMutableRawBufferPointer.allocate(
			byteCount: MemoryLayout<UInt8>.stride * capacity,
			alignment: MemoryLayout<UInt8>.alignment
		))
	}

	deinit {
		unsafe self.inner.deallocate()
	}

	@inlinable
	public borrowing func availableRead(head: Int, tail: Int) -> Int {
		return tail >= head ? tail &- head : tail &+ self.capacity &- head
	}

	@inlinable
	public borrowing func availableWrite(head: Int, tail: Int) -> Int {
		return tail >= head ? self.capacity &- tail &+ head : head &- tail
	}

	public borrowing func availableRead() -> Int {
		let head = self.head.load(ordering: .relaxed)
		let tail = self.tail.load(ordering: .relaxed)
		return self.availableRead(head: head, tail: tail)
	}

	public borrowing func availableWrite() -> Int {
		let head = self.head.load(ordering: .relaxed)
		let tail = self.tail.load(ordering: .relaxed)
		return self.availableWrite(head: head, tail: tail)
	}

	public mutating func read(into dst: UnsafeMutableRawBufferPointer) -> Int {
		guard let baseAddress = dst.baseAddress else { return 0 }
		_onFastPath()
		return unsafe self.read(dst: baseAddress, length: dst.count)
	}

	public mutating func write(from src: UnsafeRawBufferPointer) -> Int {
		guard let baseAddress = src.baseAddress else { return 0 }
		_onFastPath()
		return unsafe self.write(src: baseAddress, length: src.count)
	}

	@unsafe
	public mutating func read(dst: UnsafeMutableRawPointer, length: Int) -> Int {
		let head = self.head.load(ordering: .acquiring)
		let tail = self.tail.load(ordering: .relaxed)

		let available = self.availableRead(head: head, tail: tail)
		guard available >= length, let src = unsafe self.inner.baseAddress else { return 0 }

		var nextHead = head + length
		let needsWrap = nextHead >= self.capacity
		nextHead -= needsWrap ? self.capacity : 0
		self.head.store(nextHead, ordering: .releasing)

		let len1 = needsWrap ? self.capacity - head : length
		let len2 = needsWrap ? nextHead : 0

		unsafe memcpy(dst, src.advanced(by: head), len1)
		unsafe memcpy(dst.advanced(by: len1), src, len2)

		return length
	}

	@unsafe
	public mutating func write(src: UnsafeRawPointer, length: Int) -> Int {
		let head = self.head.load(ordering: .relaxed)
		let tail = self.tail.load(ordering: .acquiring)

		let available = self.availableWrite(head: head, tail: tail)
		guard available >= length, let dst = unsafe self.inner.baseAddress else { return 0 }

		var nextTail = tail + length
		let needsWrap = nextTail >= self.capacity
		nextTail -= needsWrap ? self.capacity : 0
		self.tail.store(nextTail, ordering: .releasing)

		let len1 = needsWrap ? self.capacity &- tail : length
		let len2 = needsWrap ? nextTail : 0

		unsafe memcpy(dst.advanced(by: tail), src, len1)
		unsafe memcpy(dst, src.advanced(by: len1), len2)

		return length
	}

	public mutating func clear() {
		self.head.store(0, ordering: .relaxed)
		self.tail.store(0, ordering: .relaxed)
	}
}
