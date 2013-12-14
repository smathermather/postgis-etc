CREATE OR REPLACE FUNCTION volumetricIntersection(geom1 geometry, geom2 geometry)
-- volumetric intersection takes an the input of two 3D geometries
  RETURNS geometry AS
$BODY$

WITH 
intersected AS (
-- first we perform an intersection. This in most cases will return a TIN plus 3D linstrings
-- and other messy pieces we don't need.
	SELECT ST_3DIntersection(geom1, geom2) AS the_geom
	),
-- we use ST_Dump to dump these out to their requisite parts
-- (no, ST_CollectionExtract will not work here-- it only handles
-- points, lines, and polygons, not triangles and tins
dumped AS (
	SELECT (ST_Dump(the_geom)).geom AS the_geom FROM intersected
	),
-- Now we filter for triangle and collect them together
triangles AS (
	SELECT ST_Collect(the_geom) AS the_geom FROM dumped
		WHERE ST_GeometryType(the_geom) ='ST_Triangle'
	),
-- next as a venerable hack, we'll convert to text
triangleText AS (
	SELECT ST_AsText(the_geom) AS triText FROM triangles
	),
-- and replace words in the text in order to "convert" from a collection
-- of triangles to a TIN
replaceTriangle AS (
	SELECT replace(triText, 'TRIANGLE Z ', '') AS rTri FROM triangleText
	),
tinText AS (
	SELECT replace(rTri, 'GEOMETRYCOLLECTION', 'TIN') AS tt FROM replaceTriangle
	),
-- now we convert back to a binary tin, and give it back to the user
tin AS (
	SELECT ST_GeomFromText(tt) AS the_geom FROM tinText
	)
	
SELECT the_geom FROM tin;

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
