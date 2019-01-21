import numpy as np
import pandas as pd
import datetime as dt
import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, func

from flask import Flask, jsonify, request

import warnings
warnings.filterwarnings('ignore')

#################################################
# Database Setup
#################################################
engine = create_engine("sqlite:///Resources/hawaii.sqlite")

# reflect an existing database into a new model
Base = automap_base()
# reflect the tables
Base.prepare(engine, reflect=True)

# Save reference to the table
Measurement = Base.classes.measurement
Station = Base.classes.station

# Create our session (link) from Python to the DB
session = Session(engine)

#################################################
# Flask Setup
#################################################
app = Flask(__name__)


#################################################
# Flask Routes
#################################################

# Home page.
@app.route('/')
def welcome():
    ''' List all available api routes. '''
    return (
        'Welcome to Hawaii Weather Data - Precipitation and Temperature!<br/><br/>'
        'Available Routes:<br/>'
        '/api/v1.0/precipitation<br/>'
        '/api/v1.0/stations<br/>'
        '/api/v1.0/tobs<br/>'
        '/api/v1.0/{start}<br/>'
        '/api/v1.0/{start}/{end}<br/>'
    )
##def welcome()

@app.route('/api/v1.0/precipitation')
def precipitation():
    '''
    * Convert the query results to a Dictionary using `date` as the key and `prcp` as the value.
    * Return the JSON representation of your dictionary.
    '''

    # Calculate the date one year from the last date in data set.
    prev_year = dt.date(2017, 8, 23) - dt.timedelta(days=365)

    # Perform a query to retrieve the date and precipitation scores
    results = session.query(Measurement.date, Measurement.prcp).\
                filter(Measurement.date >= prev_year).\
                filter(Measurement.prcp.isnot(None)).all()

    # convert results to a dict
    pdict = {t[0]:t[1] for t in results}
    return jsonify(pdict)
##def precipitation()

@app.route('/api/v1.0/stations')
def stations():
    ''' Return a JSON list of stations from the dataset. '''
    # What are the most active stations? (i.e. what stations have the most rows)?
    # List the stations and the counts in descending order.
    sel = [Measurement.station,
           func.count(Measurement.station).label('counts')]
    stn_activity = session.query(*sel).group_by(Measurement.station).order_by('counts desc').all()

    # convert results to a dict
    sdict = {t[0]:t[1] for t in stn_activity}
    return jsonify(sdict)
##def stations()

@app.route('/api/v1.0/tobs')
def tobs():
    '''
    * query for the dates and temperature observations from a year from the last data point.
    * Return a JSON list of Temperature Observations (tobs) for the previous year.
    '''
    # Choose the station with the highest number of temperature observations.
    sel = [Measurement.station,
           func.count(Measurement.station).label('counts')]
    stn = session.query(*sel).filter(Measurement.tobs.isnot(None)).\
            group_by(Measurement.station).order_by('counts desc').limit(1).all()[0][0]

    # Calculate the date one year from the last date in data set.
    prev_year = dt.date(2017, 8, 23) - dt.timedelta(days=365)

    # Query the last 12 months of temperature observation data for this station and
    # plot the results as a histogram
    results = session.query(Measurement.date, Measurement.tobs).\
                filter(Measurement.station == stn).filter(Measurement.date >= prev_year).all()
    tobsdict = {t[0]:t[1] for t in results}
    return jsonify(tobsdict)
##def tobs()

def calc_temps(start_date, end_date):
    '''TMIN, TAVG, and TMAX for a list of dates.
    
    Args:
        start_date (string): A date string in the format %Y-%m-%d
        end_date (string): A date string in the format %Y-%m-%d
        
    Returns:
        TMIN, TAVE, and TMAX in json format
    '''
    sel = [func.min(Measurement.tobs).label('min_temp'),
           func.avg(Measurement.tobs).label('avg_temp'),
           func.max(Measurement.tobs).label('max_temp')]
    results = session.query(*sel).\
                filter(Measurement.date >= start_date).\
                filter(Measurement.date <= end_date).all()
    tdict = {'TMIN': results[0][0],
             'TAVG': results[0][1],
             'TMAX': results[0][2]}
    return jsonify(tdict)
##def calc_temps(start_date, end_date)

@app.route('/api/v1.0/<start>')
def temps(start):
    '''
    * Return a JSON list of the minimum temperature, the average temperature, and the max temperature
      for a given start or start-end range.
    * When given the start only, calculate `TMIN`, `TAVG`, and `TMAX` for all dates greater than and
      equal to the start date.
    '''
    return calc_temps(start, '2017-08-23')
##def temps(start)

@app.route('/api/v1.0/<start>/<end>')
def tempse(start, end):
    '''
    * Return a JSON list of the minimum temperature, the average temperature, and the max temperature
      for a given start or start-end range.
    * When given the start and the end date, calculate the `TMIN`, `TAVG`, and `TMAX` for dates between
      the start and end date inclusive.
    '''
    return calc_temps(start, end)
##def tempse(start, end)


if __name__ == "__main__":
    app.run(debug=True)
