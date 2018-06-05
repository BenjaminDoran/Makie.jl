# this is a bit of an odd design, but I think it does it's job.
# This file contains statements spereated by the comment # cell (without space),
# which makes it possible to extract each cell out of this file.
# There is also the setup cell indicated by # setup.
# We can then continue to generate files for visual regression tests
# snoop compiling and even create ijulia notebooks with cells containing this.

#setup
using Makie, GLFW, GeometryTypes, Reactive, FileIO, ColorBrewer, Colors
using GLVisualize
using GLVisualize: loadasset, assetpath

cd(@__DIR__) do 
function xy_data(x, y)
    r = sqrt(x*x + y*y)
    r == 0.0 ? 1f0 : (sin(r)/r)
end

function custom_theme(scene)
    @theme theme = begin
        linewidth = to_float(3)
        colormap = to_colormap(:RdYlGn)#to_colormap(:RdPu)
        scatter = begin
            marker = to_spritemarker(Circle)
            markersize = to_float(0.03)
            strokecolor = to_color(:white)
            strokewidth = to_float(0.01)
            glowcolor = to_color(RGBA(0, 0, 0, 0.4))
            glowwidth = to_float(0.1)
        end
    end
    # update theme values
    scene[:theme] = theme
end


#cell
img = loadasset("doge.png")
scene = Scene(resolution = (500, 500))

display(scene)
show(scene)
println(scene)

is = image(img)
center!(scene)
subscene = Scene(scene, Signal(SimpleRectangle(0, 0, 200, 200)))
scatter(subscene, rand(100) * 200, rand(100) * 200, markersize = 4)
center!(scene)

#cell
scene = Scene(resolution = (500, 500));
x = [0, 1, 2, 0];
y = [0, 0, 1, 2];
z = [0, 2, 0, 1];
color = [:red, :green, :blue, :yellow];
i = [0, 0, 0, 1];
j = [1, 2, 3, 2];
k = [2, 3, 1, 3];

indices = [1, 2, 3, 1, 3, 4, 1, 4, 2, 2, 3, 4];
mesh(x, y, z, indices, color = color);
r = linspace(-0.5, 2.5, 4);
axis(r, r, r);
center!(scene);

#cell
scene = Scene(resolution = (500, 500))
Makie.Makie.volume(rand(32, 32, 32), algorithm = :iso)
center!(scene)

#cell
scene = Scene(resolution = (500, 500))
heatmap(rand(32, 32))
center!(scene)

