# WireframeDisplay

A small resource pack that makes it easy to create and display wireframes of any size that look like those in vanilla.  
Adapted from [HalbFettKaese/WireframeDisplay](https://github.com/HalbFettKaese/WireframeDisplay).  
Minecraft version: 1.21.4

> [!Warning]
> The wireframe display is triggered by item textures with alpha=251.  
> Other item textures with this specific alpha value may be affected.

## Spawning a wireframe display

The wireframe displays are just item models. You can spawn them as a display like this:

```mcfunction
execute align xyz run summon item_display ~ ~ ~ {item: {id: coal, components: {item_model: "wireframe:regular", custom_model_data: {colors: [1131796]}}}, transformation: {scale: [1.,1.,1.], left_rotation: [0.,0.,0.,1.], right_rotation: [0.,0.,0.,1.], translation: [.5,.5,.5]}}
```

- Item ID: anything that uses `rendertype_item_entity_translucent_cull` shader should be fine.
- Item model: `wireframe:regular` or a custom wireframe model.
- Custom model data - colors\[0\]: color of the wireframe.

## Custom Wireframe Shape

### Cuboid Size

Simply change `transformation.scale` of the item display entity.

### Rotation

Horizontal rotation is supported. You can change that in `transformation.left_rotation`.  
Other rotations (such as pitch and roll) doesn't work.

## Custom Wireframe Model

1. Start from a copy of one of the existing textures.
2. Do **NOT** edit the first 2×3 area. These are marker pixels.
3. The 2×3 area to the right of the marker pixels represents thickness. Paint the 2×3 area with the same color. More details below.
4. The next 2×3 area controls if the wireframe should be displayed regardless of fog. Paint the 2×3 area to display the wireframe behind fog.
5. Create a new simple model inheriting `wireframe:item/template_wireframe`, and provide your texture to `0`.
```json
{
  "parent": "wireframe:item/template_wireframe",
  "textures": {
    "0": "example:your_texture_here"
  }
}
```
6. Create a new item model referencing the simple model, and provide a color to tint index 0 to control the color of the frame.
```json
{
  "model": {
    "type": "model",
    "model": "example:your_simple_model_here",
    "tints": [
      {
        "type": "custom_model_data",
        "default": 16777215
      }
    ]
  }
}
```

### Thickness representation

When the area is transparent, the thickness is 2.5 pixels (default value).  
When the area is painted, the thickness is determined by the color.

To convert the thickness `x` (in pixels) to color representation:
1. Convert the number to hexadecimal (website tool [here](https://www.rapidtables.com/convert/number/decimal-to-hex.html)). e.g. `4.625` → `4.A`.
2. Take the two digits before the hexadecimal point and the four after that. Combine them into a hexadecimal color representation. e.g. `4.A` → `#04A000`.
