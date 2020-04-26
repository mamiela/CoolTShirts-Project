# How many campaigns and sources does CoolTShirts use? Which source is used for each campaign?

SELECT COUNT(DISTINCT utm_campaign)
FROM page_visits;

SELECT COUNT(DISTINCT utm_source)
FROM page_visits;

SELECT utm_campaign, utm_source
FROM page_visits
GROUP BY 1;

# What pages are on the CoolTShirts website?

SELECT DISTINCT page_name
FROM page_visits;

# How many first touches is each campaign responsible for?

WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id)
SELECT ft.first_touch_at, pv.utm_source, pv.utm_campaign, COUNT(DISTINCT ft.user_id) as cft
FROM first_touch ft
JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp
GROUP BY 3
ORDER BY 4 DESC;


# How many last touches is each campaign responsible for?

WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id)
SELECT pv.utm_source, pv.utm_campaign, COUNT(DISTINCT lt.user_id)
FROM last_touch lt
JOIN page_visits pv
ON lt.last_touch_at = pv.timestamp
AND lt.user_id = pv.user_id
GROUP BY 2
ORDER BY 3 DESC;

# How many visitors make a purchase?

SELECT COUNT(DISTINCT user_id)
FROM page_visits
WHERE page_name = '4 - purchase';

# How many last touches on the purchase page is each campaign responsible for?

WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    WHERE page_name = '4 - purchase'
    GROUP BY user_id)
SELECT pv.utm_source, pv.utm_campaign, COUNT(DISTINCT lt.user_id)
FROM last_touch lt
JOIN page_visits pv
ON lt.last_touch_at = pv.timestamp
AND lt.user_id = pv.user_id
GROUP BY 2
ORDER BY 3 DESC;

#CoolTShirts can re-invest in 5 campaigns. Given your findings in the project, which should they pick and why?

WITH first_touch AS (
   SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id),
cft AS (
  SELECT pv.utm_source, pv.utm_campaign, COUNT(DISTINCT ft.user_id) as cft1
FROM first_touch ft
JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp
  GROUP BY 2
  ORDER BY 3 DESC),
last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id),
clt AS (
SELECT pv.utm_source, pv.utm_campaign, COUNT(DISTINCT lt.user_id) as clt1
FROM last_touch lt
JOIN page_visits pv
ON lt.last_touch_at = pv.timestamp
AND lt.user_id = pv.user_id
GROUP BY 2
ORDER BY 3 DESC),
purchase_touch AS (
    SELECT user_id,
        MAX(timestamp) as purchase_touch_at
    FROM page_visits
    WHERE page_name = '4 - purchase'
    GROUP BY user_id),
cpt AS(
SELECT pv.utm_source, pv.utm_campaign, COUNT(DISTINCT pt.user_id) as cpt1
FROM purchase_touch pt
JOIN page_visits pv
ON pt.purchase_touch_at = pv.timestamp
AND pt.user_id = pv.user_id
GROUP BY 2
ORDER BY 3 DESC),
todo AS(
SELECT *
FROM cpt
LEFT JOIN clt
ON clt.utm_campaign = cpt.utm_campaign
LEFT JOIN cft
ON cft.utm_campaign = cpt.utm_campaign)
SELECT todo.utm_source, todo.utm_campaign, cft1, clt1, cpt1
FROM todo;

