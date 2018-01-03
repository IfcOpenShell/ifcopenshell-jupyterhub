# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <markdowncell>

# <codecell>

import ifcopenshell
import ifcopenshell.geom

from matplotlib import pyplot as plt
from collections import defaultdict 


# <codecell>


f = ifcopenshell.open("models/Duplex_A_20110907_optimized.ifc")


# <codecell>


def get_key_values(pset):
    def to_tuple(prop):
        if prop.is_a("IfcPropertySingleValue"):
            return prop.Name, prop.NominalValue.wrappedValue
        elif prop.is_a("IfcPhysicalQuantity"):
            return prop.Name, prop[2]
        
    if pset.is_a("IfcPropertySet"):
        return tuple(map(to_tuple, pset.HasProperties))
    elif pset.is_a("IfcElementQuantity"):
        return tuple(map(to_tuple, pset.Quantities))
    else: return ()

def get_space_volumes():
    for space in f.by_type("IfcSpace"):
        key_values = [get_key_values(rel.RelatingPropertyDefinition) for rel in space.IsDefinedBy]
        props = dict(sum(key_values, ()))
        yield space, props.get("Volume")
    
space_volumes = list(get_space_volumes())


# <codecell>


get_ipython().run_line_magic('matplotlib', 'inline')

plt.figure(figsize=(10,5))
plt.title("Distribution of space volumes")
plt.hist([v[1] for v in space_volumes], bins=24);


# <codecell>


get_ipython().run_line_magic('matplotlib', 'inline')

by_category = defaultdict(float)

for space, volume in space_volumes:
    cat = "".join(filter(str.isalpha, space.LongName))
    by_category[cat] += volume
    
plt.figure(figsize=(10,5))
plt.title("Distribution of space volumes")
plt.bar(list(by_category.keys()), list(by_category.values()));

