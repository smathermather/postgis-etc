-- A small function to convert ST_Delaunay (requires GEOS 3.4) to a 2.5D Tin
-- Uses the hackerish approach of converting to text, and doing string replacement
--- for format conversion.

-- A Delaunay triangulation does not by itself formally make a TIN.  To do this,
-- we will require some modification to the output format.  If we perform an ST_AsText
-- on our new geometries we will see that they are POLYGON Z's wrapped in a
-- GEOMETRYCOLLECTION.

-- Thus there are two ways in which this is not a TIN-- the internal POLYGON Z are
-- implicitly triangles, but explicitly POLYGON Zs.  In addition, the external wrapper
-- for the collection of triangles is a GEOMETRYCOLLECTION, not a TIN.
-- Once that we have this geometry in text form, the easiest way to fix this is
-- with string replacement to fix these two things, then convert back to binary

CREATE OR REPLACE FUNCTION chp07.AsTIN(geometry)
  RETURNS geometry AS
$BODY$


WITH dt AS
(
SELECT ST_AsText(ST_DelaunayTriangles(ST_Collect($1))) AS atext
),
replacedt AS
(
-- Remove polygon z designation, as TINs don't require it.
SELECT replace(atext, 'POLYGON Z', '') as ttext
  FROM dt
),
replacegc AS
(
-- change leading declaration to TIN
SELECT replace(ttext, 'GEOMETRYCOLLECTION Z', 'TIN') AS tintext
  from replacedt
),
tingeom AS
(
-- Aaaand convert back to binary.  Voila!
SELECT ST_GeomFromEWKT(tintext) AS the_geom FROM replacegc
)

SELECT the_geom FROM tingeom

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION chp07.AsTIN(geometry)
  OWNER TO postgres;
