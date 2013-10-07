-- Creates a set of functions and type to allow average compass heading
-- computation by the database
--
-- given a table foo 
-- with a double precision column containing compass direction in degrees (0 - 359) named degrees
--
--     select avg_dir(degrees) from foo;
--
-- will return the correct average direction.
--
-- The data is assumed to be valid (0.0 >= degrees < 360.0). This can be enforced with
-- a column constraint, or by modifying the sfunc_dir function to apply a mod operator
-- prior to computation.
--
-- Copyright 2013, bechter.com - All Rights Reserved
--   see LICENSE

drop aggregate avg_dir(double precision);
drop function ffunc_dir(stype_dir);
drop function sfunc_dir(stype_dir, double precision);
drop type stype_dir;

create type stype_dir as (
    u double precision,
    v double precision,
    n integer
);

create function sfunc_dir(stype_dir, double precision) returns stype_dir as $$
select $1.u - sin($2 * 0.017453293), $1.v - cos($2 * 0.017453293), $1.n + 1;
$$ language sql;

create function ffunc_dir(stype_dir) returns double precision as $$
select cast(mod(cast((270.0 - (atan2($1.v / $1.n, $1.u / $1.n) * 57.29577951)) as numeric), 360.0) as double precision);
$$ language sql;

create aggregate avg_dir(double precision) (
    sfunc = sfunc_dir,
    stype = stype_dir,
    finalfunc = ffunc_dir,
    initcond = '(0.0, 0.0, 0)'
);

