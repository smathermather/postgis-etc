CREATE OR REPLACE FUNCTION volumetricIntersection(geom1 geometry, geom2 geometry)
  RETURNS geometry AS
$BODY$

WITH 
intersected AS (
	SELECT ST_3DIntersection(geom1, geom2) AS the_geom
	),
dumped AS (
	SELECT (ST_Dump(the_geom)).geom AS the_geom FROM intersected
	),
triangles AS (
	SELECT ST_Collect(the_geom) AS the_geom FROM dumped
		WHERE ST_GeometryType(the_geom) ='ST_Triangle'
	),
triangleText AS (
	SELECT ST_AsText(the_geom) AS triText FROM triangles
	),
replaceTriangle AS (
	SELECT replace(triText, 'TRIANGLE Z ', '') AS rTri FROM triangleText
	),
tinText AS (
	SELECT replace(rTri, 'GEOMETRYCOLLECTION', 'TIN') AS tt FROM replaceTriangle
	),
tin AS (
	SELECT ST_GeomFromText(tt) AS the_geom FROM tinText
	)
	
SELECT the_geom FROM tin;

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
