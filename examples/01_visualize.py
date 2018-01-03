# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <markdowncell>

# An example of interactively exploring a model. By doing imports and file 
# parsing in dedicated cells, results of time-consuming operations can be 
# re-used. 


# <codecell>


import ifcopenshell
import ifcopenshell.geom

f = ifcopenshell.open("models/Duplex_A_20110907_optimized.ifc")

# <markdowncell>

# The same applies to the geometry generation, which is in general more 
# time consuming then parsing. PythonOCC TopoDS_Shapes are stored in a 
# global dictionary for later use. `ifcopenshell.geom.iterator` is more 
# efficient than `ifcopenshell.geom.create_shape()` as it is able to cache 
# shared definitions for subsequent products. 


# <codecell>


s = ifcopenshell.geom.settings()
s.set(s.USE_PYTHON_OPENCASCADE, True)
geometry = dict((f[item.data.id], (item.geometry, item.styles)) for item in ifcopenshell.geom.iterator(s, f))


# <codecell>


from ifc_viewer import ifc_viewer
        
viewer = ifc_viewer()

for product, (shape, styles) in geometry.items():
    if not product.is_a("IfcWall"): continue
    viewer.DisplayShape(product, shape, styles)
    
viewer.Display()

