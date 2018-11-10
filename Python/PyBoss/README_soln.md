Python Homework: PyBoss

The solution is in main.py
It analyzes ./employee_data.csv and converts the fields as follows:

* The `Name` column should be split into separate `First Name` and `Last Name` columns.
* The `DOB` data should be re-written into `MM/DD/YYYY` format.
* The `SSN` data should be re-written such that the first five numbers are hidden from view.
* The `State` data should be re-written as simple two-letter abbreviations.

For eg.:
    Old format:
        Emp ID,Name,DOB,SSN,State
        214,Sarah Simpson,1985-12-04,282-01-8166,Florida
    New format:
        Emp ID,First Name,Last Name,DOB,SSN,State
        214,Sarah,Simpson,12/04/1985,***-**-8166,FL

The converted data is saved in a csv file ./new_employee_data.csv
