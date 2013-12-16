-- Function creates an inverted pyramid
-- Function takes as input an origin point, the size base in x and y, and the height of the pyramid
-- Usage example: SELECT 1 pyramid_maker(geom, 2, 2, 1)  AS the_geom;
CREATE OR REPLACE FUNCTION pyramidMaker(origin geometry, basex numeric, basey numeric, height numeric)
  RETURNS geometry AS
$BODY$

-- Create points as the base of the pyramid-- which perversly is in the air... .
WITH basePoints1 AS
	(
	SELECT ST_Translate(origin, -0.5 * basex, 0.5 * basey) AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, 0.5 * basex, 0.5 * basey) AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, 0.5 * basex, -0.5 * basey) AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, -0.5 * basex, 0.5 * basey) AS the_geom
	),
-- Make the points into a line so we can convert to polygon
basePointsC1 AS
	(
	SELECT ST_MakeLine(the_geom) AS the_geom FROM basePoints1
	),	
baseBox1 AS
	(
	SELECT ST_MakePolygon(ST_Force3DZ(the_geom)) AS the_geom FROM basePointsC1
	),
-- move base of pyramid vertically the input height
base1 AS
	(
	SELECT ST_Translate(the_geom, 0, 0, height) AS the_geom FROM baseBox1
	),
basePoints2 AS
	(
	SELECT ST_Translate(origin, -0.5 * basex, 0.5 * basey) AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, 0.5 * basex, -0.5 * basey) AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, -0.5 * basex, -0.5 * basey) AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, -0.5 * basex, 0.5 * basey) AS the_geom
	),
-- Make the points into a line so we can convert to polygon
basePointsC2 AS
	(
	SELECT ST_MakeLine(the_geom) AS the_geom FROM basePoints2
	),	
baseBox2 AS
	(
	SELECT ST_MakePolygon(ST_Force3DZ(the_geom)) AS the_geom FROM basePointsC2
	),
-- move base of pyramid vertically the input height
base2 AS
	(
	SELECT ST_Translate(the_geom, 0, 0, height) AS the_geom FROM baseBox2
	),
-- Now we construct the triangles, ensuring that we digitize them counterclockwise for validity
triOnePoints AS
	(
	SELECT origin AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, 0.5 * basex, 0.5 * basey, height) AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, -0.5 * basex, 0.5 * basey, height) AS the_geom
		UNION ALL
	SELECT origin AS the_geom
	),
triOneAngle AS
	(
	SELECT ST_MakePolygon(ST_MakeLine(the_geom)) the_geom FROM triOnePoints
	),
triTwoPoints AS
	(
	SELECT origin AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, 0.5 * basex, -0.5 * basey, height) AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, 0.5 * basex, 0.5 * basey, height) AS the_geom
		UNION ALL
	SELECT origin AS the_geom
	),
triTwoAngle AS
	(
	SELECT ST_MakePolygon(ST_MakeLine(the_geom)) the_geom FROM triTwoPoints
	),
triThreePoints AS
	(
	SELECT origin AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, -0.5 * basex, -0.5 * basey, height) AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, 0.5 * basex, -0.5 * basey, height) AS the_geom
		UNION ALL
	SELECT origin AS the_geom
	),
triThreeAngle AS
	(
	SELECT ST_MakePolygon(ST_MakeLine(the_geom)) the_geom FROM triThreePoints
	),
triFourPoints AS
	(
	SELECT origin AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, -0.5 * basex, 0.5 * basey, height) AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, -0.5 * basex, -0.5 * basey, height) AS the_geom
		UNION ALL
	SELECT origin AS the_geom
	),
triFourAngle AS
	(
	SELECT ST_MakePolygon(ST_MakeLine(the_geom)) the_geom FROM triFourPoints
	),
-- Assemble the whole thing into a pyramid
pyramid AS
	(
	SELECT the_geom FROM triOneAngle
		UNION ALL
	SELECT the_geom FROM triTwoAngle
		UNION ALL
	SELECT the_geom FROM triThreeAngle
		UNION ALL
	SELECT the_geom FROM triFourAngle
		UNION ALL
	SELECT the_geom FROM base1
		UNION ALL
	SELECT the_geom FROM base2
	),
-- format the pyramid temporarily as a 3D multipolygon
pyramidMulti AS
	(
	SELECT ST_Multi(St_Collect(the_geom)) AS the_geom FROM pyramid
	),
-- convert to text in order to manipulate with a find/replace into a polyhedralsurface
-- and then convert back to binary
textPyramid AS
	(
	SELECT ST_AsText(the_geom) AS textpyramid FROM pyramidMulti
	),
textBuildSurface AS
	(
	SELECT ST_GeomFromText(replace(textpyramid, 'MULTIPOLYGON', 'POLYHEDRALSURFACE')) AS the_geom FROM textPyramid
	)

SELECT the_geom FROM textBuildSurface

;

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION pyramidMaker(geometry, numeric, numeric, numeric)
  OWNER TO me;
