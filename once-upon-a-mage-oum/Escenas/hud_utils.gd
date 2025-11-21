extends Node
class_name HudUtils

static func select_frame(textures: Array, current: float, maximum: float) -> Texture2D:
	if textures.size() == 0:
		return null
	if maximum <= 0.0:
		return textures.back()

	var safe_current: float = clamp(current, 0.0, maximum)
	var span: int = textures.size() - 1
	if span <= 0:
		return textures[0]

	var step: float = float(maximum) / float(span)
	if step <= 0.0:
		return textures.back()

	var spent: float = float(maximum) - safe_current
	var frame: int = int(clamp(floor(spent / step), 0.0, float(span)))
	return textures[frame]
