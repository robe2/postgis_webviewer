--version 0.4 --
CREATE OR REPLACE FUNCTION postgis_viewer_image(param_sql text, param_spatial_type text DEFAULT 'geometry'::text, param_rgb integer[] DEFAULT NULL::integer[])
  RETURNS bytea AS
$$
  DECLARE var_result bytea;
  DECLARE var_bandtypes text[] := ARRAY['8BUI', '8BUI', '8BUI'];
  DECLARE var_geom geometry;
  BEGIN
      IF param_spatial_type = 'geometry' THEN
		EXECUTE 'WITH data AS (SELECT (' || param_sql || ') AS geom )' ||
        'SELECT ST_AsPNG(ST_AsRaster(geom, 200, (greatest(50,200*(ST_YMax(geom)-ST_YMin(geom)))/greatest(10,(ST_XMax(geom)-ST_XMin(geom))))::integer,$1,$2, ARRAY[0,0,0])) FROM data ' INTO STRICT var_result USING var_bandtypes, param_rgb ;
      ELSIF param_spatial_type = 'raster' THEN
        EXECUTE 'SELECT ST_AsPNG((' || param_sql || '), ARRAY[1,2,3])' INTO STRICT var_result;
	  ELSE -- assume raw
		EXECUTE param_sql INTO STRICT var_result;
      END IF;
      RETURN var_result;
 END ;
$$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
