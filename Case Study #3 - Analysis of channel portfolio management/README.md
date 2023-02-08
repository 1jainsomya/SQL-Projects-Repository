##	Analysis of channel portfolio management Document
##	Analysing which channels generate more search and paid and free traffic comparison along with device type traffic distribution
####	Author Somya Jain

### Q1. Comparing channel portfolio sources

USE mavenfuzzyfactory;
SELECT
MIN(DATE(created_at)) AS week_start_date,
COUNT(DISTINCT website_session_id) AS total_sessions,
COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
   COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-29'
AND utm_campaign = 'nonbrand'
GROUP BY
YEARWEEK(created_at);
 
![image](https://user-images.githubusercontent.com/38453077/217521430-94691c25-ea56-4ad1-87f7-29a2c05759be.png)


### Conclusion-
Gsearch seems to be three times larger than bsearch and it is consistent across majority weeks

### Q2. Comparing Channel Characteristics
SELECT
	utm_source,
    COUNT(DISTINCT website_session_id) AS total_sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS pct_mobile
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-30'
	AND utm_campaign = 'nonbrand'
GROUP BY
	utm_source

![image](https://user-images.githubusercontent.com/38453077/217521470-ded11994-7460-4a02-bd43-34bfdb7ca791.png)


### Conclusion-
Gsearch perform more better in mobile search as compared to bsearch
   

### Q3. Device and utm source investigation 
SELECT
	website_sessions.device_type,
    website_sessions.utm_source,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(order_id) AS orders,
    COUNT(order_id) / COUNT(website_sessions.website_session_id) AS conv_rate
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-08-22' AND '2012-09-18'
	AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1, 2
ORDER BY 1;        
 
![image](https://user-images.githubusercontent.com/38453077/217521501-06dc8426-a98d-4ced-88bc-7402cfb06163.png)


### Conclusion-
Gsearch outperforms bsearch in both desktop and mobile with 0.04 and 0.01 conversion rate sessions by orders

### Q4. Channel portfolio trends
SELECT
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN (device_type = 'desktop' AND utm_source = 'gsearch') THEN website_session_id ELSE NULL END) AS g_dtop_sessions,
    COUNT(DISTINCT CASE WHEN (device_type = 'desktop' AND utm_source = 'bsearch') THEN website_session_id ELSE NULL END) AS b_dtop_sessions,
    COUNT(DISTINCT CASE WHEN (device_type = 'desktop' AND utm_source = 'bsearch') THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN (device_type = 'desktop' AND utm_source = 'gsearch') THEN website_session_id ELSE NULL END) AS b_pct_of_g_dtop,
    COUNT(DISTINCT CASE WHEN (device_type = 'mobile' AND utm_source = 'gsearch') THEN website_session_id ELSE NULL END) AS g_mob_sessions,
    COUNT(DISTINCT CASE WHEN (device_type = 'mobile' AND utm_source = 'bsearch') THEN website_session_id ELSE NULL END) AS b_mob_sessions,
    COUNT(DISTINCT CASE WHEN (device_type = 'mobile' AND utm_source = 'bsearch') THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN (device_type = 'mobile' AND utm_source = 'gsearch') THEN website_session_id ELSE NULL END) AS b_pct_of_g_mob
FROM website_sessions
WHERE website_sessions.created_at BETWEEN '2012-11-04' AND '2012-12-22'
	AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	YEARWEEK(created_at)

![image](https://user-images.githubusercontent.com/38453077/217521539-0d8e213e-bb89-4a6d-904f-9a0911cd0489.png)


### Conclusion-
After 2nd Dec 2012 we see a drop in both gsearch and bsearch desktop but drop is significant in bsearch. And in case of mobile platform only gsearch has increase, bsearch seems to have no growth after 2nd Dec 2012

###  Q5. Analyzing free channels
SELECT DISTINCT
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE website_sessions.created_at < '2012-12-23';

SELECT
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS nonbrand,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS brand,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS brand_pct_of_nonbrand,
	COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) AS direct,
    COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS direct_pct_of_nonbrand,
	COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS organic,
    COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS organic_pct_of_nonbrand
FROM website_sessions
WHERE website_sessions.created_at < '2012-12-23'
GROUP BY
	YEAR(created_at),
    MONTH(created_at);
    
![image](https://user-images.githubusercontent.com/38453077/217521567-6ba0d72e-f9bd-46dc-86f0-af2cb150d0ad.png)

 
### Conclusion-
Organic reach and sessions are growing by seeing month trends and brand percent of non brand has also shown similar trend
