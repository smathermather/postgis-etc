-- Function creates an inverted pyramid
-- Function takes as input an origin point, the size base in x and y, and the height of the pyramid
-- Usage example: SELECT 1 pyramid_maker(geom, 2, 2, 1)  AS the_geom;
CREATE OR REPLACE FUNCTION chp07.pyramidMaker(origin geometry, basex numeric, basey numeric, height numeric)
  RETURNS geometry AS
$BODY$

WITH basePoints AS
	(
	SELECT ST_Translate(origin, -0.5 * basex, 0.5 * basey) AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, 0.5 * basex, 0.5 * basey) AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, 0.5 * basex, -0.5 * basey) AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, -0.5 * basex, -0.5 * basey) AS the_geom
		UNION ALL
	SELECT ST_Translate(origin, -0.5 * basex, 0.5 * basey) AS the_geom
	),
basePointsC AS
	(
	SELECT ST_MakeLine(the_geom) AS the_geom FROM basePoints
	),	
baseBox AS
	(
	SELECT ST_MakePolygon(ST_Force3DZ(the_geom)) AS the_geom FROM basePointsC
	),
base AS
	(
	SELECT ST_Translate(the_geom, 0, 0, height) AS the_geom FROM baseBox
	),
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
	SELECT the_geom FROM base
	),
pyramidMulti AS
	(
	SELECT ST_Multi(St_Collect(the_geom)) AS the_geom FROM pyramid
	),
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
ALTER FUNCTION chp07.pyramid_maker(geometry, numeric, numeric, numeric)
  OWNER TO me;
