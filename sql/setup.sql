-- Run this file from the project root:
-- mysql -u root -p < sql/setup.sql
SOURCE sql/01_schema.sql;
SOURCE sql/02_seed_data.sql;
SOURCE sql/03_views.sql;

SELECT 'Database setup completed successfully.' AS status;

