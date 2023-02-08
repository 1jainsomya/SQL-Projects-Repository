--  Analyzing top website content.
--  Which pages are seen most by users and most common entry pages and how those pages convert to business objective. ALso analyze where people are exiting the website 
--  Author Somya Jain

--  EDA 
use mavenfuzzyfactory;
create temporary table first_page_view_temp
select website_session_id,min(website_pageview_id) as min_pv_id from `mavenfuzzyfactory`.`website_pageviews` group by`website_session_id`;
select * from first_page_view_temp as  fpv left join website_pageviews as wp on fpv.min_pv_id=wp.website_pageview_id ;

--  Q1 Identifying Top Websites Pages

select pageview_url,count( distinct website_pageview_id) as cnt_website_session from `mavenfuzzyfactory`.`website_pageviews` where created_at<'2012-06-09'
group by pageview_url order by count( distinct website_pageview_id) desc ;

--  Q2 Identifying Top Entry Pages
drop table if exists landing_page;
create temporary table landing_page
select
	website_session_id,min(website_pageview_id) as landing_page_id
    from website_pageviews
    where created_at<'2012-06-12'
    group by website_session_id;
    
select 
	website_pageviews.pageview_url as landing_page_url,
    count(distinct landing_page.website_session_id) as sessions_hitting_page
    from landing_page
    left join website_pageviews
    on landing_page.landing_page_id=website_pageviews.website_pageview_id
    group by website_pageviews.pageview_url;

--  Q3 Performace of Landing Page via bounce rate
--  Step 1: Finding the first website_pageview_id for relevant sessions

drop table if exists first_pageview;
CREATE TEMPORARY TABLE first_pageview
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pageview_id
FROM `mavenfuzzyfactory`.`website_pageviews`
WHERE created_at < '2012-06-14'
GROUP BY
	website_session_id;

--  STEP 2: identifying landing page of each session
drop table if exists sessions_w_landing_page;
CREATE TEMPORARY TABLE sessions_w_landing_page
SELECT
	first_pageview.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageview
	LEFT JOIN website_pageviews
		ON first_pageview.min_pageview_id = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url = '/home';

--  STEP 3: counting pageviews for each session, to identify "bounces"
CREATE TEMPORARY TABLE bounced_sessions
SELECT
	sessions_w_landing_page.website_session_id,
    sessions_w_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_landing_page
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_w_landing_page.website_session_id
GROUP BY
	sessions_w_landing_page.website_session_id,
    sessions_w_landing_page.landing_page
HAVING
	COUNT(website_pageviews.website_pageview_id) = 1;

--  STEP 4: Summarizing by counting total sessions and bounced sessions
SELECT
    COUNT(DISTINCT sessions_w_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) / COUNT(DISTINCT sessions_w_landing_page.website_session_id) AS bounce_rate
FROM sessions_w_landing_page
	LEFT JOIN bounced_sessions
		ON sessions_w_landing_page.website_session_id = bounced_sessions.website_session_id;
        
-- Q4. ANALYZING LANDING PAGE TESTS
--  STEP 1: find out when the new page /lander launched
SELECT
	created_at AS first_created_at,
    website_pageview_id AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1';

-- STEP 2: finding the first website_pageview_id for relevant sessions
CREATE TEMPORARY TABLE first_pageview_lander1
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
        AND website_pageviews.created_at < '2012-07-28' -- as per assignment
        AND website_pageviews.website_pageview_id > 23504 -- as per STEP 0
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	website_pageviews.website_session_id;

-- STEP 3: identifying landing page of each session
CREATE TEMPORARY TABLE sessions_w_landing_page_lander1
SELECT
	first_pageview_lander1.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageview_lander1
	LEFT JOIN website_pageviews
		ON first_pageview_lander1.min_pageview_id = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');

-- STEP 4: counting pageviews for each session, to identify "bounces"
CREATE TEMPORARY TABLE bounced_sessions_lander1
SELECT
	sessions_w_landing_page_lander1.website_session_id,
    sessions_w_landing_page_lander1.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_landing_page_lander1
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_w_landing_page_lander1.website_session_id
GROUP BY
	sessions_w_landing_page_lander1.website_session_id,
    sessions_w_landing_page_lander1.landing_page
HAVING
	COUNT(website_pageviews.website_pageview_id) = 1;

-- STEP 5: summarizing by counting total sessions and bounced sessions, by landing page
SELECT
	sessions_w_landing_page_lander1.landing_page,
    COUNT(DISTINCT sessions_w_landing_page_lander1.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions_lander1.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions_lander1.website_session_id) / COUNT(DISTINCT sessions_w_landing_page_lander1.website_session_id) AS bounce_rate
FROM sessions_w_landing_page_lander1
	LEFT JOIN bounced_sessions_lander1
		ON sessions_w_landing_page_lander1.website_session_id = bounced_sessions_lander1.website_session_id
GROUP BY
	sessions_w_landing_page_lander1.landing_page;

-- Q5. LANDING PAGE TREND ANALYSIS
#STEP 1: finding the first website_pageview_id for relevant sessions and website_pageview_id count
drop table if exists sessions_w_min_pv_and_view_count;
CREATE TEMPORARY TABLE sessions_w_min_pv_and_view_count
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE
	website_pageviews.created_at > '2012-06-01' #asked by requestor
	AND website_pageviews.created_at < '2012-08-31' #prescribed by assignment date
	AND website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	website_pageviews.website_session_id;

#STEP 2: identifying landing page of each session ad session_created_at
CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at
SELECT
sessions_w_min_pv_and_view_count.website_session_id,
sessions_w_min_pv_and_view_count.first_pageview_id,
sessions_w_min_pv_and_view_count.count_pageviews,
website_pageviews.pageview_url AS landing_page,
website_pageviews.created_at AS session_created_at
FROM sessions_w_min_pv_and_view_count
LEFT JOIN website_pageviews
	ON sessions_w_min_pv_and_view_count.first_pageview_id = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');

#STEP 3: summarizing by week (bounce rate, sessions to each lander)
SELECT
MIN(DATE(session_created_at)) AS week_start_date,
#COUNT(DISTINCT website_session_id) AS total_sessions,
#COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS bounce_rate,
COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions
FROM sessions_w_counts_lander_and_created_at
GROUP BY
YEARWEEK(session_created_at);
