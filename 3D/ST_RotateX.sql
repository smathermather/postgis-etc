-- Function: st_rotatex(geometry, double precision, geometry)
CREATE OR REPLACE FUNCTION ST_RotateX(geomA geometry, rotRadians double precision, pointOrigin geometry)
  RETURNS geometry AS
$BODY$

----- Transform geometry to nullsville (0,0,0) so rotRadians will take place around the pointOrigin
WITH transformed AS (
    SELECT ST_Translate(geomA, -1 * ST_X(pointOrigin), -1 * ST_Y(pointOrigin), -1 * ST_Z(pointOrigin)) AS the_geom
    ),
----- Rotate in place
rotated AS (
    SELECT ST_RotateX(the_geom, rotRadians) AS the_geom FROM transformed
    ),
----- Translate back home
rotTrans AS (
    SELECT ST_Translate(the_geom, ST_X(pointOrigin), ST_Y(pointOrigin), ST_Z(pointOrigin)) AS the_geom
	FROM rotated
    )
----- profit
SELECT the_geom from rotTrans

;

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
