#!/bin/sh

duckdb << EOF | cat # workaround for https://github.com/duckdb/duckdb/issues/21253
LOAD SPATIAL;

COPY (
    SELECT *
    FROM '$1'
    ORDER BY ST_Hilbert(
        geometry,
        (
            SELECT ST_Extent(ST_Extent_Agg(geometry))
            FROM '$1'
        )
    )
)
TO '$2' (
    FORMAT PARQUET,
    COMPRESSION ZSTD,
    COMPRESSION_LEVEL 10
    -- TBD: Partitioning; row group size by bytes?
);
EOF
