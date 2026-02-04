USE customer_shopping_behavior;

-- 1. Total revenue by gender + their percentage share
SELECT gender, SUM(purchase_amount) AS revenue, 100 * (SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER ()) AS percentage_share
FROM customer
GROUP BY gender;

-- 2. Customers who use a discount but still spent more than the average purchase amount and by how much
SELECT customer_id, purchase_amount, purchase_amount - (SELECT AVG(purchase_amount) FROM customer) AS above_avg_amount
FROM customer
WHERE discount_applied = 'Yes' and purchase_amount >= (SELECT AVG(purchase_amount) FROM customer);

-- 3. Top 5 products with the highest average review rating
SELECT item_purchased, AVG(review_rating) AS avg_review_rating 
FROM customer
GROUP BY item_purchased
ORDER BY avg_review_rating DESC
LIMIT 5;

-- 4. Comparison between Standard and Express shipping
SELECT shipping_type, COUNT(*) AS no_of_purchases, AVG(purchase_amount) 
FROM customer
WHERE shipping_type IN ('Standard', 'Express') 
GROUP BY shipping_type;

-- 5. Subscribed customers vs non-subscribers on average spend and total revenue
SELECT subscription_status, COUNT(*) AS total_purchases, AVG(purchase_amount) AS avg_spend, SUM(purchase_amount) AS total_revenue
FROM customer
WHERE subscription_status IN ('Yes', 'No') 
GROUP BY subscription_status;

-- 6. Top 5 products with highest percentage of purchases with discounts applied
SELECT item_purchased, 
		100.0 * SUM(CASE 
					WHEN discount_applied = 'Yes' THEN 1
                    ELSE 0
                  END) / COUNT(*) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

-- 7. Segment customers into New, Returning, and Loyal based on their previous purchases and show the count and revenue of each segment
SELECT 
	CASE
		WHEN previous_purchases < 2 THEN 'New'
        WHEN previous_purchases BETWEEN 2 and 10 THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_type, 
    COUNT(*) AS no_of_customers, SUM(purchase_amount) AS total_revenue
FROM customer    
GROUP BY customer_type;
    
-- 8. Top 3 most purchased products within each category
SELECT item_rank, category, item_purchased, no_of_purchases
FROM 
	(SELECT item_purchased, category, COUNT(*) as no_of_purchases,
		ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS item_rank 
    FROM customer
	GROUP BY item_purchased, category
    ) ranked_items	  -- an alias/table name for this nested query
WHERE item_rank <= 3;
    
-- 9. Repeat buyers (more than 5 previous purchases) on subscription
SELECT subscription_status, COUNT(*) as repeat_buyers, 100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS percentage_share
FROM customer    
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- 10. Revenue and share contribution of each age group
SELECT age_group, SUM(purchase_amount) AS total_revenue, 100.0 * SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER () AS percentage_share
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;

-- 11. Discount impact on spending
SELECT discount_applied, COUNT(*) AS purchases, AVG(purchase_amount) AS avg_spend, SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY discount_applied;

-- 12. Frequency vs value
SELECT frequency_of_purchases, COUNT(*) AS customers, AVG(purchase_amount) AS avg_spend, SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY frequency_of_purchases
ORDER BY total_revenue DESC;

-- 13. Season-wise sales
SELECT category, 
		SUM(CASE WHEN season = 'Winter' THEN purchase_amount ELSE 0 END) AS winter_sales,
        SUM(CASE WHEN season = 'Summer' THEN purchase_amount ELSE 0 END) AS summer_sales,
        SUM(CASE WHEN season = 'Spring' THEN purchase_amount ELSE 0 END) AS spring_sales,
        SUM(CASE WHEN season = 'Fall' THEN purchase_amount ELSE 0 END) AS fall_sales
FROM customer
GROUP BY category
ORDER BY winter_sales DESC, summer_sales DESC, spring_sales DESC, fall_sales DESC;

-- 14. Locations vs revenue and subscription rate
SELECT location, SUM(purchase_amount) as revenue, 
		100.0 * SUM(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) as subcription_rate
FROM customer
GROUP BY location
ORDER BY revenue DESC;

-- 15. Sizes vs repeat-purchase rates
SELECT size, SUM(CASE WHEN previous_purchases > 2 THEN 1 ELSE 0 END) AS repeat_customers, 
		100.0 * SUM(CASE WHEN previous_purchases > 2 THEN 1 ELSE 0 END) / COUNT(*) AS repeat_purchase_rate
FROM customer
GROUP BY size
ORDER BY repeat_purchase_rate DESC;

-- 16. Most popular color per category
SELECT category, color AS popular_color, color_rank
FROM (
	   SELECT category, color, COUNT(color) AS color_count,
			ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS color_rank
	   FROM customer
	   GROUP BY category, color
      ) ranked_colors
WHERE color_rank = 1;      

-- 17. Top 3 products per location
SELECT location, item_purchased, product_count
FROM (
    SELECT location, item_purchased, COUNT(*) AS product_count,
        ROW_NUMBER() OVER (PARTITION BY location ORDER BY COUNT(*) DESC) AS product_rank
    FROM customer
    GROUP BY location, item_purchased
) ranked_products
WHERE product_rank <= 3;

-- 18. Size preferences by gender
SELECT gender, size, COUNT(*) AS no_of_purchases
FROM customer
GROUP BY gender, size
ORDER BY gender, no_of_purchases DESC;

-- 19. Top color preferences across seasons
SELECT season, color AS top_colors, color_count
FROM (
	  SELECT season, color, COUNT(*) AS color_count,
        ROW_NUMBER() OVER (PARTITION BY season ORDER BY COUNT(*) DESC) AS color_rank
    FROM customer
    GROUP BY season, color
) ranked_colors
WHERE color_rank = 1;

-- 20. Most used payment methods
SELECT payment_method, COUNT(*) AS no_of_purchases
FROM customer
GROUP BY payment_method
ORDER BY no_of_purchases DESC;

-- 21. Payment methods preferred by high-value customers
SELECT payment_method, COUNT(*) AS high_value_payments, AVG(purchase_amount) AS avg_purchase_amount
FROM customer
WHERE purchase_amount > (SELECT AVG(purchase_amount) FROM customer)
GROUP BY payment_method
ORDER BY high_value_payments DESC;

-- 22. Discount usage rate by payment method
SELECT payment_method, COUNT(*) AS total_transactions, 
		SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) AS discounted_transactions,
        100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) AS discount_usage_rate
FROM customer        
GROUP BY payment_method
ORDER BY discount_usage_rate DESC;










