COPY (SELECT EXISTS(SELECT 1 FROM work.resources) AS catalogPresent,
 object_count AS objectCount,attribute_count AS attributeCount FROM runtime.parameters)
TO ${result_file} (FORMAT JSON, ARRAY true);
