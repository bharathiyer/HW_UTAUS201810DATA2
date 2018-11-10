import os
import csv
import us_state_abbrev as ussa

def convertline(old, new):
    ''' Convert each line to new format.
    Old format:
        Emp ID,Name,DOB,SSN,State
        214,Sarah Simpson,1985-12-04,282-01-8166,Florida
    New format:
        Emp ID,First Name,Last Name,DOB,SSN,State
        214,Sarah,Simpson,12/04/1985,***-**-8166,FL
    '''
    # copy the Emp ID
    new['Emp ID'] = old['Emp ID']

    # split the Name to First Name and Last Name
    namesplit = old['Name'].split()
    new['First Name'] = namesplit[0]
    new['Last Name'] = namesplit[1]

    # convert DOB from yyyy-mm-dd to mm/dd/yyyy
    olddob = old['DOB'].split('-')
    newdob = olddob[1:] + olddob[0:1]
    new['DOB'] = '/'.join(newdob)

    # hide first 5 digits of SSN
    oldssn = old['SSN'].split('-')
    new['SSN'] = '***-**-' + oldssn[2]

    # convert the state name to abbreviation
    new['State'] = ussa.abbrev[old['State']]

##end convertline(old, new)


# path to data file
empfilepath = 'employee_data.csv'
outfilepath = 'new_employee_data.csv'
# list the new header
newheader = ['Emp ID', 'First Name', 'Last Name', 'DOB', 'SSN', 'State']

with open(empfilepath, newline='') as empfile, open(outfilepath, 'w', newline='') as outfile:
    # read csv
    empreader = csv.DictReader(empfile, delimiter=',')
    # use csv DictWriter and provide the new header
    outwriter = csv.DictWriter(outfile, fieldnames=newheader)
    outwriter.writeheader()

    newline = dict()
    for (rnum, curline) in enumerate(empreader):
        convertline(curline, newline)
        outwriter.writerow(newline)

