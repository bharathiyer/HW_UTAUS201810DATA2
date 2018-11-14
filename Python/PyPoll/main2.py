import os
import csv

# path to poll data file
pollfilepath = os.path.join('Resources', 'election_data.csv')
# open the file
with open(pollfilepath, newline='') as pollfile:
    # read csv
    pollreader = csv.reader(pollfile, delimiter=',')

    # ignore the header line
    next(pollreader)
    # copy col2 as votelist
    votelist = [c[2] for c in pollreader]
# dict comprehension to count votes
tally = {x: votelist.count(x) for x in set(votelist)}
# identify winner
winner = max(tally, key = tally.get)

rnum = len(votelist)
# generate the output string
outstr = f'''Election Results
-------------------------
Total Votes: {rnum}
-------------------------
'''
# identify winner
for (k,v) in tally.items():
    perc = v/rnum * 100
    outstr = outstr + f'{k}: {perc:.03f}% ({v})\n'
outstr = outstr + f'''-------------------------
Winner: {winner}
-------------------------'''
print(outstr)