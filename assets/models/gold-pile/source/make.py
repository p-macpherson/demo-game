import bpy,bmesh,math,random,sys
from mathutils import Vector,Matrix
random.seed(7)
bpy.ops.wm.read_factory_settings(use_empty=True)
PAL=[(1.0,0.82,0.30),(1.0,0.87,0.38),(0.97,0.76,0.26),(1.0,0.91,0.5),(0.99,0.8,0.28),(0.85,0.12,0.18),(0.15,0.7,0.66),(0.95,0.74,0.24)]
N=len(PAL)
pi=bpy.data.images.new("palette",N,1)
px=[]
for c in PAL: px+=[c[0]**2.2,c[1]**2.2,c[2]**2.2,1]
pi.pixels=px; pi.filepath_raw=sys.argv[-1]; pi.file_format="PNG"; pi.save()
bm=bmesh.new(); uvl=bm.loops.layers.uv.new("UVMap")
def setcol(faces,i):
    for f in faces:
        for l in f.loops: l[uvl].uv=((i+.5)/N,.5)
def coin(center,normal,r,t,col):
    seg=10
    prof=[(0,.6*t),(.78*r,.6*t),(.85*r,t),(r,t),(r,.15*t)]
    rings=[]
    for (rad,z) in prof:
        rings.append([bm.verts.new((rad*math.cos(2*math.pi*k/seg),rad*math.sin(2*math.pi*k/seg),z-t/2)) if rad>0 else None for k in range(seg)])
    c0=bm.verts.new((0,0,.6*t-t/2))
    fs=[]
    for k in range(seg):
        k2=(k+1)%seg
        fs.append(bm.faces.new((c0,rings[1][k],rings[1][k2])) if False else bm.faces.new((c0,rings[1][k2],rings[1][k])))
    for a in range(1,len(prof)-1):
        for k in range(seg):
            k2=(k+1)%seg
            fs.append(bm.faces.new((rings[a][k],rings[a][k2],rings[a+1][k2],rings[a+1][k])))
    # underside fan hidden: skip, but close with a small bottom ring
    vs=[v for v in set(sum([[*f.verts] for f in fs],[]))]
    q=Vector((0,0,1)).rotation_difference(Vector(normal)).to_matrix().to_4x4()
    spin=Matrix.Rotation(random.uniform(0,6.28),4,'Z')
    bmesh.ops.transform(bm,verts=vs,matrix=Matrix.Translation(center)@q@spin)
    setcol(fs,col)
RX,RY,H=0.25,0.19,0.11
def hgt(x,y):
    d=(x/RX)**2+(y/RY)**2
    return H*max(0,1-d)**0.7
# base dome
geo=bmesh.ops.create_uvsphere(bm,u_segments=12,v_segments=6,radius=1)
vs=geo["verts"]
dead=[v for v in vs if v.co.z<-0.01]
bmesh.ops.delete(bm,geom=dead,context='VERTS')
for v in vs:
    if v.is_valid: v.co=Vector((v.co.x*(RX+.01),v.co.y*(RY+.01),v.co.z*(H-.008)))
dome=[f for f in bm.faces]
for f in dome: f.normal_update()
setcol(dome,7)
# coins
pts=[]
tries=0
while len(pts)<40 and tries<5000:
    tries+=1
    x=random.uniform(-RX,RX);y=random.uniform(-RY,RY)
    if (x/RX)**2+(y/RY)**2>1: continue
    if any((x-a)**2+(y-b)**2<0.058**2 for a,b in pts): continue
    pts.append((x,y))
# sort so lower ones first (irrelevant), build
for (x,y) in pts:
    e=0.01
    gx=(hgt(x+e,y)-hgt(x-e,y))/(2*e); gy=(hgt(x,y+e)-hgt(x,y-e))/(2*e)
    n=Vector((-gx,-gy,1)).normalized()
    n=(n+Vector((random.uniform(-.45,.45),random.uniform(-.45,.45),0))).normalized()
    coin(Vector((x,y,hgt(x,y)+0.012)),n,random.uniform(.058,.07),0.02,random.choice([0,1,2,3,4]))
# gem + goblet
def gem(c,s,col):
    g=bmesh.ops.create_icosphere(bm,subdivisions=1,radius=s)
    for v in g["verts"]: v.co+=c; v.co.z=c.z+(v.co.z-c.z)*1.2
    setcol([f for v in g["verts"] for f in v.link_faces],col)
gem(Vector((-0.10,0.07,hgt(-.10,.07)+0.02)),0.032,5)
gem(Vector((0.13,-0.05,hgt(.13,-.05)+0.015)),0.026,6)
# goblet: lathe
gp=[(0.0,0),(0.025,0),(0.025,.01),(0.009,.02),(0.009,.05),(0.03,.065),(0.036,.10),(0.028,.10)]
seg=8
rg=[[bm.verts.new((r*math.cos(2*math.pi*k/seg),r*math.sin(2*math.pi*k/seg),z)) for k in range(seg)] for r,z in gp[1:]]
gf=[]
for a in range(len(rg)-1):
    for k in range(seg):
        k2=(k+1)%seg
        gf.append(bm.faces.new((rg[a][k],rg[a][k2],rg[a+1][k2],rg[a+1][k])))
gv=list({v for f in gf for v in f.verts})
cc=hgt(.02,.09)
bmesh.ops.transform(bm,verts=gv,matrix=Matrix.Translation((0.02,0.09,cc-.01))@Matrix.Rotation(.45,4,'X')@Matrix.Rotation(.3,4,'Y'))
setcol(gf,3)
bmesh.ops.recalc_face_normals(bm,faces=bm.faces)
# dome normals must point outward: recalc handles. triangulate
bmesh.ops.triangulate(bm,faces=bm.faces)
me=bpy.data.meshes.new("gold-pile"); bm.to_mesh(me)
for p in me.polygons: p.use_smooth=False
o=bpy.data.objects.new("gold-pile",me); bpy.context.scene.collection.objects.link(o)
m=bpy.data.materials.new("gold"); m.use_nodes=True
b=m.node_tree.nodes["Principled BSDF"]
t=m.node_tree.nodes.new("ShaderNodeTexImage"); t.image=bpy.data.images.load(bpy.path.abspath("//source/palette.png") if False else sys.argv[-1]); t.interpolation="Closest"
m.node_tree.links.new(t.outputs[0],b.inputs["Base Color"])
b.inputs["Metallic"].default_value=0.35; b.inputs["Roughness"].default_value=0.5
me.materials.append(m)
print("TRIS",len(me.polygons))
mn=Vector(o.bound_box[0]);mx=Vector(o.bound_box[6]);print("BB",mn,mx)
bpy.ops.export_scene.gltf(filepath="source/edited.glb",export_format="GLB")
