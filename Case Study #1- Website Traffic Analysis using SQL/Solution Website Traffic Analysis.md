##	Website Traffic Analysis SQL 
##	Somya Jain

### Q1. Finding the Top Traffic Sources

select utm_source,utm_campaign,http_referer,count(distinct website_session_id) from `mavenfuzzyfactory`.`website_sessions` 
where created_at<'2012-04-12' group by utm_source,utm_campaign,http_referer order by count(distinct website_session_id) desc

![image](https://user-images.githubusercontent.com/38453077/217515431-e03a8b66-9bd1-43d3-98ec-98c258832e2a.png)


 
### Conclusion-
Gsearch and non-brand campaign combination is driving the most visit on the website

### Q2. Calculate session to order conversion rate
select count(b.order_id)/count(a.website_session_id) from `mavenfuzzyfactory`.`website_sessions` as a
left join `mavenfuzzyfactory`.`orders` as b on a.website_session_id=b.website_session_id 
where a.created_at<'2012-04-12' and a.utm_source='gsearch' and a.utm_campaign='nonbrand'

![image](https://user-images.githubusercontent.com/38453077/217515478-c7d18f45-ca8b-495d-85f2-184b2325c35c.png)

 
### Conclusion-
Conversion Rate for sales is around 2% for Gsearch and non-brand campaign 

### Q3. Traffic Source Trends week by weeks analysis 
select week(created_at),min(date(created_at)),count(website_session_id) from `mavenfuzzyfactory`.`website_sessions` 
where created_at<'2012-05-10' and utm_source='gsearch' and utm_campaign='nonbrand' 
group by 1;
![image](https://user-images.githubusercontent.com/38453077/217515501-c786cd56-775d-43f6-9470-71525be177b0.png)

 
### Conclusion-
There is considerable decline in users session after 8th April week 

### Q4. Session to order conversion rate by device type analysis
select device_type,count(distinct ws.website_session_id) as session_count,count(distinct order_id) as order_count,
count(distinct order_id)/count(distinct ws.website_session_id) as session_to_order
from `mavenfuzzyfactory`.`website_sessions` ws left join `mavenfuzzyfactory`.`orders` o on o.website_session_id=ws.website_session_id 
where ws.created_at<'2012.-05-11'  and utm_source='gsearch' and utm_campaign='nonbrand' group by 1;

![image](https://user-images.githubusercontent.com/38453077/217515521-9fb0f413-b817-4617-8200-24033802ee53.png)

 
### Conclusion-
Mobile devices have much lower conversion rate than desktop app

### Q5. Device type segment traffic source trend analysis 
select min(date(created_at)) as week_start,
count(distinct case when device_type='mobile' then website_session_id else null end) as mobile_session_count,
count(distinct case when device_type='desktop' then website_session_id else null end) as website_session_count 
 from `mavenfuzzyfactory`.`website_sessions` where created_at>'2012-04-15' and created_at<'2012-06-09' and utm_source='gsearch' and utm_campaign='nonbrand' 
 group by year(created_at),week(created_at) order by year(created_at),week(created_at)

 ![image](https://user-images.githubusercontent.com/38453077/217515552-95f72d43-fc34-477a-8f7a-a1ddd6e77ed3.png)

 
### Conclusion-
Website sessions are increased after May 13th and Mobile sessions did not had much changes 
