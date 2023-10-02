-- Consulta que nos muestre el pago promedio por cada alquiler.

-- Cada fila:
-- Tienda (distrito, ciudad)
-- Mayo2005, pago promedio
-- Junio2005
-- Diferencia -> Junio - Mayo
-- % crecimiento -> (Junio - Mayo) / Mayo
-- Julio2005
-- Diferencia 2 -> Julio - Junio
-- % crecimeinto2 -> (Julio - Junio) / Junio

-- Consulta que nos muestre el pago promedio por cada alquiler.

use sakila;

with datos_pagos as (
    select
        staff_id,
        MONTH(payment_date) as mes,
        YEAR(payment_date) as annio,
        SUM(amount) as amount
    from payment
    group by
        staff_id,
        MONTH(payment_date),
        YEAR(payment_date)
),

datos_alquiler as (
    select
        staff_id,
        MONTH(rental_date) as mes,
        YEAR(rental_date) as annio,
        COUNT(*) as qty
    from rental
    group by
        staff_id,
        MONTH(rental_date),
        YEAR(rental_date)
),

datos_y_alquiler as (
    select *
    from datos_alquiler
    join datos_pagos using(staff_id, mes, annio)
),
datos_mes as (
    select
        d.staff_id,
        d.mes,
        d.annio,
        s.store_id,
        a.address,
        c.city,
        SUM(d.qty) as total_qty,
        AVG(d.amount) as avg_payment
    from datos_y_alquiler d
    join staff s using (staff_id)
    join store st using (store_id)
    join address a on st.address_id = a.address_id 
    join city c using (city_id)
    group by
        d.staff_id,
        d.mes,
        d.annio,
        s.store_id,
        a.address,
        c.city
),
datos_mes_col as (
    select
        store_id,
        address,
        city,
        SUM(case when annio = 2005 and mes = 5 then avg_payment else 0 end) as mayo2005,
        SUM(case when annio = 2005 and mes = 6 then avg_payment else 0 end) as junio2005,
        SUM(case when annio = 2005 and mes = 7 then avg_payment else 0 end) as julio2005
    from datos_mes
    group by 
        store_id,
        address,
        city
)

select
    CONCAT(dm.address, ', ', dm.city) as Tienda,
    mayo2005,
    junio2005,
    junio2005 - mayo2005 as Diferencia1,
    (junio2005 - mayo2005) / mayo2005 as Crecimiento1,
    julio2005,
    julio2005 - junio2005 as Diferencia2,
    (julio2005 - junio2005) / junio2005 as Crecimiento2
from datos_mes_col dm;