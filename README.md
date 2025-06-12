# Señora Salsa
## By Eric Azevedo & Jesus Garcia
### CS340 Intro to Databases
----------------
\
We created a website where users can access the database for Señora Salsa, a bussines designed for this project to sell different types of salsas.   
Users can access Customers, Employees, Sales, Products, Categories, and SalesProducts info.  
The website is built via Flask using the following dependency in a virtual environment: 
```
pip3 install Flask flask-mysqldb gunicorn
```
\
\
To test run: ```python3 app.py```


**OVERVIEW**
 
Señora Salsa is a small business startup looking to take in stake in Panama with its Mexican style macha salsa.

Initial market research suggests a steady demand of 1,000 bottles/month in the first six months, with projected growth of 500 additional bottles/month, then, reaching 10,000 bottles/month by the end of year two. Assuming an average customer purchase of 2 bottles per sale, the system will need to handle approximately 48,000 sales records and manage 96,000 bottles sold within the first 24 months.

To support this growth, the business will begin with two employees and scale up to eight by year two. The product catalog will initially include four items: three spice levels of the flagship Picante Pili and one pickled product.

**CITATIONS**

We used codes from CS340 Exploration pages to help with the foundation of this project, as well as using a combination of ChatGPT and CoPilot to help with any errors. The included citations are on the top of each page, as well as below here. If a page has no citations, we did not use any citations in those pages (but to maintain the same format and flow, there might be some similarities between the pages, which could have resulted from such citations).

*app.py*

1. Used aspects of starter code from CS340 Exploration - Web Application Technology

2. Used GitHub Copilot to help with the debugging process by asking it to fix certain lines of code

\
*templates files* 

1. Used chatGPT to generate template for navigation buttons. Query: "Generate a template to generate buttons from existing html and j2 pages."

2. Used GitHub Copilot with debugging process like:
help fixing errors in output, how to make isActive show YES/NO instead 1/0

3. Used GitHub Copilot with debugging process like:
how to make categoryName show instead categoryID

4. Used GitHub Copilot with debugging process like: 
how to have edit be within the view table

5. Used GitHub Copilot with debugging process like: include customer name, sale date, total amount when user selects sales id in add section

\
*database files*
1. Adapted from CS340 Explorations