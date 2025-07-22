#!/bin/sh

echo $@

duckdb << EOF
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
    COMPRESSION ZSTD
    -- TBD: Partitioning; row group size by bytes?
);
EOF
