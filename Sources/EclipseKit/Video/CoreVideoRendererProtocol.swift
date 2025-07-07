public protocol CoreVideoRendererProtocol: ~Copyable {
	init(
		core: inout (some CoreProtocol & ~Copyable),
		for format: consuming CoreVideoDescriptor,
		with sharedContext: CoreSharedRenderingContext,
		isolation: isolated (any Actor)?
	) async throws

	func render(
		targetTime: Double,
		drawable: CoreSharedRenderingContext.Drawable,
		outputTexture: CoreSharedRenderingContext.Texture
	)

	func screenshot(colorspace: CoreSharedRenderingContext.ColorSpace) -> CoreSharedRenderingContext.Image?
}
