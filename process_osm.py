import sys
import json
from os import path
import argparse
import osmium

from src.highways import HighwaysWriter
from src.buildings import BuildingsWriter

LAYERS = {
    "highways": HighwaysWriter,
    "buildings": BuildingsWriter,
}


def main():
    parser = argparse.ArgumentParser(
        description="Process OSM data into multiple GeoParquet files"
    )
    parser.add_argument("osm_file", help="Input OSM PBF file")
    parser.add_argument(
        "output_dir", help="Directory to write output GeoParquet files to"
    )
    parser.add_argument(
        "--osmium-idx",
        default="flex_mem",
        help="Osmium index type to use for node locations (see https://osmcode.org/osmium-concepts/)",
    )

    for layer_name in LAYERS.keys():
        parser.add_argument(
            "--" + layer_name,
            action=argparse.BooleanOptionalAction,
            help=f"Whether to write {layer_name} layer",
        )

    args = parser.parse_args()

    enabled_layers = {
        layer_name for layer_name in LAYERS.keys() if getattr(args, layer_name)
    }
    if not enabled_layers:
        # if no layers are provided as CLI arguments, default to building them all
        enabled_layers = set(LAYERS.keys())

    # Create writers for each output type
    writers = []
    tag_name_filters = set()
    for layer_name in enabled_layers:
        layer_class = LAYERS[layer_name]
        output_path = path.join(args.output_dir, f"{layer_name}.parquet")

        writers.append(layer_class(output_path))
        if not layer_class.FILTERS:
            raise NotImplementedError(f"Writer {layer_name} has no FILTERS defined!")
        tag_name_filters.update(layer_class.FILTERS)

    filters = [
        osmium.filter.EmptyTagFilter(),
        osmium.filter.KeyFilter(*tag_name_filters),
    ]

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
                if hasattr(writer, "node"):
                    writer.node(o)

        def way(self, o):
            for writer in self.writers:
                if hasattr(writer, "way"):
                    writer.way(o)

        def relation(self, o):
            for writer in self.writers:
                if hasattr(writer, "relation"):
                    writer.relation(o)

        def area(self, o):
            for writer in self.writers:
                if hasattr(writer, "area"):
                    writer.area(o)

    # Create and run the handler
    handler = MultiHandler(writers)
    handler.apply_file(
        args.osm_file,
        filters=filters,
        idx=args.osmium_idx,
    )

    # Finish all writers
    for writer in writers:
        writer.finish()

    # Write metadata
    reader = osmium.io.Reader(args.osm_file)
    header = reader.header()
    metadata = {
        "timestamp": header.get("timestamp"),
        "seqno": header.get("osmosis_replication_sequence_number"),
    }

    with open(path.join(args.output_dir, "metadata.json"), "w") as f:
        json.dump(metadata, f, indent=2)
        f.write("\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
