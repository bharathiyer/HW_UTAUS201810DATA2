import os
import csv

# path to poll data file
pollfilepath = os.path.join('Resources', 'election_data.csv')
tally = dict()

# open the file
with open(pollfilepath, newline='') as pollfile:
    # read csv
    pollreader = csv.reader(pollfile, delimiter=',')
    # ignore the header line
    next(pollreader)
    # loop through the file
    for (rnum, currow) in enumerate(pollreader):
        # count a vote for the candidate
        cand = currow[2]
        tally[cand] = tally.get(cand, 0) + 1

rnum += 1
# generate the output string
outstr = f'''Election Results
-------------------------
Total Votes: {rnum}
-------------------------
'''

winner = ""
maxvote = 0
# identify winner
for (k,v) in tally.items():
    perc = v/rnum * 100
    outstr = outstr + f'{k}: {perc:.03f}% ({v})\n'
    if maxvote < v:
        maxvote = v
        winner = k

outstr = outstr + f'''-------------------------
Winner: {winner}
-------------------------'''
print(outstr)
# Put results in file
fhandout = open('PyPoll_analysis.txt', 'w')
fhandout.write(outstr)
fhandout.close()
