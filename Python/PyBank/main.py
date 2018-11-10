import os
import csv
def process_pnl(mdata):
    ''' Process the month, pnl reported in mdata to:
    - calculate running totalpnl and totalchg
    - identify max increase and max decrease'''
    global mimonth, mdmonth, maxinc, maxdec, totalchg, totalpnl, prevpnl
    # extract current pnl and add to total
    pnl = int(mdata[1])
    totalpnl += pnl
    # calc change in pnl
    chg = pnl - prevpnl
    # sum the change in pnl
    totalchg += chg
    # identify max increase and max decrease
    if (maxinc is None) or (maxinc < chg):
        maxinc = chg
        mimonth = mdata[0]
    if (maxdec is None) or (maxdec > chg):
        maxdec = chg
        mdmonth = mdata[0]

    # save current pnl
    prevpnl = pnl
##end process_pnl(pnl)

# path to data file
budgetfilepath = os.path.join('Resources', 'budget_data.csv')

mimonth = ""
mdmonth = ""
maxinc = None
maxdec = None
totalchg = 0
# open the data file
with open(budgetfilepath, newline='') as budgetfile:
    # read csv
    budgetreader = csv.reader(budgetfile, delimiter=',')
    # ignore the header line
    next(budgetreader)
    # read first line of data
    mdata = next(budgetreader)
    # extract pnl and initialize total
    prevpnl = int(mdata[1])
    totalpnl = prevpnl
    # loop across rows
    for (rnum, currow) in enumerate(budgetreader):
        process_pnl(currow)

# adjust rnum to account for the 2 lines read before the loop
rnum += 2
# calc average change in pnl
avgchg = totalchg/(rnum-1)

# generate output string
outstr = f'''Financial Analysis
----------------------------
Total Months: {rnum}
Total: ${totalpnl}
Average  Change: ${avgchg:.02f}
Greatest Increase in Profits: {mimonth} (${maxinc})
Greatest Decrease in Profits: {mdmonth} (${maxdec})'''

print(outstr)
# Put results in file
fhandout = open('PyBank_analysis.txt', 'w')
fhandout.write(outstr)
fhandout.close()
