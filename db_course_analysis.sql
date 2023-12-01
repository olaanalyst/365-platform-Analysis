USE db_course_conversions;
SELECT * FROM db_course_conversions.student_engagement;
SELECT * FROM db_course_conversions.student_info;
SELECT * FROM db_course_conversions.student_purchases;

-- Select columns to retrieve information on students info
SELECT 
    i.student_id,
    i.date_registered,
    MIN(e.date_watched) AS first_date_watched,
    MIN(P.date_purchased) AS first_date_purchased,
    
 -- Calculate the difference in days between registration date and the first watch date   
    DATEDIFF(MIN(e.date_watched),
            MIN(i.date_registered)) AS days_diff_reg_watch,
    
    -- Calculate the difference in days between the first watch date and the first purchase date  
    DATEDIFF(MIN(p.date_purchased),
            MIN(e.date_watched)) AS days_diff_watch_purch
FROM
    student_info i
        JOIN
    student_engagement e ON i.student_id = e.student_id
        LEFT JOIN
    student_purchases p ON i.student_id = p.student_id
GROUP BY i.student_id , i.date_registered;


-- Join the three tables to retrieve the records
SELECT 
    e.student_id,
    e.date_watched,
    i.date_registered,
    p.purchase_id,
    p.date_purchased
FROM
    student_engagement e
        JOIN
    student_info i ON e.student_id = i.student_id
        JOIN
    student_purchases p ON e.student_id = p.student_id;

/*
Filter the data to exclude the records where the date of first-time engagement comes
later than the date of first-time purchase and the student who never made purchase
*/
SELECT 
    e.student_id,
    i.date_registered,
    MIN(e.date_watched) AS first_date_watched,
    MIN(p.date_purchased) AS first_date_purchased,
    DATEDIFF(MIN(e.date_watched), i.date_registered) AS days_diff_reg_watch,
    DATEDIFF(MIN(p.date_purchased),
            MIN(e.date_watched)) AS days_diff_watch_purch
FROM
    student_engagement e
        JOIN
    student_info i ON e.student_id = i.student_id
        LEFT JOIN
    student_purchases p ON e.student_id = p.student_id
GROUP BY e.student_id
HAVING first_date_purchased IS NULL
    OR first_date_watched <= first_date_purchased;

/*
Calculate the free-to-paid Conversion Rate
Calculate the Average Duration between Registration and First-Time Engagement
Calculate the Average  between First-Time Engagement and First-Time purchase
Create subquery
*/

 SELECT 
    ROUND(COUNT(first_date_purchased) / COUNT(first_date_watched),
            2) * 100 AS conversion_rate,
    ROUND(SUM(days_diff_reg_watch) / COUNT(days_diff_reg_watch),
            2) AS av_reg_watch,
    ROUND(SUM(days_diff_watch_purch) / COUNT(days_diff_watch_purch),
            2) AS av_watch_purch
FROM
    (SELECT 
        e.student_id,
            i.date_registered,
            MIN(e.date_watched) AS first_date_watched,
            MIN(p.date_purchased) AS first_date_purchased,
            DATEDIFF(MIN(e.date_watched), i.date_registered) AS days_diff_reg_watch,
            DATEDIFF(MIN(p.date_purchased), MIN(e.date_watched)) AS days_diff_watch_purch
    FROM
        student_engagement e
    JOIN student_info i ON e.student_id = i.student_id
    LEFT JOIN student_purchases p ON e.student_id = p.student_id
    GROUP BY e.student_id
    HAVING first_date_purchased IS NULL
        OR first_date_watched <= first_date_purchased) a;
 
