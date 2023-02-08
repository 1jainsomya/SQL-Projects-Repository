-- Analyzing website traffic sources and cost
-- Which channels are generating the most traffic and how many of them are converted into sales
-- We have GA tracking parameters to track website sessions
-- Author Somya Jain

-- Q1. Finding the Top Traffic Sources
select utm_source,utm_campaign,http_referer,count(distinct website_session_id) from `mavenfuzzyfactory`.`website_sessions` 
where created_at<'2012-04-12' group by utm_source,utm_campaign,http_referer order by count(distinct website_session_id) desc;

-- Q2. Calculate session to order conversion rate 
select count(a.website_session_id) as Website_session_count,count(b.order_id) as Order_count,count(b.order_id)/count(a.website_session_id) as CVR_ratio from `mavenfuzzyfactory`.`website_sessions` as a
left join `mavenfuzzyfactory`.`orders` as b on a.website_session_id=b.website_session_id 
where a.created_at<'2012-04-12' and a.utm_source='gsearch' and a.utm_campaign='nonbrand';

-- Q3 Traffic Source Trends week by weeks analysis 
select week(created_at),min(date(created_at)),count(website_session_id) from `mavenfuzzyfactory`.`website_sessions` 
where created_at<'2012-05-10' and utm_source='gsearch' and utm_campaign='nonbrand' group by 1;

-- Q4 Seesion to order conversion rate by device type analysis
select device_type,count(distinct ws.website_session_id) as session_count,count(distinct order_id) as order_count,
count(distinct order_id)/count(distinct ws.website_session_id) as session_to_order
from `mavenfuzzyfactory`.`website_sessions` ws left join `mavenfuzzyfactory`.`orders` o on o.website_session_id=ws.website_session_id 
where ws.created_at<'2012.-05-11'  and utm_source='gsearch' and utm_campaign='nonbrand' group by 1;

-- Q5 Device type segment traffic source trend analysis 
select min(date(created_at)) as week_start,
count(distinct case when device_type='mobile' then website_session_id else null end) as mobile_session_count,
count(distinct case when device_type='desktop' then website_session_id else null end) as website_session_count 
 from `mavenfuzzyfactory`.`website_sessions` where created_at>'2012-04-15' and created_at<'2012-06-09' and utm_source='gsearch' and utm_campaign='nonbrand' 
 group by year(created_at),week(created_at) order by year(created_at),week(created_at)