#cell
scene = Scene(resolution = (500, 500))
r = linspace(-10, 10, 512)
z = ((x, y)-> sin(x) + cos(y)).(r, r')
Makie.contour(r, r, z, levels = 5, color = ColorBrewer.palette("RdYlBu", 5))
center!(scene)

#cell
scene = Scene(resolution = (500, 500))
vx = -1:0.1:1;
vy = -1:0.1:1;

f(x, y) = (sin(x*10) + cos(y*10)) / 4
psurf = surface(vx, vy, f)

pos = lift_node(psurf[:x], psurf[:y], psurf[:z]) do x, y, z
    vec(Point3f0.(x, y', z .+ 0.5))
end
pscat = scatter(pos)
plines = lines(view(pos, 1:2:length(pos)))
center!(scene)
@theme theme = begin
    markersize = to_markersize2d(0.01)
    strokecolor = to_color(:white)
    strokewidth = to_float(0.01)
end
# this pushes all the values from theme to the plot
push!(pscat, theme)
pscat[:glow_color] = to_node(RGBA(0, 0, 0, 0.4), x->to_color((), x))
# apply it to the scene
custom_theme(scene)
# From now everything will be plotted with new theme
psurf = surface(vx, 1:0.1:2, psurf[:z])
center!(scene)

#cell
scene = Scene(resolution = (500, 500))
sv = scatter(rand(Point3f0, 100))
similar(sv, rand(10), rand(10), rand(10), color = :black, markersize = 0.4)
scene

#cell
scene = Scene(resolution = (500, 500))
large_sphere = HyperSphere(Point3f0(0), 1f0)
positions = decompose(Point3f0, large_sphere)
colS = [Colors.RGBA{Float32}(rand(), rand(), rand(), 1.) for i = 1:length(positions)]
sizesS = [rand(Vec3f0) .* 0.5f0 for i = 1:length(positions)]
meshscatter(positions, color = colS, markersize = sizesS)
center!(scene)

#cell
scene = Scene(resolution = (500, 500))
y = [
    -0.997669
    -0.979084
    -0.942261
    -0.887885
    -0.81697
    -0.730836
    -0.631088
    -0.519584
    -0.398401
    -0.269797
    -0.136167
    0.0
    0.136167
    0.269797
    0.398401
    0.519584
    0.631088
    0.730836
    0.81697
    0.887885
    0.942261
    0.979084
    0.997669
]
contour(linspace(-0.99, 0.99, 23), y, rand(23, 23), levels = 10)
center!(scene)

#cell
scene = Scene(resolution = (500, 500))
# define points/edges
perturbfactor = 4e1
N = 3; nbfacese = 30; radius = 0.02
large_sphere = HyperSphere(Point3f0(0), 1f0)
positions = decompose(Point3f0, large_sphere, 30)
np = length(positions)
pts = [positions[k][l] for k = 1:length(positions), l = 1:3]
pts = vcat(pts, 1.1 * pts + randn(size(pts)) / perturbfactor) # light position influence ?
edges = hcat(collect(1:np), collect(1:np) + np)
ne = size(edges, 1); np = size(pts, 1)
# define markers meshes
meshC = GeometryTypes.GLNormalMesh(GeometryTypes.Cylinder{3, Float32}(
                                   GeometryTypes.Point3f0(0., 0., 0.),
                                   GeometryTypes.Point3f0(0., 0, 1.),
                                   Float32(1)), nbfacese)

meshS = GeometryTypes.GLNormalMesh(large_sphere, 20)
# define colors, markersizes and rotations
pG = [GeometryTypes.Point3f0(pts[k, 1], pts[k, 2], pts[k, 3]) for k = 1:np]
lengthsC = sqrt.(sum((pts[edges[:,1], :] .- pts[edges[:, 2], :]) .^ 2, 2))
sizesC = [GeometryTypes.Vec3f0(radius, radius, lengthsC[i]) for i = 1:ne]
sizesC = [Vec3f0(1., 1., 1.) for i = 1:ne]
colorsp = [Colors.RGBA{Float32}(rand(), rand(), rand(), 1.) for i = 1:np]
colorsC = [(colorsp[edges[i, 1]] + colorsp[edges[i, 2]]) / 2. for i = 1:ne]
sizesC = [Vec3f0(radius, radius, lengthsC[i]) for i = 1:ne]
Qlist = zeros(ne, 4)
for k = 1:ne
    ct = GeometryTypes.Cylinder{3, Float32}(
                GeometryTypes.Point3f0(pts[edges[k, 1], 1], pts[edges[k, 1], 2], pts[edges[k, 1], 3]),
                GeometryTypes.Point3f0(pts[edges[k, 2], 1], pts[edges[k, 2], 2], pts[edges[k, 2], 3]),
                Float32(1))
    Q = GeometryTypes.rotation(ct)
    r = 0.5 * sqrt(1 + Q[1, 1] + Q[2, 2] + Q[3, 3]); Qlist[k, 4] = r
    Qlist[k, 1] = (Q[3, 2] - Q[2, 3]) / (4 * r)
    Qlist[k, 2] = (Q[1, 3] - Q[3, 1]) / (4 * r)
    Qlist[k, 3] = (Q[2, 1] - Q[1, 2]) / (4 * r)
end
rotationsC = AbstractVector[Vec4f0(Qlist[i, 1], Qlist[i, 2], Qlist[i, 3], Qlist[i, 4]) for i = 1:ne]
# plot
hm = Makie.meshscatter(pG[edges[:, 1]], color = colorsC, marker = meshC,
                       markersize = sizesC,  rotations = rotationsC)
hp = Makie.meshscatter(pG, color = colorsp, marker = meshS, markersize = radius)

r = linspace(-1.3, 1.3, 4); Makie.axis(r, r, r)
center!(scene)

#cell
scene = Scene(resolution = (500, 500))
large_sphere = HyperSphere(Point3f0(0), 1f0)
positions = decompose(Point3f0, large_sphere)
linepos = view(positions, rand(1:length(positions), 1000))
lines(linepos, linewidth = 0.1, color = :black)
scatter(positions, strokewidth = 0.02, strokecolor = :white, color = RGBA(0.9, 0.2, 0.4, 0.6))
r = linspace(-1.5, 1.5, 5)
axis(r, r, r)
scene

#cell
scene = Scene(resolution = (500, 500))
large_sphere = HyperSphere(Point3f0(0), 1f0)
positions = decompose(Point3f0, large_sphere)
meshscatter(positions, color = RGBA(0.9, 0.2, 0.4, 1))
scene

#cell
scene = Scene(resolution = (500, 500))

r = linspace(-2, 2, 40)
surf_func(i) = [Float32(xy_data(x*i, y*i)) for x = r, y = r]
z = surf_func(20)
surf = surface(r, r, z)

wf = wireframe(r, r, surf[:z] .+ 1.0,
    linewidth = 2f0, color = lift_node(x-> x[5], surf[:colormap])
)
xy = linspace(-2.1, 2.1, 4)
axis(xy, xy, linspace(0, 2, 4))
center!(scene)

io = VideoStream(scene)
for i in linspace(0, 60, 100)
    surf[:z] = surf_func(i)
    recordframe!(io)
end
scene


#cell
scene = Scene(resolution = (500, 500))

N = 40
r = linspace(-2, 2, 40)
surf_func(i) = [Float32(xy_data(x*i, y*i)) for x = r, y = r]
surface(
    r, r, surf_func(10),
    color = GLVisualize.loadasset("doge.png")
)
center!(scene)
scene

#cell
scene = Scene(resolution = (500, 500))
x = GLVisualize.loadasset("cat.obj")
Makie.mesh(x.vertices, x.faces, color = :black)
pos = map(x.vertices, x.normals) do p, n
    p => p .+ (normalize(n) .* 0.05f0)
end
linesegment(pos)
scene


#cell
scene = Scene(resolution = (500, 500))
mesh(GLVisualize.loadasset("cat.obj"))
r = linspace(-0.1, 1, 4)
center!(scene)
scene

#cell
scene = Scene(resolution = (500, 500))
cat = load(assetpath("cat.obj"), GLNormalUVMesh)
Makie.mesh(cat, color = loadasset("diffusemap.tga"))
center!(scene)

#cell
scene = Scene(resolution = (500, 500))
Makie.mesh(Sphere(Point3f0(0), 1f0))
center!(scene)
scene


#cell
scene = Scene(resolution = (500, 500))
wireframe(GLVisualize.loadasset("cat.obj"))
center!(scene)
scene

#cell
scene = Scene(resolution = (500, 500))
wireframe(Sphere(Point3f0(0), 1f0))
center!(scene)
scene

#cell
scene = Scene(resolution = (500, 500))
heatmap(rand(32, 32))
center!(scene)

#cell
scene = Scene(resolution = (500, 500), color = :black)
stars = 100_000
scatter((rand(Point3f0, stars) .- 0.5) .* 10,
    glowwidth = 0.005, glow_color = :white, color = RGBA(0.8, 0.9, 0.95, 0.4),
    markersize = rand(linspace(0.0001, 0.01, 100), stars)
)
scene

#cell
scene = Scene(resolution = (500, 500))
Makie.volume(rand(32, 32, 32), algorithm = :iso)
center!(scene)

#cell
scene = Scene(resolution = (500, 500))
scatter(Point3f0[(1,0,0), (0,1,0), (0,0,1)], marker=[:x, :circle, :cross])
axis(scene, linspace(0, 1, 4), linspace(0, 1, 4), linspace(0, 1, 4))
center!(scene);


#cell
scene = Scene(resolution = (500, 500))

x = map([:dot, :dash, :dashdot], [2, 3, 4]) do ls, lw
    linesegment(linspace(1, 5, 100), rand(100), rand(100), linestyle = ls, linewidth = lw)
end
push!(x, scatter(linspace(1, 5, 100), rand(100), rand(100)))
center!(scene)
l = Makie.legend(x, ["attribute $i" for i in 1:4])
l[:position] = (0, 1)
l[:backgroundcolor] = RGBA(0.95, 0.95, 0.95)
l[:strokecolor] = RGB(0.8, 0.8, 0.8)
l[:gap] = 30
l[:textsize] = 19
l[:linepattern] = Point2f0[(0,-0.2), (0.5, 0.2), (0.5, 0.2), (1.0, -0.2)]
l[:scatterpattern] = decompose(Point2f0, Circle(Point2f0(0.5, 0), 0.3f0), 9)
l[:markersize] = 2f0
scene

#cell
scene = Scene(resolution = (500, 500))
cmap = collect(linspace(to_color(:red), to_color(:blue), 20))
l = Makie.legend(cmap, 1:4)
l[:position] = (1.0,1.0)
l[:textcolor] = :blue
l[:strokecolor] = :black
l[:strokewidth] = 1
l[:textsize] = 15
l[:textgap] = 5
scene

#cell
using Makie, GeometryTypes


# mktempdir() do path
#     scene = Scene()
#     lineplots = []
#     axis(linspace(-0.1, 1.1, 4), linspace(-2, 2, 4), linspace(0, 2, 4))
#     center!(scene)
#     us = linspace(0, 1, 100)
#     io = VideoStream(scene, path, "lines")
#
#     for i = 1:100
#         if length(lineplots) < 20
#             push!(lineplots, lines(us, sin.(us .+ time()), zeros(100)))
#         else
#             lineplots = circshift(lineplots, 1)
#             lp = first(lineplots)
#             lp[:positions] = Point3f0.(us, sin.(us .+ time()), zeros(100))
#             lp[:offset] = Vec3f0(0)
#         end
#         for lp in lineplots
#             z = to_value(lp, :offset)[3]
#             lp[:offset] = Vec3f0(0, 0, z + 0.1)
#         end
#         sleep(1/30)
#         recordframe!(io)
#     end
#     finish(io, "gif")
# end


#cell
function animtest1(r)
    mktempdir() do path
        scene = Scene(resolution = (600, 600))
        axis(linspace(-25, 25, 4), linspace(-25, 25, 4))
        scatter(r[1][:, 1], r[1][:, 2], markersize = 1)
        center!(scene)
        io = VideoStream(scene, path, "interaction")
        @inbounds for i in 2:length(r)
            scene[:scatter][:positions] = Point2f0.(view(r[i], :, 1), view(r[i], :, 2))
            recordframe!(io)
        end
        finish(io, "mp4") # could also be gif, webm or mkv
    end
    nothing
end
r = [(rand(7, 2) .- 0.5) .* 25 for i = 1:200]
animtest1(r)


using Makie
scene = Scene()
text(
    ". This is an annotation!",
    position = (300, 200),
    align = (:center,  :center),
    textsize = 60,
    font = "URW Chancery L"
)



#cell
using Makie, UnicodeFun, GeometryTypes
scene = Scene()
vx = -1:0.01:1;
vy = -1:0.01:1;

f(x, y) = (sin(x*10) + cos(y*10)) / 4
psurf = surface(vx, vy, f)

a = axis(linspace(extrema(vx)..., 4), linspace(extrema(vy)..., 4), linspace(-1, 1, 4))
center!(scene, 0)

a[:axisnames] = ("\\bf{ℜ}[u]", "\\bf{𝕴}[u]", " OK\n\\bf{δ}\n γ")
a[:axisnames_size] = (0.15, 0.15, 0.15)
a[:axisnames_color] = (:black, :black, :black)
a[:axisnames_font] = "Palatino"

psurf[:colormap] = :RdYlBu
wh = widths(scene)
t = text(
    "Multipole Representation of first resonances of U-238",
    position = (wh[1] / 2.0, wh[2] - 20.0),
    align = (:center,  :center),
    textsize = 20,
    font = "Palatino",
    camera = :pixel
)
c = lines(Circle(Point2f0(0.1, 0.5), 0.1f0), color = :red, offset = Vec3f0(0, 0, 1))
#update surface
psurf[:z] = f.(vx .+ 0.5, (vy .+ 0.5)')



#cell
using Makie, GeometryTypes, ColorTypes
scene = Scene();
scatter([Point2f0(1.0f0,1.0f0),Point2f0(1.0f0,0.0f0)])
center!(scene);
text_overlay!(scene, "test", position = Point2f0(1.0f0,1.0f0), textsize=200,color= RGBA(0.0f0,0.0f0,0.0f0,1.0f0))
text_overlay!(scene, "test", position = Point2f0(1.0f0,0.0f0), textsize=200,color= RGBA(0.0f0,0.0f0,0.0f0,1.0f0))

scene = Scene();
scatter([Point2f0(1.0f0,1.0f0),Point2f0(1.0f0,0.0f0)])
center!(scene);

text_overlay!(scene,:scatter, "test", "test", textsize=200,color= RGBA(0.0f0,0.0f0,0.0f0,1.0f0))

scene = Scene();
scatter([Point2f0(1.0f0,1.0f0),Point2f0(1.0f0,0.0f0)])
center!(scene);
text_overlay!(scene, :scatter, 1=>"test1", 2=>"test2", textsize=200,color= RGBA(0.0f0,0.0f0,0.0f0,1.0f0))


#cell

using Makie, GeometryTypes
scene = Scene()
points = decompose(Point2f0, Circle(Point2f0(0), 1f0))
pol = poly!(scene, points, color = :gray, linewidth = 10, linecolor = :black)

# Optimized forms
# y = poly!(scene, [Circle(Point2f0(600+i, i), 50f0) for i = 1:150:800])
# x = poly!(scene, [Rectangle{Float32}(600+i, i, 100, 100) for i = 1:150:800], strokewidth = 10, strokecolor = :black)
x = linesegments!(scene,
    [Point2f0(600+i, i) => Point2f0(i + 700, i + 100) for i = 1:150:800], linewidth = 20, color = :purple
)
scene
#cell
using Makie, Colors
scene = Scene(resolution = (500, 500))
heatmap!(scene, rand(32, 32))
image!(scene, map(x->RGB(x,0.5, 0.5), rand(32,32)))
scene

# #cell
# using Makie
#
# scene = Scene(resolution = (500, 500))
# pts = CartesianRange((10, 10))
# xs = vec([I[1] for I in pts])
# ys = vec([I[2] for I in pts])
# zs = vec([sin(I[1]/10*2pi)+sin(I[2]/10*2pi) for I in pts])
# wireframe(xs, ys, zs) # stackoverflow


using Makie, GeometryTypes

n = 20
f   = (x,y,z) -> x*exp(cos(y)*z)
∇f  = (x,y,z) -> Point3f0(exp(cos(y)*z), -sin(y)*z*x*exp(cos(y)*z), x*cos(y)*exp(cos(y)*z))
∇ˢf = (x,y,z) -> ∇f(x,y,z) - Point3f0(x,y,z)*dot(Point3f0(x,y,z), ∇f(x,y,z))

θ = [0;(0.5:n-0.5)/n;1]
φ = [(0:2n-2)*2/(2n-1);2]
x = [cospi(φ)*sinpi(θ) for θ in θ, φ in φ]
y = [sinpi(φ)*sinpi(θ) for θ in θ, φ in φ]
z = [cospi(θ) for θ in θ, φ in φ]

pts = vec(Point3f0.(x, y, z))
∇ˢF = vec(∇ˢf.(x, y, z))

scene = Scene();
surface!(scene , x, y, z)

Makie.arrows(
    scene, pts, ∇ˢF,
    arrowsize = 0.03, linecolor = :gray, linewidth = 3
)
scene


using Makie, GeometryTypes

# needs to be in a function for ∇ˢf to be fast and inferable
function test(scene)
    n = 20
    f   = (x,y,z) -> x*exp(cos(y)*z)
    ∇f  = (x,y,z) -> Point3f0(exp(cos(y)*z), -sin(y)*z*x*exp(cos(y)*z), x*cos(y)*exp(cos(y)*z))
    ∇ˢf = (x,y,z) -> ∇f(x,y,z) - Point3f0(x,y,z)*dot(Point3f0(x,y,z), ∇f(x,y,z))
    θ = [0;(0.5:n-0.5)/n;1]
    φ = [(0:2n-2)*2/(2n-1);2]
    x = [cospi(φ)*sinpi(θ) for θ in θ, φ in φ]
    y = [sinpi(φ)*sinpi(θ) for θ in θ, φ in φ]
    z = [cospi(θ) for θ in θ, φ in φ]

    pts = vec(Point3f0.(x, y, z))
    lns = Makie.streamlines!(scene, pts, ∇ˢf)
    # those can be changed interactively:
    lns[:color] = :black
    lns[:h] = 0.06
    lns[:linewidth] = 1.0
    lns
end

scene = Scene()
n = 20
θ = [0;(0.5:n-0.5)/n;1]
φ = [(0:2n-2)*2/(2n-1);2]
x = [cospi(φ)*sinpi(θ) for θ in θ, φ in φ]
y = [sinpi(φ)*sinpi(θ) for θ in θ, φ in φ]
z = [cospi(θ) for θ in θ, φ in φ]
rand([-1f0, 1f0], 3)
pts = vec(Point3f0.(x, y, z))

surface!(scene, x, y, z)
scene
using Makie, GeometryTypes
scene = Scene()
function SphericalToCartesian(r::T,θ::T,ϕ::T) where T<:AbstractArray
    x = @.r*sin(θ)*cos(ϕ)
    y = @.r*sin(θ)*sin(ϕ)
    z = @.r*cos(θ)
    Point3f0.(x, y, z)
end

n = 128^2 #number of points to generate
r = ones(n);
θ = acos.(1 .- 2 .* rand(n));
φ = 2π * rand(n);
pts = SphericalToCartesian(r,θ,φ);
s = Makie.arrows(scene, pts, (normalize.(pts) .* 0.1f0), arrowsize = 0.02)
scene


parent = Scene();
n = 128
θ = [0;(0.5:n-0.5)/n;1]
φ = [(0:2n-2)*2/(2n-1);2]
x = [cospi(φ)*sinpi(θ) for θ in θ, φ in φ]
y = [sinpi(φ)*sinpi(θ) for θ in θ, φ in φ]
z = [cospi(θ) for θ in θ, φ in φ]
sub1 = Scene(parent);
s = surface!(sub1, x, y, z, image = rand(size(xyz)), colormap = :viridis)
sub2 = Scene(parent, transformation = Makie.Transformation())
s = surface!(sub2, x, y, z, image = rand(size(xyz)), colormap = :viridis)
parent
sub2.transformation.translation[] = Vec3f0(0, 1.5, 0)
sub2.plots[1][:model][]
typeof(sub2) == typeof(parent)


image(rand(10, 10))
Makie.current_scene()

using Makie, Colors, GeometryTypes

function test(x, y, z)
    xy = [x, y, z]
    (xy') * eye(3, 3) * xy
end
scene = Scene()
x = linspace(-2pi, 2pi, 100)
scene = Scene()
c1 = contour!(scene, x, x, x, test)
scene
xm, ym, zm = minimum(Makie.limits(scene)[])
s1 = Makie.translated(scene, (:xy, -zm));
c2 = contour!(scene, x, x, map(v-> v[1, :, :], c1[4])[]);
scene
Makie.modelmatrix(c2)[]

heatmap!(translated(scene, (:xz, ym)), x, x, map(v-> v[:, 1, :], c[4]))
contour!(translated(scene, (:yz, xm)), x, x, map(v-> v[:, :, 1], c[4]), fillrange = true)
scene


scene


using Makie, Colors, GeometryTypes
function test(x, y, z)
    xy = [x, y, z]
    (xy') * eye(3, 3) * xy
end
x = linspace(-2pi, 2pi, 100)
scene = Scene()
c = contour!(scene, x, x, x, test)
xm, ym, zm = minimum(scene.limits[])
# c[4] == fourth argument of the above plotting command
contour!(scene, x, x, map(v-> v[1, :, :], c[4]), transformation = (:xy, zm))
heatmap!(scene, x, x, map(v-> v[:, 1, :], c[4]), transformation = (:xz, ym))
contour!(scene, x, x, map(v-> v[:, :, 1], c[4]), fillrange = true, transformation = (:yz, xm))


using Makie, GeometryTypes

s = Scene()
x, y = rand(10), rand(10)
s1 = Scene(s, transformation = Makie.Transformation())
lines!(s1, x, y)
s2 = Scene(s, transformation = Makie.Transformation())
lines!(s2, x, y, color = :black)
s
xw = (Makie.real_boundingbox(s1) |> maximum)[1]
s2.transformation.translation[] = Vec3f0(xw, 0, 0)


# Layouting + transformations
# UI elements
# setindex/getindex, theme merging
# fix desing of convert_arguments
