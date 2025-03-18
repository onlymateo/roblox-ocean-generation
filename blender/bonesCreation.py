import bpy
import mathutils

plane = bpy.data.objects['Plane']
bpy.context.view_layer.objects.active = plane

bpy.ops.object.mode_set(mode='EDIT')
mesh = bpy.context.object.data
vertices = [plane.matrix_world @ v.co for v in mesh.vertices]

bpy.ops.object.mode_set(mode='OBJECT')

vertices_sorted = sorted(vertices, key=lambda v: (v.y, v.x))

bpy.ops.object.armature_add(enter_editmode=True)
armature = bpy.context.object
edit_bones = armature.data.edit_bones

for i, vertex in enumerate(vertices_sorted):
    bone = edit_bones.new(name=f'Bone_{i+1:03}')
    bone.head = vertex
    bone.tail = vertex + mathutils.Vector((0, 0, 0.1))
    print(f'Bone: {bone.name}, Head: {bone.head}, Tail: {bone.tail}')

bpy.ops.object.mode_set(mode='OBJECT')

bpy.context.view_layer.objects.active = armature
bpy.ops.object.mode_set(mode='POSE')