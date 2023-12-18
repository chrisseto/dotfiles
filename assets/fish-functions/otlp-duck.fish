function otlp-duck
	set filename $argv[1]
	set script "CREATE OR REPLACE TABLE spans AS
WITH
	unwrapped_spans AS (
		SELECT unnest(spans.spans, recursive := true) FROM (SELECT unnest(instrumentation_library_spans) AS spans  FROM ( SELECT unnest(resource_spans, recursive:=true) FROM read_ndjson_auto('$filename')))
	), span_attrs AS (
		SELECT
			span_id,
			json_group_object(key, COALESCE(value->'StringValue', value->'BoolValue', value->'IntValue', value->'ArrayValue')) as attributes,
		FROM (SELECT span_id, key, Value::JSON as value  FROM (SELECT span_id, unnest(attributes, max_depth:=3) FROM unwrapped_spans))
		GROUP BY span_id
	)
SELECT
	trace_id,
    unwrapped_spans.span_id,
    parent_span_id,
    name,
	make_timestamp(start_time_unix_nano//1000) as start,
	make_timestamp(end_time_unix_nano//1000) as end,
	message as error,
	span_attrs.attributes,
FROM unwrapped_spans JOIN span_attrs ON span_attrs.span_id = unwrapped_spans.span_id;"

	duckdb -init (echo $script | psub)
end
