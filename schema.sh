#!/bin/sh

# Generate Markdown documentation for the columns produced by each SQL layer.
# Usage: ./schema.sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SQL_DIR="$SCRIPT_DIR/sql"
OUTPUT="$SCRIPT_DIR/SCHEMA.md"

TMP_OUTPUT=$(mktemp "$OUTPUT.tmp.XXXXXX")
cleanup() {
    rm -f "$TMP_OUTPUT"
}
trap cleanup EXIT HUP INT TERM

{
    printf '%s\n' '# Layercake schema' '' \
        'Generated from the SQL layer definitions in [`sql/`](sql/).' ''

    found_layer=0
    for sql_file in "$SQL_DIR"/*.sql; do
        [ -f "$sql_file" ] || continue

        table=$(basename "$sql_file" .sql)
        [ "$table" = 'macros' ] && continue
        found_layer=1

        printf '## %s\n\n' "$table"

        awk '
            # Remove whitespace around an extracted column name.
            function trim(value) {
                sub(/^[[:space:]]+/, "", value)
                sub(/[[:space:]]+$/, "", value)
                return value
            }

            # The second SELECT is the layer output schema. Start reading
            # columns there rather than the SELECT in the raw CTE.
            /^[[:space:]]*SELECT[[:space:]]*$/ {
                in_output_select = 1
                next
            }

            # The output column list ends immediately before FROM raw.
            in_output_select && /^[[:space:]]*FROM[[:space:]]+raw[[:space:]]*$/ {
                exit
            }

            in_output_select {
                # Normalize the line before examining the selected expression.
                line = $0
                sub(/^[[:space:]]+/, "", line)
                sub(/[[:space:]]*,[[:space:]]*$/, "", line)

                # Ignore comments and the fields inside the bbox struct.
                if (line ~ /^--/ || line ~ /^[{]/ || line ~ /^}[[:space:]]*$/ || line == "")
                    next

                # type, id, and geometry are selected without aliases.
                if (line == "type" || line == "id" || line == "geometry") {
                    column = line
                # For expressions, keep the name following AS as the column.
                } else if (line ~ /[[:space:]]+AS[[:space:]]+/) {
                    sub(/^.*[[:space:]]+AS[[:space:]]+/, "", line)
                    column = trim(line)
                    # SQL permits aliases surrounded by single or double
                    # quotes (and backticks), which are not part of the name.
                    quote = sprintf("%c", 39)
                    if (substr(column, 1, 1) == quote || substr(column, 1, 1) == "\"" || substr(column, 1, 1) == "`")
                        column = substr(column, 2)
                    if (substr(column, length(column), 1) == quote || substr(column, length(column), 1) == "\"" || substr(column, length(column), 1) == "`")
                        column = substr(column, 1, length(column) - 1)
                } else {
                    next
                }

                if (column_count++ > 0)
                    printf ", "
                printf "`%s`", column
            }

            END {
                printf "\n"
            }
        ' "$sql_file"
    done

    if [ "$found_layer" -eq 0 ]; then
        printf '%s\n' '_No SQL layer files found._'
    fi
} > "$TMP_OUTPUT"

mv "$TMP_OUTPUT" "$OUTPUT"
trap - EXIT HUP INT TERM
printf 'Generated %s\n' "$OUTPUT"
