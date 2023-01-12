#### You have data. Now what?

Don't panic! You have many tools and methods at your disposal. This documentation will show how you can use and combine them to make your data more valuable.

- **Explore** 
    - The simplest thing you can do is explore your raw data. There may be too much at first to be meaningful, but viewing your data is necessary to determine how to transform and summarize it. In data science this is called _Exploratory Data Analysis_ (EDA).
        - Example: Using `cat` to view a log file or loading a CSV into a spreadsheet.
    - _Visualizing_ your data through graphs and charts is a useful way to discover patterns and trends, identify outliers, and view relationships.
- **Filter** 
    - Reducing the amount of data through _filtering_ is nearly always going to be your first step and often between other operations as well. 
    - Not only does this remove noise irrelevant to your question or goal, but it decreases the time it takes to process the remaining data.
    - How to: Countless tools accomplish this in different ways. Anything that uses regular expressions, search terms, or comparisions is a way of filtering data. Common Linux utils like `grep` and `awk`, THT's `filter`, your SIEM's search bar, or even a SQL `WHERE` clause are all ways to accomplish this.
- **Compute** 
    - This is when you use fields from your existing data and perform some operation to create or _derive_ a new field, sometimes referred to as a _computed field_. A simple example would be adding the bytes sent and received together to get the total bytes transferred. In data science this is known as _Feature Engineering_.
    - _Computing_ normally involves some custom programming, either in a formal language like Python, or in a domain specific language (DSL) in a tool like Miller.
- **Correlate** 
    - Closely related to pivoting, which is when you would manually use a piece of information to _pivot_ into a different dataset. This can also be thought of as a _join_.
    - You can _correlate_ your data with other data by _joining_ datasets together on common fields.
        - Example: Taking multiple log types that share a field (e.g. IP address) and joining them together to create a single entry containing data from both logs. 
    - You can also _enrich_ your data using data from other sources, such as an API or existing database. 
        - Examples: Name resolution or passive DNS, geographical info, WHOIS or ownership info, or even threat intelligence feeds.
- **Summarize** 
    - _Summarizing_, also known as _grouping_, _aggregating_, or _data stacking_, reduces your data by combining data through methods such as the average, sum, or count.


<!-- - Visualize - can be broken down into EDA, conceptualization - Learning about your dataset

- Search / Filter - Reducing your dataset (filter), also columns (chop)
- Compute / Transform - increases your data by adding new information
- Summarize / group / aggregate / stack - related but reduces number of rows

Similar Models:

- Split, Apply, Combine - [Pandas `groupby` function](https://pandas.pydata.org/docs/user_guide/groupby.html)
- Extract, Transform, Load (ETL) - Data Science discipline
- Graph, Aggregate, Pivot, Statistics, Search (GAPPS) - [Chris Sanders' Practical Threat Hunting course](https://chrissanders.org/training/threat-hunting-training/) -->


# Complementary Projects

These are all projects that work well together with THT.

- [Elastic](https://www.elastic.co/elasticsearch/) / [Kibana](https://www.elastic.co/kibana/)
- [Metabase](https://github.com/metabase/metabase)
- [ml-workspace](https://github.com/ml-tooling/ml-workspace)
- [Data Science at the Command Line](https://www.datascienceatthecommandline.com/)

## Further Resources

- https://github.com/dbohdan/structured-text-tools