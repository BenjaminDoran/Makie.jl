vertexbuffer(x) = decompose(Point, x)
vertexbuffer(x::Observable) = Buffer(lift(vertexbuffer, x))

facebuffer(x) = facebuffer(GeometryBasics.faces(x))
facebuffer(x::Observable) = Buffer(lift(facebuffer, x))
function facebuffer(x::AbstractArray{GLTriangleFace})
    return x
end

function array2color(colors, cmap, crange)
    cmap = RGBAf0.(Colors.color.(to_colormap(cmap)), 1.0)
    AbstractPlotting.interpolated_getindex.((cmap,), colors, (crange,))
end

function array2color(colors::AbstractArray{<: Colorant}, cmap, crange)
    return RGBAf0.(colors)
end

function converted_attribute(plot::AbstractPlot, key::Symbol)
    lift(plot[key]) do value
        convert_attribute(value, Key{key}(), Key{plotkey(plot)}())
    end
end

function create_shader(scene::Scene, plot::AbstractPlotting.Mesh)
    # Potentially per instance attributes
    mesh_signal = plot[1]
    mattributes = GeometryBasics.attributes
    get_attribute(mesh, key) = lift(x-> getproperty(x, key), mesh)
    data = mattributes(mesh_signal[])

    uniforms = Dict{Symbol, Any}(); attributes = Dict{Symbol, Any}()

    for (key, default) in (
            :uv => Vec2f0(0),
            :normals => Vec3f0(0)
        )
        if haskey(data, key)
            attributes[key] = Buffer(get_attribute(mesh_signal, key))
        else
            uniforms[key] = Observable(default)
        end
    end

    if haskey(data, :attributes) && data[:attributes] isa AbstractVector
        attributes[:color] = Buffer(lift(get_attribute(mesh_signal, :attributes), get_attribute(mesh_signal, :attribute_id)) do color, attr
            color[Int.(attr) .+ 1]
        end)
        uniforms[:uniform_color] = false
    else
        color_signal = converted_attribute(plot, :color)
        color = color_signal[]
        uniforms[:uniform_color] = Observable(false) # this is the default

        if color isa AbstractArray
            c_converted = if color isa AbstractArray{<: Colorant}
                color_signal
            elseif color isa AbstractArray{<: Number}
                lift(array2color, color_signal, plot.colormap, plot.colorrange)
            else
                error("Unsupported color type: $(typeof(color))")
            end
            if c_converted[] isa AbstractVector
                attributes[:color] = Buffer(c_converted) # per vertex colors
            else
                uniforms[:uniform_color] = Sampler(c_converted) # Texture
                !haskey(attributes, :uv) && @warn "Mesh doesn't use Texturecoordinates, but has a Texture. Colors won't map"
            end
        elseif color isa Colorant && !haskey(attributes, :color)
            uniforms[:uniform_color] = color_signal
        else
            error("Unsupported color type: $(typeof(color))")
        end
    end

    if !haskey(attributes, :color)
        uniforms[:color] = Vec4f0(0) # make sure we have a color attribute
    end

    uniforms[:shading] = plot.shading

    for key in (:ambient, :diffuse, :specular, :shininess, :lightposition)
        uniforms[key] = plot[key]
    end

    if haskey(uniforms, :lightposition)
        eyepos = getfield(scene.camera, :eyeposition)
        uniforms[:lightposition] = lift(uniforms[:lightposition], eyepos, typ=Vec3f0) do pos, eyepos
            ifelse(pos == :eyeposition, eyepos, pos)::Vec3f0
        end
    end

    faces = facebuffer(mesh_signal)
    positions = vertexbuffer(mesh_signal)
    # on(mesh_signal) do m
    #     @show vertexbuffer(m)[1]
    # end
    instance = GeometryBasics.Mesh(
        GeometryBasics.meta(positions; attributes...), faces
    )
    get!(uniforms, :colorrange, true)
    get!(uniforms, :colormap, true)
    return Program(
        WebGL(),
        lasset("mesh.vert"),
        lasset("mesh.frag"),
        instance;
        uniforms...
    )
end

function draw_js(jsctx, jsscene, scene::Scene, plot::AbstractPlotting.Mesh)
    program = create_shader(scene, plot)
    mesh = wgl_convert(scene, jsctx, program)
    resize_pogram(jsctx, program, mesh)
    debug_shader("mesh", program)
    mesh.name = "Mesh"
    update_model!(mesh, plot)
    map(plot.visible) do visible
        mesh.visible = visible
    end
    jsscene.add(mesh)
    return mesh
end
