import os
import csv

# path to data file
budgetfilepath = os.path.join('Resources', 'budget_data.csv')

# open the data file
with open(budgetfilepath, newline='') as budgetfile:
    # read csv
    budgetreader = csv.reader(budgetfile, delimiter=',')
    # ignore the header line
    next(budgetreader)
    # copy rows into pnllist
    pnllist = [[p[0], int(p[1])] for p in budgetreader]

# total number of entries
rnum = len(pnllist)
# sum of pnl
totalpnl = sum(p[1] for p in pnllist)
# list of month to month changes in pnl
chglist = [(p[1] - pnllist[rnum][1]) for rnum, p in enumerate(pnllist[1:])]
# sum of month to month changes
totalchg = sum(chglist)
# calc average change in pnl
avgchg = totalchg/(rnum-1)
# extract max change and corresponding month
maxinc = max(chglist)
mimonth = pnllist[chglist.index(maxinc)+1][0]
# extract min change and corresponding month
maxdec = min(chglist)
mdmonth = pnllist[chglist.index(maxdec)+1][0]

# generate output string
outstr = f'''Financial Analysis
----------------------------
Total Months: {rnum}
Total: ${totalpnl}
Average  Change: ${avgchg:.02f}
Greatest Increase in Profits: {mimonth} (${maxinc})
Greatest Decrease in Profits: {mdmonth} (${maxdec})
'''

print(outstr)
# Put results in file
#fhandout = open('PyBank_analysis.txt', 'w')
#fhandout.write(outstr)
#fhandout.close()
