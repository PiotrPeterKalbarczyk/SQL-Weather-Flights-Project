# SQL Flights Project Challenge

## 📋 **Project Description**
This project addresses a business challenge for the flight-scheduling department by analyzing the accuracy of scheduled flight durations compared to actual elapsed times. The analysis focuses on flights in January, ensuring data reliability and providing actionable insights to enhance scheduling processes.

---

## 🎯 **Analysis Goals**
1. Verify the reliability of the `actual_elapsed_time` column in the `flights` table.
2. Assess the accuracy of the `scheduled flight duration` metric relative to `actual_elapsed_time`.
3. Identify routes with the highest percentage of flights where `scheduled flight duration` is shorter than `actual_elapsed_time`.
4. Calculate the average time difference for routes with at least 30 flights in January.

---

## 🛠️ **Technologies Used**
- **SQL**: PostgreSQL for data analysis.
- **Analytical Tools**: Common Table Expressions (CTEs) for structuring the analysis.

---

## 🚀 **How to Run the Project**
1. Clone the repository and open the SQL script in your preferred SQL tool (e.g., DBeaver).
2. Ensure your database contains the required tables (`flights`, `airports`).
3. Execute the queries step by step or run the entire script to replicate the analysis.

---

## 🗂️ **Repository Structure**
```
- README.md: Project documentation
- scripts/ : Main SQL script for analysis
- data/ : Sample data files 
```

---

## 💡 **Potential Project Extensions**
- Incorporating weather data to analyze its impact on flight delays.
- Expanding the analysis to include other months or years.
- Visualizing the results using Tableau or Python for deeper insights.
