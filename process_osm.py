import sys
import argparse
import osmium

from src.highways import HighwaysWriter
from src.buildings import BuildingsWriter

def main():
    parser = argparse.ArgumentParser(description='Process OSM data into multiple GeoParquet files')
    parser.add_argument('osm_file', help='Input OSM PBF file')
    parser.add_argument('--highways', help='Output file for highways')
    parser.add_argument('--buildings', help='Output file for buildings')
    # Add more output file arguments as needed
    
    args = parser.parse_args()
    
    # Create writers for each output type
    writers = []
    if args.highways:
        writers.append(HighwaysWriter(args.highways))
    if args.buildings:
        writers.append(BuildingsWriter(args.buildings))
    
    if not writers:
        print("Error: No output files specified", file=sys.stderr)
        return 1
    
    # Create a handler that forwards calls to all writers
    class MultiHandler(osmium.SimpleHandler):
        def __init__(self, writers):
            super().__init__()
            self.writers = writers
            
        def node(self, o):
            for writer in self.writers:
                if hasattr(writer, 'node'):
                    writer.node(o)
                
        def way(self, o):
            for writer in self.writers:
                if hasattr(writer, 'way'):
                    writer.way(o)
                
        def area(self, o):
            for writer in self.writers:
                if hasattr(writer, 'area'):
                    writer.area(o)
    
    # Create and run the handler
    handler = MultiHandler(writers)
    
    handler.apply_file(
        args.osm_file,
        filters=[osmium.filter.EmptyTagFilter()]
    )

    # Finish all writers
    for writer in writers:
        writer.finish()
    
    return 0

if __name__ == '__main__':
    sys.exit(main()) 