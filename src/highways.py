import sys
import osmium
from .geoparquet import GeoParquetWriter

class HighwaysWriter(GeoParquetWriter):    
    TAGS = [
        # type and subtypes
        'highway',
        'service',
        'crossing',
        'footway',
        'construction',
        
        # identifiers
        'name',
        'ref',

        # physical properties
        'bridge',
        'covered',
        'lanes',
        'layer',
        'lit',
        'sidewalk',
        'smoothness',
        'surface',
        'tracktype',
        'tunnel',
        'wheelchair',
        'width',
        
        # access and restrictions
        'access',
        'bicycle',
        'bus',
        'foot',
        'hgv',
        'maxspeed',
        'motor_vehicle',
        'motorcycle',
        'oneway',
        'toll',
    ]
    
    def __init__(self, filename):
        super().__init__(filename, self.TAGS)
        
    def node(self, o):
        if 'highway' not in o.tags:
            return
            
        try:
            self.append("node", o.id, o.tags, self.wkbfactory.create_point(o))
        except RuntimeError as e:
            print(e, file=sys.stderr)

    def way(self, o):
        if 'highway' not in o.tags:
            return
            
        if o.is_closed() and o.tags.get("area") == "yes":
            # closed ways explicitly tagged area=yes are polygons
            # (they will be handled by area() below)
            return
            
        try:
            self.append("way", o.id, o.tags, self.wkbfactory.create_linestring(o))
        except RuntimeError as e:
            print(e, file=sys.stderr)

    def area(self, o):

        if 'highway' not in o.tags:
            return
            
        if o.from_way() and o.tags.get("area") != "yes":
            # closed ways with highway=* aren't areas unless they are also
            # tagged area=yes (these elements will be handled by way() above)
            return
        
        try:
            self.append(
                "way" if o.from_way() else "relation",
                o.orig_id(),
                o.tags,
                self.wkbfactory.create_multipolygon(o)
            )
        except RuntimeError as e:
            print(e, file=sys.stderr) 