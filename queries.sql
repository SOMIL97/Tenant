Select s.profile_id,concat (first_name,' ',last_name) as Full_name,phone from
Profiles s
Full join
Tenancy_histories t on
s.profile_id=t.profile_id
where s.profile_id=
(SELECT top 1 profile_id from Tenancy_histories)
order by DATEDIFF(month,move_in_date,move_out_date);

select concat (first_name,' ',last_name) as Full_Name,email, phone
from Profiles
where (Profiles.profile_id 
IN (select profile_id from Tenancy_histories where (Tenancy_histories.rent>9000))) 
and Profiles.marital_status = 'Y';

select DISTINCT p.profile_id, concat (first_name,' ',last_name) as Full_Name,phone,email,city,a.house_id,
move_in_date,move_out_date,rent,count(referrer_id) as Referrals_made,latest_employer,Occupational_category
from Profiles p
Full JOIN
Tenancy_histories t On
p.profile_id = t.profile_id
Full join
Referrals r On
p.profile_id = r.referrer_id
Full Join
Employment_details e On
p.profile_id = e.profile_id
Full Join
Addresses a On
t.house_id = a.house_id
where city in
( select city from Addresses where city = 'bangalore'or city ='Pune'
and move_in_date > '12-31-2014')
group by p.profile_id,t.move_in_date,t.move_out_date,first_name,last_name,phone,email,city,a.house_id,
move_in_date,move_out_date,rent,latest_employer,Occupational_category
Order by rent DESC;



select DISTINCT concat (first_name,' ',last_name) as Full_Name,email, phone,referral_code,sum(referrer_bonus_amount) as Total_bonus
from Profiles p
inner join
Referrals r
On
p.profile_id = r.referrer_id
where exists
(select count(referrer_id) as Count_of_id
from Referrals
where referral_valid=1
having count(referrer_id) > 1)
Group by referral_valid,referrer_id,first_name,last_name,email,phone,referral_code;


select a.city,sum(rent) as Total_city_rent
from Tenancy_histories t
Right join
Addresses a
On
t.house_id  =a.house_id
Group by city
UNION
Select 'Total' as City, SUM(rent) from Tenancy_histories;

CREATE VIEW
vw_tenant 
AS
Select profile_id,rent,move_in_date,house_type,beds_vacant,description,city  
From  Tenancy_histories f
INNER JOIN
Houses h
ON
f.house_id = h.house_id
INNER JOIN
Addresses a
ON
h.house_id = a.house_id
where Beds_vacant != 0
and move_in_date >= '04-30-2015'
go
select * from vw_tenant;


Select referrer_id,DATEADD(MM, 1, valid_till) as Extended_date
from  referrals
where  referrer_id in
(select referrer_id from referrals
 group by referrer_id
 having count(referrer_id) > 2);


 Select DISTINCT concat (first_name,' ',last_name) as Full_Name,email, phone,
IIF(rent > 10000,'Grade A',
IIF(rent >= 7500 and rent<= 10000, 'Grade B','Grade C') ) as Customer_Segment
From Profiles p
inner join
Tenancy_histories t On
p.profile_id = t.profile_id
group by rent,first_name,last_name,email,phone;

 Select DISTINCT concat (first_name,' ',last_name) as Full_Name,email,   phone,city_hometown,r.referrer_id,h.house_type,
 h.bhk_details,h.furnishing_type
 from Profiles p
 full join
 Tenancy_histories t
 On
 p.profile_id=t.profile_id
 full join
 Referrals r
 On
 p.profile_id = r.referrer_id
 full join
 Houses h
 On
 t.house_id=h.house_id
 where p.profile_id not in (select referrer_id from Referrals)
 group by r.referrer_id,first_name,last_name,email,phone,city_hometown,house_type,bhk_details,furnishing_type;


 select top (1) with ties a.house_id,a.name,h.house_type,h.bhk_details,h.furnishing_type, 
(h.bed_count - h.Beds_vacant) AS Total_Occupancy
from Addresses a
INNER JOIN Houses h 
ON 
a.house_id = h.house_id 
order by Total_Occupancy Desc
