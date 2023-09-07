use employees;

--- 1. Row number
select e.*, row_number() over(partition by dept_name order by emp_no) as row_num from employees e 
join dept_emp de on e.emp_no = de.emp_no
join departments d on d.dept_no = de.dept_no;

-- Fetch the first two employees from each department tp join the company
select * from (select e.*, row_number() over(partition by dept_name) as row_num from employees e 
join dept_emp de on e.emp_no = de.emp_no
join departments d on d.dept_no = de.dept_no) new_emp where row_num > 1;

-- 2. Rank() Function
SELECT 
    *
FROM
    employees;
SELECT 
    *
FROM
    departments;
SELECT 
    *
FROM
    dept_emp;
SELECT 
    *
FROM
    salaries;
SELECT 
    *
FROM
    dept_manager;

-- Fetch top 3 employee from each department earning the highest salary
select * from(
              select e.emp_no, e.first_name, e.last_name, s.salary, de.dept_name, rank() 
              over(partition by dept_name order by salary desc) 
			  as rnk from employees e join salaries s on e.emp_no = s.emp_no 
              join dept_emp d on s.emp_no = d.emp_no join departments de on d.dept_no = de.dept_no) emp_rank 
where emp_rank.rnk < 4 ;

-- 3.Dense_Rank
select e.emp_no, e.first_name, e.last_name, s.salary, de.dept_name, dense_rank() 
over(partition by dept_name order by salary desc) 
as dns_rnk from employees e join salaries s on e.emp_no = s.emp_no 
join dept_emp d on s.emp_no = d.emp_no join departments de on d.dept_no = de.dept_no
limit 1500;

-- 4.Lead and Lag Functions
select e.emp_no, e.first_name, e.last_name, s.salary, de.dept_name, 
lead(salary) over(partition by dept_name order by emp_no desc) as emp_next_sal 
from employees e join salaries s on e.emp_no = s.emp_no 
join dept_emp d on s.emp_no = d.emp_no join departments de on d.dept_no = de.dept_no;
-- 5.Lag Function
select e.emp_no, e.first_name, e.last_name, s.salary, de.dept_name, 
lag(salary) over(partition by dept_name order by emp_no desc) as emp_prev_sal 
from employees e join salaries s on e.emp_no = s.emp_no 
join dept_emp d on s.emp_no = d.emp_no join departments de on d.dept_no = de.dept_no;

-- 6.First Value
-- Write a query to display the highest paid employee under each department
SELECT 
    *
FROM
    employees;
select e.emp_no, e.first_name, e.last_name, s.salary, de.dept_name, first_value(e.emp_no)
over(partition by de.dept_name order by salary) as hghest_employee from employees e join salaries s on e.emp_no = s.emp_no 
join dept_emp d on s.emp_no = d.emp_no join departments de on d.dept_no = de.dept_no;

-- 7. Last_value
-- Display the least paid employees under each department
select e.emp_no, e.first_name, e.last_name, s.salary, de.dept_name, 
last_value(e.emp_no)
over(partition by de.dept_name order by s.salary desc range between unbounded preceding and unbounded following) 
as least_paid_employee 
from employees e join salaries s on e.emp_no = s.emp_no 
join dept_emp d on s.emp_no = d.emp_no join departments de on d.dept_no = de.dept_no;

-- 8. NTH value
-- Write a query to display the second highest paid employee under each department
select e.emp_no, e.first_name, e.last_name, s.salary, de.dept_name, 
nth_value(e.emp_no, 2)
over w as second_paid_employee 
from employees e join salaries s on e.emp_no = s.emp_no 
join dept_emp d on s.emp_no = d.emp_no join departments de on d.dept_no = de.dept_no
window w as (partition by dept_name order by salary
range between unbounded preceding and unbounded following);

-- 9.Ntile Function
-- It's used to segragate a set of data within a partition
-- Write a query all the highest, middle and least paid employees from each department
-- First you create the employe categories
select e.emp_no, e.first_name, e.last_name, e.gender, s.salary, de.dept_name,
ntile(3) over(order by salary desc) as emp_sal_group from employees e join salaries s on e.emp_no = s.emp_no 
join dept_emp d on s.emp_no = d.emp_no join departments de on d.dept_no = de.dept_no
where gender = 'M' or 'F';

-- use a case statement
select emp_no, first_name, last_name, gender,
case when x.emp_sal_group > 20000 then 'Highest'
     when x.emp_sal_group <= 15000 then 'midrange'
     when x.emp_sal_group < 10000 then 'lowest'
     end as salary 
from (select e.emp_no, e.first_name, e.last_name, e.gender, s.salary, de.dept_name,
ntile(3) over(order by salary desc) as emp_sal_group from employees e join salaries s on e.emp_no = s.emp_no 
join dept_emp d on s.emp_no = d.emp_no join departments de on d.dept_no = de.dept_no
where gender = 'M' or 'F') x;

-- 10. Cume_dist(Cumulative Distribution)
-- Fetch all employees constituting first 30% of data based on their salaries in employees table
SELECT 
    *
FROM
    employees;
SELECT 
    *
FROM
    salaries;
select first_name, (perc_cum_dist||'%') as perc_cum_dist
from (select e.emp_no, e.first_name, e.gender, s.salary, 
cume_dist() over(order by s.salary) as cumul_dist,
round(cume_dist() over(order by s.salary desc)*100, 1) as perc_cum_dist
from employees e join salaries s on e.emp_no = s.emp_no) x
where perc_cum_dist<=30;

-- 11.Percent_Rank (Percentage Ranking)
-- Identify how much percentage more salary is "Parto" compared to all other employees
select first_name, percy_rank from (select e.emp_no, e.first_name, e.gender, s.salary, 
percent_rank() over(order by s.salary desc) as Rank_Percentage,
round(percent_rank() over(order by s.salary desc)*100, 1) as percy_rank
from employees e join salaries s on e.emp_no = s.emp_no) x where x.percy_rank = "Parto";
